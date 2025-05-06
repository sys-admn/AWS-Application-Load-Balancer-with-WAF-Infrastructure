# AWS Provider
aws_region = "eu-west-3"

# General settings
tag         = "dev"
environment = "Development"
project     = "ALB-WAF-Demo"

# VPC settings
vpc_cidr_block              = "10.0.0.0/16"
public_subnet_count         = 2
private_subnet_count        = 2
availability_zones          = ["eu-west-3a", "eu-west-3b"]
associate_public_ip_address = true
create_nat_gateway          = true
single_nat_gateway          = true  # Use single NAT Gateway for cost savings in dev

# Security settings
bastion_allowed_ips         = ["78.112.57.78/32"]  # FIXME Replace with your actual IP

# ALB settings
alb_name                    = "dev-alb"
enable_https                = false
enable_deletion_protection  = false
# Le bucket sera créé automatiquement, ne pas spécifier de nom ici
access_logs_bucket          = ""

# WAF settings
waf_blocked_ips             = ["46.193.64.43/32"]  # FIXME Example IPs to block
enable_waf_core_rule_set    = true
enable_waf_sql_injection_protection = true
enable_waf_rate_limiting    = true
enable_geo_restriction      = true  # Activé les restrictions géographiques
allowed_country_codes       = ["FR"]  # FIXME

# EC2 settings
key_name                    = "key-mgnt-dev"
instance_type               = "t2.micro"
bastion_instance_type       = "t2.micro"
min_size                    = 1
max_size                    = 3
desired_capacity            = 2
root_volume_size            = 8
root_volume_type            = "gp2"
web_associate_public_ip     = false
bastion_associate_public_ip = true
ami_name_filter             = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"

# CloudWatch settings
dashboard_name              = "Dev-ALB-WAF-EC2-Dashboard"
sns_topic_arn               = "arn:aws:sns:eu-west-3:234747448884:sns-dev" #FIXME
alarm_evaluation_periods    = 1
alarm_period                = 60
enable_ok_actions           = false
enable_4xx_alarm            = true
enable_latency_alarm        = true
enable_per_instance_alarms  = false
enable_bastion_monitoring   = true
enable_composite_alarm      = false
enable_memory_metrics       = false
enable_disk_metrics         = false

# Alarm thresholds
cpu_high_threshold          = 80
cpu_low_threshold           = 20
alb_5xx_error_threshold     = 5
alb_4xx_error_threshold     = 100
alb_latency_threshold       = 1
waf_blocked_requests_threshold = 10
bastion_cpu_threshold       = 80

# Logs settings
logs_transition_to_ia_days = 30
logs_transition_to_glacier_days = 90
logs_expiration_days = 365
cloudwatch_log_retention_days = 30
high_log_volume_threshold = 5000000  # 5MB

# Flow Logs settings
enable_flow_logs = true  # FIXME Désactivé temporairement pour éviter les conflits