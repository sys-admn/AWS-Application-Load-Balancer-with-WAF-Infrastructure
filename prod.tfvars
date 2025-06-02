# AWS Provider
aws_region = "us-east-1"

# General settings
tag         = "prod"
environment = "Production"
project     = "ALB-WAF-Demo"

# VPC settings
vpc_cidr_block              = "11.0.0.0/16"
public_subnet_count         = 3
private_subnet_count        = 3
availability_zones          = ["us-east-1a", "us-east-1b", "us-east-1c"]
associate_public_ip_address = true
create_nat_gateway          = true
single_nat_gateway          = false  # Use multiple NAT Gateways for high availability in prod

# Security settings
# bastion_allowed_ips is defined in secrets.tfvars

# ALB settings
alb_name                    = "prod-alb"
enable_https                = false
# certificate_arn is defined in secrets.tfvars
enable_deletion_protection  = true
# Le bucket sera créé automatiquement, ne pas spécifier de nom ici
access_logs_bucket          = ""

# WAF settings
# waf_blocked_ips is defined in secrets.tfvars
enable_waf_core_rule_set    = true
enable_waf_sql_injection_protection = true
enable_waf_rate_limiting    = true
enable_geo_restriction      = true
allowed_country_codes       = ["FR"]

# EC2 settings
key_name                    = "key-mgnt-prod"
instance_type               = "t3.small"
bastion_instance_type       = "t3.micro"
min_size                    = 2
max_size                    = 6
desired_capacity            = 3
root_volume_size            = 20
root_volume_type            = "gp3"
web_associate_public_ip     = false
bastion_associate_public_ip = true
cpu_high_threshold          = 70
cpu_low_threshold           = 30
ami_name_filter             = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"

# CloudWatch settings
dashboard_name              = "Prod-ALB-WAF-EC2-Dashboard"
# sns_topic_arn is defined in secrets.tfvars
alarm_evaluation_periods    = 2
alarm_period                = 60

# Logs settings
logs_transition_to_ia_days = 30
logs_transition_to_glacier_days = 90
logs_expiration_days = 730 
cloudwatch_log_retention_days = 90  
high_log_volume_threshold = 10000000  # 10MB