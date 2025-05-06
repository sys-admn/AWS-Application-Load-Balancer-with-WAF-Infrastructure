variable "name_prefix" {
  description = "Prefix to add to resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to enable flow logs for"
  type        = string
}

variable "retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch"
  type        = number
  default     = 30
}

variable "traffic_type" {
  description = "Type of traffic to log. Valid values: ACCEPT, REJECT, ALL"
  type        = string
  default     = "ALL"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "create_dashboard" {
  description = "Whether to create a CloudWatch dashboard for Flow Logs"
  type        = bool
  default     = true
}

variable "create_alarms" {
  description = "Whether to create CloudWatch alarms for Flow Logs"
  type        = bool
  default     = true
}

variable "rejected_traffic_threshold" {
  description = "Threshold for rejected traffic alarm"
  type        = number
  default     = 100
}

variable "alarm_actions" {
  description = "List of ARNs to notify when the rejected traffic alarm is triggered"
  type        = list(string)
  default     = []
}

variable "custom_log_format" {
  description = "Custom format for flow logs. Leave empty to use default format."
  type        = string
  default     = ""
}

variable "use_existing_log_group" {
  description = "Whether to use an existing CloudWatch Log Group"
  type        = bool
  default     = false
}

variable "existing_log_group_name" {
  description = "Name of the existing CloudWatch Log Group to use if use_existing_log_group is true"
  type        = string
  default     = ""
}