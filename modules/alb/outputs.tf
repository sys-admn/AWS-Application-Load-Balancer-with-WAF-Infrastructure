output "alb_name" {
  description = "The name of the ALB"
  value       = aws_lb.web_alb.name
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.web_alb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.web_alb.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the ALB"
  value       = aws_lb.web_alb.zone_id
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.web_tg.arn
}

output "target_group_name" {
  description = "The name of the target group"
  value       = aws_lb_target_group.web_tg.name
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener (if enabled)"
  value       = var.enable_https && var.certificate_arn != "" ? aws_lb_listener.https[0].arn : null
}