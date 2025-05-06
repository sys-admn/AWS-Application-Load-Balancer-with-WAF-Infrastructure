locals {
  # Fusion des tags communs avec les tags spécifiques à l'environnement
  env_tags = {
    dev = {
      Tier = "Non-Production"
      Environment = "Development"
    }
    prod = {
      Tier = "Production"
      Environment = "Production"
    }
  }
  
  # Sélectionner les tags en fonction de l'environnement (utiliser var.environment si terraform.workspace n'est pas défini)
  environment_name = contains(["dev", "prod"], terraform.workspace) ? terraform.workspace : var.environment == "Production" ? "prod" : "dev"
  selected_env_tags = local.env_tags[local.environment_name]
  
  # Fusionner avec les tags communs
  all_tags = merge(
    var.common_tags,
    {
      NetworkTier = "Core"
    },
    local.selected_env_tags
  )
  
  # Utiliser le bucket S3 créé pour les logs ALB
  alb_logs_bucket_name = aws_s3_bucket.alb_logs.id
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr_block              = var.vpc_cidr_block
  tag                         = var.tag
  public_subnet_count         = var.public_subnet_count
  private_subnet_count        = var.private_subnet_count
  availability_zones          = var.availability_zones
  associate_public_ip_address = var.associate_public_ip_address
  create_nat_gateway          = var.create_nat_gateway
  single_nat_gateway          = var.single_nat_gateway
  nat_gateway_subnet_index    = 0
  
  tags = merge(
    local.all_tags,
    {
      Environment = var.environment
      Project     = var.project
    }
  )
}

module "flow_logs" {
  source = "./modules/flow_logs"
  count  = var.enable_flow_logs ? 1 : 0
  
  name_prefix    = var.tag
  vpc_id         = module.vpc.vpc_id
  region         = var.aws_region
  retention_days = var.flow_logs_retention_days
  traffic_type   = var.flow_logs_traffic_type
  
  # Use existing log group if it already exists
  use_existing_log_group = true
  existing_log_group_name = "/aws/vpc/${var.tag}-flow-logs"
  
  create_dashboard = var.flow_logs_create_dashboard
  create_alarms    = var.flow_logs_create_alarms
  rejected_traffic_threshold = var.flow_logs_rejected_traffic_threshold
  alarm_actions    = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  
  tags = merge(
    local.all_tags,
    {
      Environment = var.environment
      Project     = var.project
      Component   = "NetworkMonitoring"
    }
  )
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
  name_prefix = "${var.tag}-"
  
  # Use the variable for bastion access
  bastion_allowed_cidr_blocks = var.bastion_allowed_ips
  
  # Custom ALB ingress rules
  alb_ingress_rules = [
    {
      description = "HTTP from anywhere"
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    # Add HTTPS rule if enabled
    var.enable_https ? {
      description = "HTTPS from anywhere"
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    } : null
  ]
  
  tags = merge(
    local.all_tags,
    {
      Environment = var.environment
      Project     = var.project
      Component   = "Security"
    }
  )
}

module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.security_groups.alb_sg_id
  
  # ALB configuration
  alb_name                  = var.alb_name
  name_prefix               = "${var.tag}-"
  enable_deletion_protection = var.enable_deletion_protection
  access_logs_bucket        = local.alb_logs_bucket_name
  access_logs_prefix        = "${var.tag}-alb-logs"
  
  # HTTPS configuration
  enable_https              = var.enable_https
  certificate_arn           = var.certificate_arn
  
  tags = merge(
    local.all_tags,
    {
      Environment = var.environment
      Project     = var.project
      Component   = "LoadBalancer"
    }
  )
  
  depends_on = [aws_s3_bucket_policy.alb_logs_policy]
}

module "waf" {
  source       = "./modules/waf"
  alb_arn      = module.alb.alb_arn
  waf_name     = "${var.tag}-waf"
  name_prefix  = "${var.tag}-"
  ip_addresses = var.waf_blocked_ips
  
