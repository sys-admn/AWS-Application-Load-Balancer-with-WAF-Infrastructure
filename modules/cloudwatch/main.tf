resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.dashboard_name
  dashboard_body = jsonencode({
    widgets = concat([
      # ALB Metrics Widget
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_name],
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_name],
            ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", var.alb_name],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_name, { "stat": "Average" }]
          ]
          view       = "timeSeries"
          stacked    = false
          region     = var.region
          title      = "ALB Metrics"
          period     = 300
          stat       = "Sum"
        }
      },
      
      # WAF Metrics Widget
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = concat(
            [
              ["AWS/WAFV2", "AllowedRequests", "WebACL", var.waf_name],
              ["AWS/WAFV2", "BlockedRequests", "WebACL", var.waf_name],
              ["AWS/WAFV2", "CountedRequests", "WebACL", var.waf_name]
            ],
            var.enable_geo_restriction ? [["AWS/WAFV2", "BlockedRequests", "WebACL", var.waf_name, "Rule", "geo-block-non-allowed-countries"]] : []
          )
          view       = "timeSeries"
          stacked    = false
          region     = var.region
          title      = "WAF Metrics"
          period     = 300
          stat       = "Sum"
        }
      },
      
      # EC2 CPU Utilization Widget
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = concat(
            [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name, { "stat": "Average" }]],
            [for id in var.instance_ids : ["AWS/EC2", "CPUUtilization", "InstanceId", id]]
          )
          view       = "timeSeries"
          stacked    = false
          region     = var.region
          title      = "EC2 CPU Utilization"
          period     = 300
        }
      },
      
      # EC2 Network Metrics Widget
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = concat(
            [for id in var.instance_ids : ["AWS/EC2", "NetworkIn", "InstanceId", id]],
            [for id in var.instance_ids : ["AWS/EC2", "NetworkOut", "InstanceId", id]]
          )
          view       = "timeSeries"
          stacked    = false
          region     = var.region
          title      = "EC2 Network Traffic"
          period     = 300
        }
      },
      
      # ALB Target Group Health Widget
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.target_group_arn, "LoadBalancer", var.alb_name],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", var.target_group_arn, "LoadBalancer", var.alb_name]
          ]
          view       = "timeSeries"
          stacked    = false
          region     = var.region
          title      = "Target Group Health"
          period     = 60
        }
      },
      
      # ALB Request Count by Target Widget
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCountPerTarget", "TargetGroup", var.target_group_arn, "LoadBalancer", var.alb_name]
          ]
          view       = "timeSeries"
          stacked    = false
          region     = var.region
          title      = "Request Count Per Target"
          period     = 60
          stat       = "Sum"
        }
      }
    ],
    # Conditionally add memory metrics widget
    var.enable_memory_metrics ? [{
      type   = "metric"
      x      = 0
      y      = 18
      width  = 12
      height = 6
      properties = {
        metrics = [for id in var.instance_ids : ["CWAgent", "mem_used_percent", "InstanceId", id]]
        view       = "timeSeries"
        stacked    = false
        region     = var.region
        title      = "EC2 Memory Utilization"
        period     = 300
      }
    }] : [],
    
    # Conditionally add disk metrics widget
    var.enable_disk_metrics ? [{
      type   = "metric"
      x      = 12
      y      = 18
      width  = 12
      height = 6
      properties = {
        metrics = [for id in var.instance_ids : ["CWAgent", "disk_used_percent", "InstanceId", id, "device", "xvda1", "fstype", "ext4", "path", "/"]]
        view       = "timeSeries"
        stacked    = false
        region     = var.region
        title      = "EC2 Disk Utilization"
        period     = 300
      }
    }] : [])
  })
}

# ALB Alarms
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.name_prefix}${var.alb_name}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.alb_5xx_error_threshold
  alarm_description   = "This alarm monitors ALB 5XX errors"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = var.enable_ok_actions ? [var.sns_topic_arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = var.alb_name
  }
  
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_4xx_errors" {
  count               = var.enable_4xx_alarm ? 1 : 0
  
  alarm_name          = "${var.name_prefix}${var.alb_name}-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.alb_4xx_error_threshold
  alarm_description   = "This alarm monitors ALB 4XX errors"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = var.enable_ok_actions ? [var.sns_topic_arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = var.alb_name
  }
  
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  count               = var.enable_latency_alarm ? 1 : 0
  
  alarm_name          = "${var.name_prefix}${var.alb_name}-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.alb_latency_threshold
  alarm_description   = "This alarm monitors ALB target response time"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = var.enable_ok_actions ? [var.sns_topic_arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = var.alb_name
  }
  
  tags = var.tags
}

