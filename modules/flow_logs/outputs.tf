output "flow_logs_group_name" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs"
  value       = local.log_group_name
}

output "flow_logs_group_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs"
  value       = local.log_group_arn
}

output "flow_logs_role_arn" {
  description = "ARN of the IAM Role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs_role.arn
}

output "flow_logs_id" {
  description = "ID of the VPC Flow Log"
  value       = aws_flow_log.vpc_flow_logs.id
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard for Flow Logs"
  value       = var.create_dashboard ? "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.flow_logs_dashboard[0].dashboard_name}" : null
}