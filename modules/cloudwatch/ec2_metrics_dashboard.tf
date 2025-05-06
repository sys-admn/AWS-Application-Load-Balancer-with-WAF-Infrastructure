# CloudWatch Dashboard for EC2 metrics from CloudWatch agent
resource "aws_cloudwatch_dashboard" "ec2_metrics_dashboard" {
  dashboard_name = "${var.name_prefix}ec2-metrics-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["CWAgent", "cpu_usage_idle", "InstanceId", "*", { "stat": "Average", "period": 300 }],
            ["CWAgent", "cpu_usage_user", "InstanceId", "*", { "stat": "Average", "period": 300 }],
            ["CWAgent", "cpu_usage_system", "InstanceId", "*", { "stat": "Average", "period": 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.region
          title   = "CPU Usage by Instance"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["CWAgent", "mem_used_percent", "InstanceId", "*", { "stat": "Average", "period": 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.region
          title   = "Memory Usage by Instance"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["CWAgent", "disk_used_percent", "InstanceId", "*", "path", "/", "device", "xvda1", "fstype", "ext4", { "stat": "Average", "period": 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.region
          title   = "Disk Usage by Instance"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["CWAgent", "netstat_tcp_established", "InstanceId", "*", { "stat": "Average", "period": 300 }],
            ["CWAgent", "netstat_tcp_time_wait", "InstanceId", "*", { "stat": "Average", "period": 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.region
          title   = "Network Connections by Instance"
          period  = 300
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6
        properties = {
          query   = "SOURCE '${var.name_prefix}ec2-logs' | fields @timestamp, @message\n| sort @timestamp desc\n| limit 20"
          region  = var.region
          title   = "EC2 Instance Logs"
          view    = "table"
        }
      }
    ]
  })
}