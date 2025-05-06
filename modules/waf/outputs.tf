output "waf_id" {
  description = "The ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.alb_waf.id
}

output "waf_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.alb_waf.arn
}

output "waf_name" {
  description = "The name of the WAF Web ACL"
  value       = aws_wafv2_web_acl.alb_waf.name
}

output "waf_capacity" {
  description = "The capacity of the WAF Web ACL"
  value       = aws_wafv2_web_acl.alb_waf.capacity
}

output "ip_set_id" {
  description = "The ID of the IP set"
  value       = aws_wafv2_ip_set.blocked_ips.id
}

output "ip_set_arn" {
  description = "The ARN of the IP set"
  value       = aws_wafv2_ip_set.blocked_ips.arn
}