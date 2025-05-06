output "alb_sg_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "web_sg_id" {
  description = "The ID of the web servers security group"
  value       = aws_security_group.web_sg.id
}

output "bastion_sg_id" {
  description = "The ID of the bastion host security group"
  value       = aws_security_group.bastion_sg.id
}

output "alb_sg_arn" {
  description = "The ARN of the ALB security group"
  value       = aws_security_group.alb_sg.arn
}

output "web_sg_arn" {
  description = "The ARN of the web servers security group"
  value       = aws_security_group.web_sg.arn
}

output "bastion_sg_arn" {
  description = "The ARN of the bastion host security group"
  value       = aws_security_group.bastion_sg.arn
}