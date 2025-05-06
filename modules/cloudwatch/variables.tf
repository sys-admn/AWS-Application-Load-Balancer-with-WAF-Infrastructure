variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
}

variable "waf_name" {
  description = "Name of the WAF"
  type        = string
}

variable "instance_ids" {
  description = "List of EC2 instance IDs"
  type        = list(string)
}

variable "bastion_instance_id" {
  description = "ID of the bastion host"
  type        = string
  default     = ""
}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = ""
}

variable "asg_scale_up_policy_arn" {
  description = "ARN of the Auto Scaling Group scale up policy"
  type        = string
  default     = ""
}

variable "asg_scale_down_policy_arn" {
  description = "ARN of the Auto Scaling Group scale down policy"
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

variable "enable_ok_actions" {
  description = "Whether to send notifications when alarms return to OK state"
  type        = bool
  default     = false
}

variable "enable_4xx_alarm" {
  description = "Whether to enable alarm for ALB 4XX errors"
  type        = bool
  default     = true
}

variable "enable_latency_alarm" {
  description = "Whether to enable alarm for ALB latency"
  type        = bool
  default     = true
}

variable "enable_per_instance_alarms" {
  description = "Whether to enable alarms for individual EC2 instances"
  type        = bool
  default     = false
}

variable "enable_bastion_monitoring" {
  description = "Whether to enable monitoring for the bastion host"
  type        = bool
  default     = true
}

variable "enable_composite_alarm" {
  description = "Whether to enable composite alarm"
  type        = bool
  default     = false
}

variable "enable_memory_metrics" {
  description = "Whether to include memory metrics in the dashboard (requires CloudWatch agent)"
  type        = bool
  default     = true
}

variable "enable_disk_metrics" {
  description = "Whether to include disk metrics in the dashboard (requires CloudWatch agent)"
  type        = bool
  default     = true
}

# Alarm threshold variables
variable "cpu_high_threshold" {
  description = "CPU utilization threshold for scaling up"
  type        = number
  default     = 80
}

variable "cpu_low_threshold" {
  description = "CPU utilization threshold for scaling down"
  type        = number
  default     = 20
}

variable "alb_5xx_error_threshold" {
  description = "Threshold for ALB 5XX errors"
  type        = number
  default     = 5
}

variable "alb_4xx_error_threshold" {
  description = "Threshold for ALB 4XX errors"
  type        = number
  default     = 100
}

variable "alb_latency_threshold" {
  description = "Threshold for ALB latency in seconds"
  type        = number
  default     = 1
}

variable "waf_blocked_requests_threshold" {
  description = "Threshold for WAF blocked requests"
  type        = number
  default     = 10
}

variable "bastion_cpu_threshold" {
  description = "Threshold for bastion host CPU utilization"
  type        = number
  default     = 80
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# Geo-restriction variable
variable "enable_geo_restriction" {
  description = "Whether geographic restrictions are enabled"
  type        = bool
  default     = false
}

# CloudWatch Log Group variables
variable "ec2_log_group_name" {
  description = "Name of the CloudWatch Log Group for EC2 instances"
  type        = string
  default     = ""
}

variable "waf_log_group_name" {
  description = "Name of the CloudWatch Log Group for WAF"
  type        = string
  default     = ""
}