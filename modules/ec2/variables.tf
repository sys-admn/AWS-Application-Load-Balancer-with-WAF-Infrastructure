variable "private_subnets" {
  description = "List of IDs of private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of IDs of public subnets"
  type        = list(string)
  default     = []
}

variable "web_sg_id" {
  description = "The ID of the web security group"
  type        = string
}

variable "bastion_sg_id" {
  description = "The ID of the bastion security group"
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the target group"
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

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
}

variable "ami_name_filter" {
  description = "Filter pattern for the AMI name"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
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

variable "bastion_volume_size" {
  description = "Size of the bastion host root volume in GB"
  type        = number
  default     = 8
}

variable "bastion_volume_type" {
  description = "Type of the bastion host root volume"
  type        = string
  default     = "gp2"
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

variable "bastion_subnet_id" {
  description = "Specific subnet ID for the bastion host (if empty, first private subnet will be used)"
  type        = string
  default     = ""
}

variable "user_data_file" {
  description = "Path to a custom user data script file (if empty, default script will be used)"
  type        = string
  default     = ""
}

variable "imds_require_imdsv2" {
  description = "Whether to require IMDSv2 for instance metadata service"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for EC2 instances"
  type        = string
  default     = ""
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 30
}