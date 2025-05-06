
# Flow Logs outputs
output "flow_logs_group_name" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_logs ? module.flow_logs[0].flow_logs_group_name : null
}

output "flow_logs_dashboard_url" {
  description = "URL of the CloudWatch dashboard for Flow Logs"
  value       = var.enable_flow_logs && var.flow_logs_create_dashboard ? module.flow_logs[0].dashboard_url : null
}

# ALB outputs
output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the ALB"
  value       = module.alb.alb_zone_id
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = module.alb.alb_arn
}

# WAF outputs
output "waf_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = module.waf.waf_arn
}

output "autoscaling_group_name" {
  description = "Name of the auto scaling group"
  value       = module.ec2.autoscaling_group_name
}

# CloudWatch outputs
output "dashboard_url" {
  description = "The URL of the CloudWatch dashboard"
  value       = module.cloudwatch.dashboard_url
}

# Logs outputs
output "logs_bucket_id" {
  description = "ID of the S3 bucket for logs"
  value       = module.logs.logs_bucket_id
}

output "logs_dashboard_url" {
  description = "URL of the CloudWatch dashboard for logs"
  value       = module.logs.logs_dashboard_url
}

output "ec2_log_group_name" {
  description = "Name of the CloudWatch Log Group for EC2 instances"
  value       = module.logs.ec2_log_group_name
}

output "waf_log_group_name" {
  description = "Name of the CloudWatch Log Group for WAF"
  value       = module.logs.waf_log_group_name
}

# Connection information
output "ssh_to_bastion" {
  description = "Command to SSH to the bastion host"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${module.ec2.bastion_public_ip}"
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.alb.alb_dns_name}"
}