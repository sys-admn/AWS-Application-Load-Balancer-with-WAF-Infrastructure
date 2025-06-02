# AWS Application Load Balancer with WAF Infrastructure

This project sets up an AWS infrastructure with Application Load Balancer, WAF, and EC2 instances.

## Security Notice

This project uses sensitive variables that should not be committed to Git. These variables are stored in a `secrets.tfvars` file which is excluded from Git via `.gitignore`.

### Sensitive Information

The following sensitive information is stored in `secrets.tfvars`:

- IP addresses for bastion access
- IP addresses for WAF blocking
- AWS Account IDs in ARNs
- SNS Topic ARNs
- Certificate ARNs

## Architecture

- **VPC**: Custom VPC with public and private subnets
- **ALB**: Application Load Balancer with WAF protection
- **EC2**: Auto Scaling Group with instances in private subnets
- **WAF**: Web Application Firewall with IP blocking and rule sets
- **Logs**: S3 bucket for ALB logs with lifecycle policies
- **Monitoring**: CloudWatch dashboards and alarms

## How to Use

1. Create a `secrets.tfvars` file with the following structure:
```hcl
# IP Addresses
bastion_allowed_ips         = ["x.x.x.x/32"]  # Your actual IP
waf_blocked_ips             = ["x.x.x.x/32"]  # IPs to block

# AWS Account specific information
sns_topic_arn_dev           = "arn:aws:sns:region:account-id:topic-name"
sns_topic_arn_prod          = "arn:aws:sns:region:account-id:topic-name"
certificate_arn             = "arn:aws:acm:region:account-id:certificate/id"
```

2. Apply the configuration using:
```bash
# For development environment
terraform apply -var-file=dev.tfvars -var-file=secrets.tfvars

# For production environment
terraform apply -var-file=prod.tfvars -var-file=secrets.tfvars
```

## S3 Bucket for ALB Logs

The infrastructure automatically creates an S3 bucket for ALB logs with:
- Lifecycle policies (transition to IA after 30 days, Glacier after 90 days)
- Server-side encryption (AES256)
- Public access blocking
- Proper bucket policies for ALB log delivery

## Important Security Notes

- Never commit `secrets.tfvars` to Git
- Always use `-var-file=secrets.tfvars` when applying the configuration
- Review the `.gitignore` file to ensure sensitive files are excluded
- The ALB logs bucket has hardcoded AWS account IDs for the ELB service