  # WAF security features
  enable_core_rule_set           = var.enable_waf_core_rule_set
  enable_sql_injection_protection = var.enable_waf_sql_injection_protection
  enable_rate_limiting           = var.enable_waf_rate_limiting

  # Geo-restriction settings
  enable_geo_restriction         = var.enable_geo_restriction
  allowed_country_codes          = var.allowed_country_codes
  
  tags = merge(
    local.all_tags,
    {
      Environment = var.environment
      Project     = var.project
      Component   = "Security"
      SecurityFunction = "WAF"
    }
  )
}

module "ec2" {
  source           = "./modules/ec2"
  private_subnets  = module.vpc.private_subnets
  public_subnets   = module.vpc.public_subnets
  web_sg_id        = module.security_groups.web_sg_id
  bastion_sg_id    = module.security_groups.bastion_sg_id
  target_group_arn = module.alb.target_group_arn
  
  # EC2 configuration
  name_prefix               = "${var.tag}-"
  key_name                  = var.key_name
  instance_type             = var.instance_type
  bastion_instance_type     = var.bastion_instance_type
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  root_volume_size          = var.root_volume_size
  root_volume_type          = var.root_volume_type
  web_associate_public_ip   = var.web_associate_public_ip
  bastion_associate_public_ip = var.bastion_associate_public_ip
  ami_name_filter           = var.ami_name_filter
  
  # CloudWatch configuration
  cloudwatch_log_group_name = module.logs.ec2_log_group_name
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days
  
  tags = merge(
    local.all_tags,
    {
      Environment = var.environment
      Project     = var.project
      Component   = "Compute"
    }
  )
}

module "cloudwatch" {
  source         = "./modules/cloudwatch"
  
  # Only include the essential parameters
  dashboard_name = var.dashboard_name
  region         = var.aws_region
  alb_name       = module.alb.alb_name
  waf_name       = module.waf.waf_name
  instance_ids   = module.ec2.instance_ids
  sns_topic_arn  = var.sns_topic_arn
  
  # Include the parameters that are causing errors
  name_prefix    = "${var.tag}-"
  bastion_instance_id = module.ec2.bastion_id
  autoscaling_group_name = module.ec2.autoscaling_group_name
  target_group_arn = module.alb.target_group_arn
  
  # Include the auto scaling policy ARNs
  asg_scale_up_policy_arn = module.ec2.scale_up_policy_arn
  asg_scale_down_policy_arn = module.ec2.scale_down_policy_arn
  
  # Include the threshold variables
  cpu_high_threshold = var.cpu_high_threshold
  cpu_low_threshold = var.cpu_low_threshold
  enable_geo_restriction = var.enable_geo_restriction
  
  # CloudWatch agent metrics - these variables are defined in the module
  ec2_log_group_name = module.logs.ec2_log_group_name
  waf_log_group_name = module.logs.waf_log_group_name
  
  tags = merge(
    local.all_tags,
    {
      Environment = var.environment
      Project     = var.project
      Component   = "Monitoring"
    }
  )

  depends_on = [module.alb, module.ec2, module.waf, module.vpc]
}

module "logs" {
  source = "./modules/logs"
  
  name_prefix = "${var.tag}-"
  region      = var.aws_region
  waf_arn     = module.waf.waf_arn
  sns_topic_arn = var.sns_topic_arn
  
  # Log retention settings
  transition_to_ia_days = var.logs_transition_to_ia_days
  transition_to_glacier_days = var.logs_transition_to_glacier_days
  expiration_days = var.logs_expiration_days
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days
  high_log_volume_threshold = var.high_log_volume_threshold
  
  tags = merge(
    local.all_tags,
    {
      Environment = var.environment
      Project     = var.project
      Component   = "Logging"
      DataRetention = "Standard"
    }
  )
  
  depends_on = [module.waf]
}