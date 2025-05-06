variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "tag" {
  description = "Tag to add to resource names"
  type        = string
  default     = "dev"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "Development"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ALB-WAF-Demo"
}

# Tags variables
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    Owner       = "InfraTeam"
    Application = "ALB-WAF-Demo"
  }
}

# VPC variables
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 2
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]
}

variable "associate_public_ip_address" {
  description = "Whether to associate public IP addresses with instances in public subnets"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateway(s)"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

# Security variables
variable "bastion_allowed_ips" {
  description = "List of CIDR blocks allowed to access the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ALB variables
variable "alb_name" {
  description = "Name of the ALB"
  type        = string
  default     = "web-alb"
}

variable "enable_https" {
  description = "Whether to enable HTTPS listener"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
  default     = ""
}

# WAF variables
variable "waf_blocked_ips" {
  description = "List of IP addresses to block"
  type        = list(string)
  default     = []
}

variable "enable_waf_core_rule_set" {
  description = "Whether to enable AWS WAF Core Rule Set"
  type        = bool
  default     = true
}

variable "enable_waf_sql_injection_protection" {
  description = "Whether to enable SQL injection protection"
  type        = bool
  default     = true
}

variable "enable_waf_rate_limiting" {
  description = "Whether to enable rate limiting"
  type        = bool
  default     = true
}

variable "enable_geo_restriction" {
  description = "Whether to enable geographic restrictions"
  type        = bool
  default     = false
}

variable "allowed_country_codes" {
  description = "List of allowed country codes if geo restriction is enabled"
  type        = list(string)
  default     = ["US", "CA", "GB", "FR"]
}

# EC2 variables
variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = "alb-waf"
}

variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t2.micro"
}

variable "bastion_instance_type" {
  description = "EC2 instance type for bastion host"
  type        = string
  default     = "t2.micro"
}

variable "min_size" {
  description = "Minimum number of instances in the auto scaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the auto scaling group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in the auto scaling group"
  type        = number
  default     = 2
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Type of the root volume (gp2, gp3, io1, etc.)"
  type        = string
  default     = "gp2"
}

variable "web_associate_public_ip" {
  description = "Whether to associate public IP addresses with web instances"
  type        = bool
  default     = false
}

variable "bastion_associate_public_ip" {
  description = "Whether to associate a public IP address with the bastion host"
  type        = bool
  default     = true
}

variable "ami_name_filter" {
  description = "Filter pattern for the AMI name"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

# CloudWatch variables
variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
  default     = "ALB-WAF-EC2-Dashboard"
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  type        = string
  default     = ""
}

variable "alarm_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm"
  type        = number
  default     = 1
}

variable "alarm_period" {
  description = "Period in seconds over which to evaluate the alarm"
  type        = number
  default     = 60
}

variable "cpu_high_threshold" {
  description = "Threshold for high CPU utilization alarm"
  type        = number
  default     = 80
}

variable "cpu_low_threshold" {
  description = "Threshold for low CPU utilization alarm"
  type        = number
  default     = 20
}

# Variables qui manquaient et causaient des avertissements
variable "enable_ok_actions" {
  description = "Whether to enable OK actions for alarms"
  type        = bool
  default     = false
}

variable "enable_4xx_alarm" {
  description = "Whether to enable alarm for 4XX errors"
  type        = bool
  default     = true
}

variable "enable_latency_alarm" {
  description = "Whether to enable alarm for high latency"
  type        = bool
  default     = true
}

variable "enable_per_instance_alarms" {
  description = "Whether to enable per-instance alarms"
  type        = bool
  default     = false
}

variable "enable_bastion_monitoring" {
  description = "Whether to enable monitoring for the bastion host"
  type        = bool
  default     = true
}

variable "enable_composite_alarm" {
  description = "Whether to enable composite alarms"
  type        = bool
  default     = false
}

variable "enable_memory_metrics" {
  description = "Whether to enable memory metrics"
  type        = bool
  default     = true
}

variable "enable_disk_metrics" {
  description = "Whether to enable disk metrics"
  type        = bool
  default     = true
}

variable "alb_5xx_error_threshold" {
  description = "Threshold for ALB 5XX error alarm"
  type        = number
  default     = 5
}

variable "alb_4xx_error_threshold" {
  description = "Threshold for ALB 4XX error alarm"
  type        = number
  default     = 100
}

variable "alb_latency_threshold" {
  description = "Threshold for ALB latency alarm in seconds"
  type        = number
  default     = 1
}

variable "waf_blocked_requests_threshold" {
  description = "Threshold for WAF blocked requests alarm"
  type        = number
  default     = 10
}

variable "bastion_cpu_threshold" {
  description = "Threshold for bastion CPU utilization alarm"
  type        = number
  default     = 80
}

# Logs variables
variable "logs_transition_to_ia_days" {
  description = "Number of days before transitioning logs to IA storage class"
  type        = number
  default     = 30
}

variable "logs_transition_to_glacier_days" {
  description = "Number of days before transitioning logs to Glacier storage class"
  type        = number
  default     = 90
}

variable "logs_expiration_days" {
  description = "Number of days before logs expire"
  type        = number
  default     = 365
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 30
}

variable "high_log_volume_threshold" {
  description = "Threshold for high log volume alarm in bytes"
  type        = number
  default     = 5000000  # 5MB
}

# Flow Logs variables
variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch"
  type        = number
  default     = 30
}

variable "flow_logs_traffic_type" {
  description = "Type of traffic to log. Valid values: ACCEPT, REJECT, ALL"
  type        = string
  default     = "ALL"
}

variable "flow_logs_create_dashboard" {
  description = "Whether to create a CloudWatch dashboard for Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_create_alarms" {
  description = "Whether to create CloudWatch alarms for Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_rejected_traffic_threshold" {
  description = "Threshold for rejected traffic alarm"
  type        = number
  default     = 100
}

# Variables pour gérer les groupes de logs existants
variable "use_existing_flow_logs_group" {
  description = "Whether to use an existing CloudWatch Log Group for Flow Logs"
  type        = bool
  default     = false
}

variable "existing_flow_logs_group_name" {
  description = "Name of the existing CloudWatch Log Group to use for Flow Logs"
  type        = string
  default     = ""
}