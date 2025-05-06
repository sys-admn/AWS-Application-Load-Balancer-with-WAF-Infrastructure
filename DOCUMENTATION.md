# AWS Application Load Balancer with WAF Infrastructure - Technical Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Components](#components)
4. [Security Features](#security-features)
5. [Monitoring and Logging](#monitoring-and-logging)
6. [Deployment Instructions](#deployment-instructions)
7. [Environment Configuration](#environment-configuration)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)
10. [Maintenance](#maintenance)
11. [Testing and Simulation](#testing-and-simulation)

## Project Overview

This project implements a secure, scalable, and monitored web application infrastructure on AWS using Terraform. The infrastructure includes an Application Load Balancer (ALB) protected by AWS WAF, auto-scaling EC2 instances, comprehensive logging, and monitoring capabilities.

### Key Features

- **Multi-AZ Architecture**: Deployed across multiple availability zones for high availability
- **Security-First Design**: WAF protection, security groups, and private subnets for application servers
- **Auto-Scaling**: Dynamic scaling based on load metrics
- **Comprehensive Monitoring**: CloudWatch dashboards, alarms, and metrics
- **Centralized Logging**: Log collection from all components with retention policies
- **Network Traffic Analysis**: VPC Flow Logs for security and troubleshooting
- **Environment Separation**: Development and production environment configurations

## Architecture

![Architecture Diagram](/assets/png/Development%20eu-west-3.png)

The infrastructure consists of four main layers:

### 1. VPC Layer
- VPC with public and private subnets across multiple AZs
- NAT Gateway for outbound internet access from private subnets
- Internet Gateway for inbound/outbound access in public subnets
- VPC Flow Logs for network traffic monitoring

### 2. Security Layer
- WAF to protect against common web exploits
- Security groups for fine-grained access control
- Bastion host for secure SSH access to instances
- Geographic restrictions for traffic filtering

### 3. Application Layer
- ALB to distribute traffic to web servers
- Auto Scaling Group to maintain application availability
- EC2 instances running web servers in private subnets

### 4. Monitoring & Logging Layer
- CloudWatch dashboards for infrastructure visibility
- CloudWatch alarms for automated notifications
- SNS topics for alert delivery
- Centralized logging to S3 with lifecycle policies
- CloudWatch agent for EC2 instance monitoring

## Components

### VPC and Networking
- **VPC**: CIDR block 10.0.0.0/16
- **Subnets**: Public and private subnets across multiple AZs
- **NAT Gateway**: For outbound internet access from private subnets
- **Internet Gateway**: For public subnet internet access
- **Route Tables**: Separate tables for public and private subnets
- **VPC Flow Logs**: For network traffic analysis and security monitoring

### Security
- **WAF**: Protects ALB from common web vulnerabilities
  - Core rule set enabled
  - SQL injection protection
  - Rate limiting
  - Geographic restrictions
  - IP-based blocking
- **Security Groups**: Least privilege access control
  - ALB security group: Allows HTTP/HTTPS from internet
  - Web server security group: Allows traffic only from ALB
  - Bastion security group: Allows SSH from specific IPs
- **IAM Roles**: Least privilege permissions for services

### Load Balancing
- **Application Load Balancer**: Distributes traffic to web servers
  - HTTP/HTTPS listeners
  - Target groups for EC2 instances
  - Health checks
  - Access logging to S3

### Compute
- **Auto Scaling Group**: Manages EC2 instances
  - Minimum, maximum, and desired capacity
  - Scaling policies based on CPU utilization
  - Health checks
- **EC2 Instances**: Web servers in private subnets
  - Ubuntu 20.04 LTS
  - Apache web server
  - CloudWatch agent for monitoring and logging
- **Bastion Host**: For secure SSH access to private instances

### Monitoring
- **CloudWatch Dashboards**: Visualize metrics
  - ALB metrics
  - EC2 metrics
  - WAF metrics
  - VPC Flow Logs metrics
- **CloudWatch Alarms**: Alert on threshold breaches
  - High CPU utilization
  - ALB 5XX errors
  - WAF blocked requests
  - Abnormal log volume
- **CloudWatch Agent**: Collects metrics and logs from EC2 instances
  - System metrics (CPU, memory, disk)
  - Application logs (Apache)
  - System logs (syslog)

### Logging
- **S3 Buckets**: Long-term log storage
  - ALB access logs
  - WAF logs
  - Lifecycle policies for cost optimization
- **CloudWatch Logs**: Real-time log analysis
  - EC2 instance logs
  - VPC Flow Logs
  - WAF logs
- **Kinesis Firehose**: For WAF log delivery to S3

## Security Features

### WAF Protection
The WAF is configured with multiple protection layers:

1. **AWS Managed Rules**:
   - Core Rule Set (CRS): Protects against common vulnerabilities
   - SQL Injection Protection: Blocks SQL injection attempts

2. **Custom Rules**:
   - Rate Limiting: Prevents DDoS attacks by limiting request rates
   - IP Blocking: Blocks specified IP addresses
   - Geo-Restriction: Limits access to specific countries (e.g., France only)

3. **Logging and Monitoring**:
   - All WAF events are logged to CloudWatch Logs
   - Alarms trigger on suspicious activity

### Network Security
- **Private Subnets**: Web servers are in private subnets with no direct internet access
- **Security Groups**: Restrict traffic between components
- **Bastion Host**: Single entry point for SSH access
- **VPC Flow Logs**: Monitor and analyze network traffic

### Data Protection
- **Encryption**: S3 buckets use server-side encryption
- **Access Control**: IAM policies restrict access to resources
- **Log Retention**: Configurable retention periods for logs

## Monitoring and Logging

### CloudWatch Agent
The CloudWatch agent is installed on all EC2 instances to collect:

1. **System Metrics**:
   - CPU utilization
   - Memory usage
   - Disk space
   - Network traffic

2. **Application Logs**:
   - Apache access logs
   - Apache error logs
   - System health logs

3. **System Logs**:
   - Syslog
   - Server setup logs

### CloudWatch Dashboards
Multiple dashboards provide visibility into:

1. **ALB Dashboard**:
   - Request count
   - Latency
   - Error rates
   - HTTP status codes

2. **EC2 Dashboard**:
   - CPU utilization
   - Memory usage
   - Disk usage
   - Network connections

3. **WAF Dashboard**:
   - Blocked requests
   - Allowed requests
   - Top attackers
   - Rule matches

4. **Flow Logs Dashboard**:
   - Network traffic patterns
   - Rejected connections
   - Traffic by IP pair

### Alarms and Notifications
Alarms are configured for:

1. **Performance Issues**:
   - High CPU utilization
   - High memory usage
   - High latency

2. **Error Conditions**:
   - ALB 5XX errors
   - ALB 4XX errors
   - Failed health checks

3. **Security Events**:
   - WAF blocked requests
   - Abnormal traffic patterns
   - Rejected network traffic

Notifications are sent to SNS topics for alerting.

### Log Management
Logs are managed with:

1. **Lifecycle Policies**:
   - Transition to IA storage after 30 days
   - Transition to Glacier after 90 days
   - Expiration after 365 days (configurable)

2. **Log Analysis**:
   - CloudWatch Logs Insights for querying
   - Custom dashboards for visualization

## Deployment Instructions

### Prerequisites
- Terraform v1.8+
- AWS CLI configured with appropriate credentials
- SSH key pair for EC2 instance access

### Deployment Steps

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Select Environment Workspace**:
   ```bash
   # For development
   terraform workspace new dev
   terraform workspace select dev
   
   # For production
   terraform workspace new prod
   terraform workspace select prod
   ```

3. **Plan Deployment**:
   ```bash
   # For development
   terraform plan -var-file="dev.tfvars"
   
   # For production
   terraform plan -var-file="prod.tfvars"
   ```

4. **Apply Changes**:
   ```bash
   # For development
   terraform apply -var-file="dev.tfvars"
   
   # For production
   terraform apply -var-file="prod.tfvars"
   ```

5. **Verify Deployment**:
   - Check the outputs for important resource information
   - Verify resources in AWS Console
   - Test application access via ALB DNS name

### Handling Existing Resources

When working with existing resources like CloudWatch Log Groups:

Set `use_existing_log_group = true` in the module configuration to use existing log groups instead of creating new ones.

## Environment Configuration

### Development Environment
The development environment (`dev.tfvars`) is configured for:

- Cost optimization (single NAT Gateway)
- Reduced redundancy (2 AZs)
- Smaller instance types (t2.micro)
- Shorter log retention periods
- HTTP only (no HTTPS)

### Production Environment
The production environment (`prod.tfvars`) is configured for:

- High availability (3 AZs, multiple NAT Gateways)
- Larger instance types (t3.small)
- Higher minimum instance count
- Longer log retention periods
- HTTPS enabled with SSL certificate
- Stricter deletion protection

## Troubleshooting

### Debugging Tools

1. **CloudWatch Logs Insights**:
   - Query for errors: `fields @timestamp, @message | filter @message like /error/i | sort @timestamp desc | limit 20`
   - Analyze WAF blocks: `fields @timestamp, action, httpRequest.clientIp | filter action = "BLOCK" | sort @timestamp desc`

2. **VPC Flow Logs Analysis**:
   - Identify rejected traffic: `fields @timestamp, srcAddr, dstAddr, action | filter action = "REJECT" | sort @timestamp desc`
   - Top traffic sources: `stats count(*) as requestCount by srcAddr | sort requestCount desc | limit 10`

3. **EC2 Instance Checks**:
   - SSH to bastion: `ssh -i key-mgnt-dev.pem ubuntu@<bastion-public-ip>`
   - SSH to web server: `ssh -i key-mgnt-dev.pem ubuntu@<web-server-private-ip>`
   - Check CloudWatch agent: `sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status`

## Best Practices

### Security
- Regularly update WAF rules to protect against new threats
- Rotate SSH keys periodically
- Review VPC Flow Logs for suspicious activity
- Use least privilege IAM permissions

### Performance
- Monitor ALB metrics for latency and error rates
- Adjust Auto Scaling parameters based on traffic patterns
- Use CloudWatch agent custom metrics for application-specific monitoring

### Cost Optimization
- Use lifecycle policies for log storage
- Scale down resources in development environment when not in use
- Monitor CloudWatch usage and adjust retention periods as needed

### Reliability
- Test failover scenarios regularly
- Implement cross-region disaster recovery for production
- Use health checks to detect and replace unhealthy instances

## Maintenance

### Regular Tasks
- Review and analyze logs for security and performance issues
- Update AMIs with latest security patches
- Test backup and recovery procedures
- Review and adjust alarm thresholds

### Scaling Considerations
- Adjust Auto Scaling parameters for changing traffic patterns
- Consider reserved instances for predictable workloads
- Evaluate instance types for cost/performance optimization

### Updates and Upgrades
- Plan for AWS service updates
- Test Terraform version upgrades in development first
- Document configuration changes

## Testing and Simulation

### CPU Load Testing

To test auto-scaling and CloudWatch alarms, you can simulate high CPU usage on EC2 instances:

#### Using the stress Tool

1. **SSH into the EC2 instance** (via bastion host if needed):
   ```bash
   # Connect to bastion first
   ssh -i your-key.pem ubuntu@<bastion-public-ip>
   
   # Then connect to the web server
   ssh -i your-key.pem ubuntu@<web-server-private-ip>
   ```

2. **Install the stress tool**:
   ```bash
   sudo apt-get update
   sudo apt-get install -y stress
   ```

3. **Generate high CPU load**:
   ```bash
   # Use all CPU cores at 100% for 5 minutes
   stress --cpu $(nproc) --timeout 300s
   ```

4. **For more controlled testing**:
   ```bash
   # For approximately 80% CPU usage on a single core
   stress --cpu 1 --timeout 300s &
   sleep 1
   pid=$!
   cpulimit -p $pid -l 80
   ```

5. **Monitor CPU usage in real-time**:
   ```bash
   top
   # or
   htop  # If installed
   ```

#### Using a Simple Bash Loop

If `stress` is not available, you can use this bash script:

```bash
#!/bin/bash
# CPU stress test
duration=300  # 5 minutes
end=$((SECONDS+duration))

echo "Starting CPU stress test for $duration seconds..."
while [ $SECONDS -lt $end ]; do
  # Create load by calculating prime numbers
  for i in {1..10000}; do
    echo "$i" | factor > /dev/null
  done
done
echo "CPU stress test completed."
```

Save this as `cpu_stress.sh`, make it executable with `chmod +x cpu_stress.sh`, and run it with `./cpu_stress.sh`.

#### Verifying the Test

1. **Check CloudWatch Metrics**:
   - Navigate to CloudWatch in the AWS Console
   - View the CPU utilization metrics for the instance
   - Verify that the alarm was triggered

2. **Verify Auto Scaling**:
   - Check if new instances were launched
   - Review the Auto Scaling Group activity history

3. **Review Notifications**:
   - Check if SNS notifications were sent
   - Verify that the appropriate teams were notified

This testing helps ensure that your auto-scaling configuration and alerting systems work correctly before they're needed in a real high-load situation.

---

## Contact Information

For questions or issues, please contact the infrastructure team.

**Last Updated**: May 2025