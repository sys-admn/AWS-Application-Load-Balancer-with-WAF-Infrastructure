resource "aws_lb" "web_alb" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [var.alb_sg_id]
  
  # Enable deletion protection in production
  enable_deletion_protection = var.enable_deletion_protection
  
  # Enable access logs if bucket is provided
  dynamic "access_logs" {
    for_each = var.access_logs_bucket != "" ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }
  
  # Improve security with HTTP/2 and drop invalid headers
  enable_http2             = true
  drop_invalid_header_fields = var.drop_invalid_header_fields
  
  # Idle timeout for connections
  idle_timeout = var.idle_timeout
  
  tags = merge(
    {
      Name = var.alb_name
    },
    var.tags
  )
}

resource "aws_lb_target_group" "web_tg" {
  name     = "${var.name_prefix}web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  # Health check configuration
  health_check {
    enabled             = true
    interval            = var.health_check_interval
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    matcher             = "200-299"
  }
  
  # Target group attributes
  stickiness {
    type            = "lb_cookie"
    cookie_duration = var.stickiness_enabled ? 86400 : 1
    enabled         = var.stickiness_enabled
  }
  
  # Deregistration delay
  deregistration_delay = var.deregistration_delay
  
  tags = merge(
    {
      Name = "${var.name_prefix}web-tg"
    },
    var.tags
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  # If HTTPS is enabled, redirect HTTP to HTTPS
  dynamic "default_action" {
    for_each = var.enable_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
  
  # If HTTPS is not enabled, forward to target group
  dynamic "default_action" {
    for_each = var.enable_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.web_tg.arn
    }
  }
}

# Create HTTPS listener if enabled
resource "aws_lb_listener" "https" {
  count = var.enable_https && var.certificate_arn != "" ? 1 : 0
  
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}