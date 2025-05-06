# IAM Role for EC2 instances to allow CloudWatch agent access
resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "${var.name_prefix}ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for CloudWatch agent
resource "aws_iam_policy" "cloudwatch_agent_policy" {
  name        = "${var.name_prefix}cloudwatch-agent-policy"
  description = "Policy for CloudWatch agent to write logs and metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_attachment" {
  role       = aws_iam_role.ec2_cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudwatch_agent_policy.arn
}

# Instance profile for web servers
resource "aws_iam_instance_profile" "web_instance_profile" {
  name = "${var.name_prefix}web-instance-profile"
  role = aws_iam_role.ec2_cloudwatch_role.name
}

# Instance profile for bastion host
resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "${var.name_prefix}bastion-instance-profile"
  role = aws_iam_role.ec2_cloudwatch_role.name
}