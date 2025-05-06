variable "alb_arn" {
  description = "ARN of the ALB to associate with the WAF"
  type        = string
}

variable "waf_name" {
  description = "Name of the WAF Web ACL"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = ""
}

variable "ip_addresses" {
  description = "List of IP addresses to block"
  type        = list(string)
  default     = []
}

variable "enable_core_rule_set" {
  description = "Whether to enable AWS Core Rule Set"
  type        = bool
  default     = true
}

variable "enable_sql_injection_protection" {
  description = "Whether to enable SQL injection protection"
  type        = bool
  default     = true
}

variable "enable_rate_limiting" {
  description = "Whether to enable rate limiting"
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Maximum number of requests allowed in a 5-minute period"
  type        = number
  default     = 2000
}

variable "custom_rules" {
  description = "List of custom rules to add to the WAF"
  type        = any
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# Geo-restriction variables
variable "enable_geo_restriction" {
  description = "Whether to enable geographic restrictions"
  type        = bool
  default     = false
}

variable "allowed_country_codes" {
  description = "List of allowed country codes in ISO 3166-1 alpha-2 format"
  type        = list(string)
  default     = ["FR"]  # France par défaut
}