# WAF Alarms
resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests" {
  alarm_name          = "${var.name_prefix}${var.waf_name}-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.waf_blocked_requests_threshold
  alarm_description   = "This alarm monitors WAF blocked requests"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = var.enable_ok_actions ? [var.sns_topic_arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    WebACL = var.waf_name
  }
  
  tags = var.tags
}

# WAF Geo-restriction Alarm
resource "aws_cloudwatch_metric_alarm" "waf_geo_blocked_requests" {
  count               = var.enable_geo_restriction ? 1 : 0
  
  alarm_name          = "${var.name_prefix}${var.waf_name}-geo-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.waf_blocked_requests_threshold
  alarm_description   = "This alarm monitors WAF geo-blocked requests"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = var.enable_ok_actions ? [var.sns_topic_arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    WebACL = var.waf_name
    Rule   = "geo-block-non-allowed-countries"
  }
  
  tags = var.tags
}

# EC2 Auto Scaling Group Alarms
resource "aws_cloudwatch_metric_alarm" "asg_cpu_high" {
  alarm_name          = "${var.name_prefix}asg-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.cpu_high_threshold
  alarm_description   = "This alarm monitors high CPU utilization across the Auto Scaling Group"
  alarm_actions       = concat([var.sns_topic_arn], var.asg_scale_up_policy_arn != "" ? [var.asg_scale_up_policy_arn] : [])
  ok_actions          = var.enable_ok_actions ? [var.sns_topic_arn] : []
  treat_missing_data  = "missing"
  
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
  
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_low" {
  alarm_name          = "${var.name_prefix}asg-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.cpu_low_threshold
  alarm_description   = "This alarm monitors low CPU utilization across the Auto Scaling Group"
  alarm_actions       = concat([var.sns_topic_arn], var.asg_scale_down_policy_arn != "" ? [var.asg_scale_down_policy_arn] : [])
  ok_actions          = var.enable_ok_actions ? [var.sns_topic_arn] : []
  treat_missing_data  = "missing"
  
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
  
  tags = var.tags
}

# Individual EC2 Instance Alarms
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  for_each = var.enable_per_instance_alarms ? toset(var.instance_ids) : []

  alarm_name          = "${var.name_prefix}${each.value}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.cpu_high_threshold
  alarm_description   = "This alarm monitors high CPU utilization for instance ${each.value}"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = var.enable_ok_actions ? [var.sns_topic_arn] : []
  treat_missing_data  = "missing"
  
  dimensions = {
    InstanceId = each.value
  }
  
  tags = var.tags
}

# Bastion Host Alarms
resource "aws_cloudwatch_metric_alarm" "bastion_cpu_high" {
  count               = var.enable_bastion_monitoring ? 1 : 0
  
  alarm_name          = "${var.name_prefix}bastion-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.bastion_cpu_threshold
  alarm_description   = "This alarm monitors high CPU utilization for the bastion host"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = var.enable_ok_actions ? [var.sns_topic_arn] : []
  treat_missing_data  = "missing"
  
  dimensions = {
    InstanceId = var.bastion_instance_id
  }
  
  tags = var.tags
}

# Create a composite alarm that triggers when multiple conditions are met
resource "aws_cloudwatch_composite_alarm" "critical_system_alarm" {
  count = var.enable_composite_alarm ? 1 : 0
  
  alarm_name        = "${var.name_prefix}critical-system-alarm"
  alarm_description = "Composite alarm that triggers when multiple critical conditions are met"
  
  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.alb_5xx_errors.alarm_name}) OR (ALARM(${aws_cloudwatch_metric_alarm.asg_cpu_high.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.waf_blocked_requests.alarm_name}))"
  
  alarm_actions = [var.sns_topic_arn]
  ok_actions    = var.enable_ok_actions ? [var.sns_topic_arn] : []
  
  tags = var.tags
}