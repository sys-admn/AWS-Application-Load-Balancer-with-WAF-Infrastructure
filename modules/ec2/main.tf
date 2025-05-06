data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.name_prefix}web-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  iam_instance_profile {
    name = aws_iam_instance_profile.web_instance_profile.name
  }
  
  network_interfaces {
    associate_public_ip_address = var.web_associate_public_ip
    security_groups             = [var.web_sg_id]
  }
  
  user_data = var.user_data_file != "" ? filebase64(var.user_data_file) : base64encode(
    replace(
      replace(
        file("${path.module}/scripts/default_web_setup.sh"),
        "LOG_GROUP_NAME_PLACEHOLDER", var.cloudwatch_log_group_name != "" ? var.cloudwatch_log_group_name : "${var.name_prefix}ec2-logs"
      ),
      "RETENTION_DAYS_PLACEHOLDER", tostring(var.cloudwatch_log_retention_days)
    )
  )
  
  block_device_mappings {
    device_name = "/dev/sda1"
    
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true
      encrypted             = true
    }
  }
  
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.imds_require_imdsv2 ? "required" : "optional"
    http_put_response_hop_limit = 1
  }
  
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "${var.name_prefix}web-server"
      },
      var.tags
    )
  }
  
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        Name = "${var.name_prefix}web-server-volume"
      },
      var.tags
    )
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name_prefix         = "${var.name_prefix}web-asg-"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.private_subnets
  
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  
  target_group_arns = [var.target_group_arn]
  
  health_check_type         = "ELB"
  health_check_grace_period = 300
  
  # Enable instance refresh for zero-downtime deployments
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  
  dynamic "tag" {
    for_each = merge(
      {
        Name = "${var.name_prefix}web-server"
      },
      var.tags
    )
    
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "web_scale_up" {
  name                   = "${var.name_prefix}web-scale-up"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "web_scale_down" {
  name                   = "${var.name_prefix}web-scale-down"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

data "aws_instances" "web_instances" {
  filter {
    name   = "tag:Name"
    values = ["${var.name_prefix}web-server"]
  }
  
  depends_on = [aws_autoscaling_group.web]
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = length(var.public_subnets) > 0 ? var.public_subnets[0] : (var.bastion_subnet_id != "" ? var.bastion_subnet_id : var.private_subnets[0])
  associate_public_ip_address = var.bastion_associate_public_ip
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.bastion_instance_profile.name
  
  user_data = base64encode(
    replace(
      replace(
        file("${path.module}/scripts/default_web_setup.sh"),
        "LOG_GROUP_NAME_PLACEHOLDER", var.cloudwatch_log_group_name != "" ? var.cloudwatch_log_group_name : "${var.name_prefix}ec2-logs"
      ),
      "RETENTION_DAYS_PLACEHOLDER", tostring(var.cloudwatch_log_retention_days)
    )
  )
  
  root_block_device {
    volume_size           = var.bastion_volume_size
    volume_type           = var.bastion_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.imds_require_imdsv2 ? "required" : "optional"
    http_put_response_hop_limit = 1
  }
  
  tags = merge(
    {
      Name = "${var.name_prefix}bastion"
    },
    var.tags
  )
  
  lifecycle {
    create_before_destroy = true
  }
}