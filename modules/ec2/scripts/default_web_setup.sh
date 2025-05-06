#!/bin/bash

# Update system packages
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install Apache and basic utilities
DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 curl unzip jq htop awscli

# Configure Apache
echo "<html>
<head>
    <title>Welcome to Our Web Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: #333;
            text-align: center;
        }
        .container {
            width: 80%;
            margin: 0 auto;
            padding: 2rem;
        }
        h1 {
            color: #0066cc;
        }
        .server-info {
            background-color: #fff;
            border-radius: 8px;
            padding: 1rem;
            margin-top: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .footer {
            margin-top: 2rem;
            font-size: 0.8rem;
            color: #666;
        }
    </style>
</head>
<body>
    <div class='container'>
        <h1>Hello from $(hostname)</h1>
        <div class='server-info'>
            <h2>Server Information</h2>
            <p><strong>Hostname:</strong> $(hostname)</p>
            <p><strong>IP Address:</strong> $(hostname -I | awk '{print $1}')</p>
            <p><strong>Date:</strong> $(date)</p>
            <p><strong>Uptime:</strong> $(uptime)</p>
        </div>
        <div class='footer'>
            <p>Powered by Apache on Ubuntu</p>
        </div>
    </div>
</body>
</html>" > /var/www/html/index.html

# Enable and start Apache
systemctl enable apache2
systemctl start apache2

# Basic security hardening
# Disable root SSH login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
# Disable password authentication
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# Restart SSH service
systemctl restart sshd

# Setup basic monitoring
cat > /etc/cron.hourly/system-health-check << 'EOF'
#!/bin/bash
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEMORY_USAGE=$(free -m | awk '/Mem:/ {print $3}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')

echo "$TIMESTAMP - CPU: $CPU_USAGE%, Memory: $MEMORY_USAGE MB, Disk: $DISK_USAGE" >> /var/log/system-health.log
EOF

chmod +x /etc/cron.hourly/system-health-check

# Install CloudWatch Agent
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
rm ./amazon-cloudwatch-agent.deb

# Get instance metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)

# Create CloudWatch Agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
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
            "log_group_name": "LOG_GROUP_NAME_PLACEHOLDER",
            "log_stream_name": "$INSTANCE_ID/syslog",
            "retention_in_days": RETENTION_DAYS_PLACEHOLDER
          },
          {
            "file_path": "/var/log/apache2/access.log",
            "log_group_name": "LOG_GROUP_NAME_PLACEHOLDER",
            "log_stream_name": "$INSTANCE_ID/apache-access",
            "retention_in_days": RETENTION_DAYS_PLACEHOLDER
          },
          {
            "file_path": "/var/log/apache2/error.log",
            "log_group_name": "LOG_GROUP_NAME_PLACEHOLDER",
            "log_stream_name": "$INSTANCE_ID/apache-error",
            "retention_in_days": RETENTION_DAYS_PLACEHOLDER
          },
          {
            "file_path": "/var/log/system-health.log",
            "log_group_name": "LOG_GROUP_NAME_PLACEHOLDER",
            "log_stream_name": "$INSTANCE_ID/system-health",
            "retention_in_days": RETENTION_DAYS_PLACEHOLDER
          },
          {
            "file_path": "/var/log/server-setup.log",
            "log_group_name": "LOG_GROUP_NAME_PLACEHOLDER",
            "log_stream_name": "$INSTANCE_ID/server-setup",
            "retention_in_days": RETENTION_DAYS_PLACEHOLDER
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
      "InstanceId": "\${aws:InstanceId}",
      "InstanceType": "\${aws:InstanceType}"
    },
    "aggregation_dimensions": [
      ["InstanceId"]
    ]
  }
}
EOF

# Start the CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Log the completion
echo "Server setup completed at $(date)" >> /var/log/server-setup.log