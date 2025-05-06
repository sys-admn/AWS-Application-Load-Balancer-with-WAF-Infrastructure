variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tag" {
  description = "Tag prefix to use for resources"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "Development"
  }
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets to create (if 0, will use public_subnet_count)"
  type        = number
  default     = 0
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

variable "nat_gateway_subnet_index" {
  description = "Index of the public subnet to place the NAT Gateway in (when using single NAT Gateway)"
  type        = number
  default     = 0
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateway(s)"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to create a single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}