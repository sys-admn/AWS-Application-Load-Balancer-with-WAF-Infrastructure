# 🚀 AWS Application Load Balancer with WAF Infrastructure

This Terraform project deploys a comprehensive AWS infrastructure featuring:
- VPC with public and private subnets
- Application Load Balancer (ALB)
- Web Application Firewall (WAF)
- Auto Scaling Group for EC2 instances
- Bastion host for secure SSH access
- CloudWatch monitoring and alerting
- Centralized logging with S3 storage
- VPC Flow Logs for network traffic analysis

## 📋 Architecture Overview

![Architecture Diagram](/assets/png/Development%20eu-west-3.png)

The infrastructure consists of:

1. **VPC Layer**:
   - Public and private subnets across multiple AZs
   - NAT Gateway for outbound internet access from private subnets
   - Internet Gateway for inbound/outbound access in public subnets
   - VPC Flow Logs for network traffic monitoring and security analysis

2. **Security Layer**:
   - WAF to protect against common web exploits
   - Security groups for fine-grained access control
   - Bastion host for secure SSH access to instances
   - Geographic restrictions for traffic filtering
   - Network traffic monitoring with VPC Flow Logs

3. **Application Layer**:
   - ALB to distribute traffic to web servers
   - Auto Scaling Group to maintain application availability
   - EC2 instances running web servers

4. **Monitoring & Logging Layer**:
   - CloudWatch dashboards for infrastructure visibility
   - CloudWatch alarms for automated notifications
   - SNS topics for alert delivery
   - Centralized logging to S3 with lifecycle policies
   - Log analysis dashboards
   - VPC Flow Logs analysis and visualization

## 🛠️ Prerequisites

- Terraform v1.8+
- AWS CLI configured with appropriate credentials
- SSH key pair for EC2 instance access

## 📁 Project Structure

```
.
├── main.tf              # Main configuration file
├── variables.tf         # Variable declarations
├── outputs.tf           # Output definitions
├── providers.tf         # Provider configuration
├── dev.tfvars           # Development environment variables
├── prod.tfvars          # Production environment variables
├── modules/
│   ├── alb/             # Application Load Balancer module
│   ├── cloudwatch/      # CloudWatch monitoring module
│   ├── ec2/             # EC2 instances and Auto Scaling module
│   ├── flow_logs/       # VPC Flow Logs module
│   ├── logs/            # Centralized logging module
│   ├── security_groups/ # Security groups module
│   ├── vpc/             # VPC and networking module
│   └── waf/             # Web Application Firewall module
└── README.md            # This file
```

## 🚀 Deployment Instructions

### Initialize Terraform

```bash
terraform init
```

### Using Terraform Workspaces

```bash
# Create and select the development workspace
terraform workspace new dev
terraform workspace select dev

# Create and select the production workspace
terraform workspace new prod
terraform workspace select prod
```

### Development Environment

```bash
# Select the development workspace
terraform workspace select dev

# Plan the deployment
terraform plan -var-file="dev.tfvars"

# Apply the changes
terraform apply -var-file="dev.tfvars"
```

### Production Environment

#### Pre-deployment Steps

Before deploying to production, you need to create the CloudWatch Log Group for VPC Flow Logs:

```bash
# Create the CloudWatch Log Group for VPC Flow Logs
aws logs create-log-group --log-group-name "/aws/vpc/prod-flow-logs" --region eu-west-3
```

This is necessary because the module is configured to use an existing log group in production.

#### Deployment

```bash
# Select the production workspace
terraform workspace select prod

# Plan the deployment
terraform plan -var-file="prod.tfvars"

# Apply the changes
terraform apply -var-file="prod.tfvars"
```

### Destroy Resources

```bash
# When you're done, destroy the resources
terraform workspace select dev
terraform destroy -var-file="dev.tfvars"

# Or for production
terraform workspace select prod
terraform destroy -var-file="prod.tfvars"
```

## 🔧 Common Issues and Solutions

### 1. Missing CloudWatch Log Group for Flow Logs

**Error:**
```
Error: reading CloudWatch Logs Log Group (/aws/vpc/prod-flow-logs): empty result
```

**Solution:**
Create the CloudWatch Log Group manually before applying Terraform:
```bash
aws logs create-log-group --log-group-name "/aws/vpc/prod-flow-logs" --region eu-west-3
```

This is required because the Flow Logs module is configured to use existing log groups in production environments.

## 🔒 Security Features

- WAF protection against OWASP Top 10 vulnerabilities
- IP-based access restrictions for bastion host
- Security groups with least privilege access
- Private subnets for application servers
- HTTPS support with custom SSL certificates
- Geographic restrictions for traffic filtering
- Encrypted logs storage
- VPC Flow Logs for network traffic monitoring and security analysis

## 📊 Monitoring and Alerting

- CloudWatch dashboard for infrastructure metrics
- Automated alerts for:
  - High CPU utilization
  - ALB 5XX errors
  - WAF blocked requests
  - Abnormal log volume
  - Suspicious network traffic patterns (via Flow Logs)
  - Rejected network traffic exceeding thresholds

## 📝 Logging System

The infrastructure includes a comprehensive logging system with the following features:

- **Centralized Log Storage**:
  - S3 bucket for long-term log storage
  - CloudWatch Log Groups for real-time log analysis
  - Automatic log rotation and lifecycle management

- **Log Lifecycle Management**:
  - Transition to IA storage class after 30 days (configurable)
  - Transition to Glacier storage after 90 days (configurable)
  - Automatic expiration after 365 days (configurable)

- **Log Sources**:
  - EC2 instance system logs
  - Application logs (Apache, etc.)
  - WAF logs for security analysis
  - ALB access logs
  - VPC Flow Logs for network traffic analysis

- **Log Analysis**:
  - CloudWatch Logs Insights for querying logs
  - Custom CloudWatch dashboard for log visualization
  - Metrics based on log data
  - Network traffic pattern analysis

- **Security**:
  - Encrypted log storage
  - Access control via IAM
  - Redaction of sensitive information

## 🔍 VPC Flow Logs

The infrastructure includes VPC Flow Logs for network traffic monitoring:

- **Traffic Visibility**: Capture information about IP traffic going to and from network interfaces in your VPC
- **Security Analysis**: Identify suspicious traffic patterns and potential security threats
- **Compliance**: Meet regulatory requirements for network monitoring and auditing
- **Troubleshooting**: Diagnose overly restrictive security group rules or network ACLs
- **Visualization**: Custom CloudWatch dashboard for Flow Logs analysis
- **Alerting**: Automated alerts for abnormal network traffic patterns

## 🔄 Auto Scaling

The EC2 instances are managed by an Auto Scaling Group that:
- Maintains a minimum number of instances
- Scales based on CPU utilization
- Distributes instances across availability zones

## 📝 Customization

Edit the `.tfvars` files to customize:
- VPC CIDR and subnet configuration
- Instance types and sizes
- Auto Scaling parameters
- WAF rules and protections
- Monitoring thresholds
- Log retention policies
- Flow Logs configuration

## 🔗 Useful Links

- [AWS WAF Documentation](https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html)
- [AWS ALB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [AWS CloudWatch Logs Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html)
- [AWS VPC Flow Logs Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Workspaces](https://www.terraform.io/docs/language/state/workspaces.html)

## 📫 Support

For questions or issues, please open a GitHub issue or contact the infrastructure team.