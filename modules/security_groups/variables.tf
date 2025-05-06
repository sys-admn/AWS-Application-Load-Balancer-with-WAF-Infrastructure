variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to all resource names"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Environment = "Development"
  }
}

variable "alb_ingress_rules" {
  description = "List of ingress rules for the ALB security group"
  type        = list(object({
    description      = string
    port             = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = optional(list(string))
  }))
  default = [
    {
      description = "HTTP from anywhere"
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS from anywhere"
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "web_ingress_rules" {
  description = "Additional ingress rules for the web servers security group (beyond ALB and bastion access)"
  type        = list(object({
    description     = string
    port            = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}

variable "bastion_allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # WARNING: This default is insecure and should be overridden
  
  validation {
    condition     = length([for cidr in var.bastion_allowed_cidr_blocks : cidr if cidr == "0.0.0.0/0"]) == 0
    error_message = "For security reasons, '0.0.0.0/0' should not be used for bastion access. Please specify your actual IP address or range."
  }
}