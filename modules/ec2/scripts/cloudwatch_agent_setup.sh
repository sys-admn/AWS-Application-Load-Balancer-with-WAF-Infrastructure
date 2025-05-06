#!/bin/bash

# Install CloudWatch Agent
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
rm ./amazon-cloudwatch-agent.deb

# Create CloudWatch Agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/syslog",
            "retention_in_days": ${retention_days}
          },
          {
            "file_path": "/var/log/apache2/access.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/apache-access",
            "retention_in_days": ${retention_days}
          },
          {
            "file_path": "/var/log/apache2/error.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/apache-error",
            "retention_in_days": ${retention_days}
          },
          {
            "file_path": "/var/log/system-health.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/system-health",
            "retention_in_days": ${retention_days}
          },
          {
            "file_path": "/var/log/server-setup.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/server-setup",
            "retention_in_days": ${retention_days}
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": true
      },
      "disk": {
        "measurement": [
          "used_percent",
          "inodes_free"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ]
      },
      "diskio": {
        "measurement": [
          "io_time"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_time_wait"
        ],
        "metrics_collection_interval": 60
      }
    },
    "append_dimensions": {
      "AutoScalingGroupName": "${!aws:AutoScalingGroupName}",
      "ImageId": "${!aws:ImageId}",
      "InstanceId": "${!aws:InstanceId}",
      "InstanceType": "${!aws:InstanceType}"
    },
    "aggregation_dimensions": [
      ["InstanceId"],
      ["AutoScalingGroupName"]
    ]
  }
}
EOF

# Start the CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Log the completion
echo "CloudWatch Agent setup completed at $(date)" >> /var/log/server-setup.log