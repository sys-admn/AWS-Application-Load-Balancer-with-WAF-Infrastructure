output "dashboard_url" {
  description = "The URL of the CloudWatch dashboard"
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${var.dashboard_name}"
}

output "alb_5xx_alarm_arn" {
  description = "ARN of the ALB 5XX errors alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx_errors.arn
}

output "waf_blocked_requests_alarm_arn" {
  description = "ARN of the WAF blocked requests alarm"
  value       = aws_cloudwatch_metric_alarm.waf_blocked_requests.arn
}

output "waf_geo_blocked_requests_alarm_arn" {
  description = "ARN of the WAF geo-blocked requests alarm"
  value       = var.enable_geo_restriction ? aws_cloudwatch_metric_alarm.waf_geo_blocked_requests[0].arn : null
}