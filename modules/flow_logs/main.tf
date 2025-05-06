# Utiliser un groupe de logs existant si spécifié
data "aws_cloudwatch_log_group" "existing_flow_logs" {
  count = var.use_existing_log_group ? 1 : 0
  name  = var.existing_log_group_name != "" ? var.existing_log_group_name : "/aws/vpc/${var.name_prefix}-flow-logs"
}

# CloudWatch Log Group pour les VPC Flow Logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.use_existing_log_group ? 0 : 1
  name              = "/aws/vpc/${var.name_prefix}-flow-logs"
  retention_in_days = var.retention_days

  tags = merge(
    {
      Name = "${var.name_prefix}-vpc-flow-logs"
    },
    var.tags
  )
}

# Utiliser le bon ARN selon que le groupe existe ou non
locals {
  log_group_arn = var.use_existing_log_group ? data.aws_cloudwatch_log_group.existing_flow_logs[0].arn : aws_cloudwatch_log_group.flow_logs[0].arn
  log_group_name = var.use_existing_log_group ? data.aws_cloudwatch_log_group.existing_flow_logs[0].name : aws_cloudwatch_log_group.flow_logs[0].name
}

# IAM Role pour les VPC Flow Logs
resource "aws_iam_role" "flow_logs_role" {
  name = "${var.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy pour les VPC Flow Logs
resource "aws_iam_policy" "flow_logs_policy" {
  name        = "${var.name_prefix}-vpc-flow-logs-policy"
  description = "Policy for VPC Flow Logs to write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "${local.log_group_arn}:*"
      }
    ]
  })
}

# Attacher la policy au rôle
resource "aws_iam_role_policy_attachment" "flow_logs_attachment" {
  role       = aws_iam_role.flow_logs_role.name
  policy_arn = aws_iam_policy.flow_logs_policy.arn
}

# VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.flow_logs_role.arn
  log_destination = local.log_group_arn
  traffic_type    = var.traffic_type
  vpc_id          = var.vpc_id
  log_format      = var.custom_log_format != "" ? var.custom_log_format : null

  tags = merge(
    {
      Name = "${var.name_prefix}-vpc-flow-logs"
    },
    var.tags
  )
}

# CloudWatch Dashboard pour visualiser les Flow Logs
resource "aws_cloudwatch_dashboard" "flow_logs_dashboard" {
  count = var.create_dashboard ? 1 : 0
  
  dashboard_name = "${var.name_prefix}-flow-logs-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "log"
        x      = 0
        y      = 0
        width  = 24
        height = 6
        properties = {
          query   = "SOURCE '${local.log_group_name}' | fields @timestamp, srcAddr, dstAddr, srcPort, dstPort, protocol, action, bytes | sort @timestamp desc | limit 20"
          region  = var.region
          title   = "VPC Flow Logs - Recent Traffic"
          view    = "table"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          query   = "SOURCE '${local.log_group_name}' | stats sum(bytes) as totalBytes by srcAddr, dstAddr | sort totalBytes desc | limit 10"
          region  = var.region
          title   = "Top Traffic by IP Pair"
          view    = "table"
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          query   = "SOURCE '${local.log_group_name}' | filter action = \"REJECT\" | stats count(*) as rejectCount by srcAddr | sort rejectCount desc | limit 10"
          region  = var.region
          title   = "Top Rejected Traffic Sources"
          view    = "table"
        }
      }
    ]
  })
}

# CloudWatch Metric Alarm pour les rejets de trafic anormaux
resource "aws_cloudwatch_metric_alarm" "rejected_traffic_alarm" {
  count = var.create_alarms ? 1 : 0
  
  alarm_name          = "${var.name_prefix}-vpc-rejected-traffic-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RejectedPackets"
  namespace           = "AWS/VPC/FlowLogs"
  period              = 300
  statistic           = "Sum"
  threshold           = var.rejected_traffic_threshold
  alarm_description   = "This alarm monitors rejected traffic in the VPC"
  alarm_actions       = var.alarm_actions
  
  dimensions = {
    VpcId = var.vpc_id
  }
  
  tags = var.tags
}