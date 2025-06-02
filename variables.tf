# AWS Provider
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

# General settings
variable "tag" {
  description = "Tag to prefix resource names"
  type        = string
  default     = "dev"
}

variable "environment" {
  description = "Environment name (Development or Production)"
  type        = string
  default     = "Development"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ALB-WAF-Demo"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# VPC settings
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
  description = "Whether to create NAT gateways for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway for all private subnets"
  type        = bool
  default     = true
}

# Security settings
variable "bastion_allowed_ips" {
  description = "List of IP addresses allowed to connect to the bastion host"
  type        = list(string)
  default     = []
  sensitive   = true
}

# ALB settings
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "dev-alb"
}

variable "enable_https" {
  description = "Whether to enable HTTPS on the ALB"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "Name of the S3 bucket for ALB access logs"
  type        = string
  default     = ""
}

# WAF settings
variable "waf_blocked_ips" {
  description = "List of IP addresses to block at the WAF level"
  type        = list(string)
  default     = []
  sensitive   = true
}

variable "enable_waf_core_rule_set" {
  description = "Whether to enable the WAF core rule set"
  type        = bool
  default     = true
}

variable "enable_waf_sql_injection_protection" {
  description = "Whether to enable SQL injection protection in WAF"
  type        = bool
  default     = true
}

variable "enable_waf_rate_limiting" {
  description = "Whether to enable rate limiting in WAF"
  type        = bool
  default     = true
}

variable "enable_geo_restriction" {
  description = "Whether to enable geographic restrictions in WAF"
  type        = bool
  default     = true
}

variable "allowed_country_codes" {
  description = "List of country codes allowed to access the application"
  type        = list(string)
  default     = ["FR"]
}

# EC2 settings
variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = "key-mgnt-dev"
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
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp2"
}

variable "web_associate_public_ip" {
  description = "Whether to associate public IP addresses with web server instances"
  type        = bool
  default     = false
}

variable "bastion_associate_public_ip" {
  description = "Whether to associate public IP addresses with bastion host"
  type        = bool
  default     = true
}

variable "ami_name_filter" {
  description = "Filter pattern to find the AMI for EC2 instances"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

# CloudWatch settings
variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
  default     = "Dev-ALB-WAF-EC2-Dashboard"
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  type        = string
  default     = ""
  sensitive   = true
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

variable "enable_ok_actions" {
  description = "Whether to enable OK actions for alarms"
  type        = bool
  default     = false
}

variable "enable_4xx_alarm" {
  description = "Whether to enable 4xx error alarms"
  type        = bool
  default     = true
}

variable "enable_latency_alarm" {
  description = "Whether to enable latency alarms"
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
  default     = false
}

variable "enable_disk_metrics" {
  description = "Whether to enable disk metrics"
  type        = bool
  default     = false
}

# Alarm thresholds
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

variable "alb_5xx_error_threshold" {
  description = "Threshold for ALB 5xx error alarm"
  type        = number
  default     = 5
}

variable "alb_4xx_error_threshold" {
  description = "Threshold for ALB 4xx error alarm"
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
  description = "Threshold for bastion host CPU utilization alarm"
  type        = number
  default     = 80
}

# Logs settings
variable "logs_transition_to_ia_days" {
  description = "Number of days after which to transition logs to IA storage"
  type        = number
  default     = 30
}

variable "logs_transition_to_glacier_days" {
  description = "Number of days after which to transition logs to Glacier storage"
  type        = number
  default     = 90
}

variable "logs_expiration_days" {
  description = "Number of days after which to expire logs"
  type        = number
  default     = 365
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "high_log_volume_threshold" {
  description = "Threshold for high log volume alarm in bytes"
  type        = number
  default     = 5000000
}

# Flow Logs settings
variable "enable_flow_logs" {
  description = "Whether to enable VPC flow logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 30
}

variable "flow_logs_traffic_type" {
  description = "Type of traffic to log (ACCEPT, REJECT, or ALL)"
  type        = string
  default     = "ALL"
}

variable "flow_logs_create_dashboard" {
  description = "Whether to create a dashboard for flow logs"
  type        = bool
  default     = true
}

variable "flow_logs_create_alarms" {
  description = "Whether to create alarms for flow logs"
  type        = bool
  default     = true
}

variable "flow_logs_rejected_traffic_threshold" {
  description = "Threshold for rejected traffic alarm"
  type        = number
  default     = 10
}