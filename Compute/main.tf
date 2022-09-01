# LATEST AMI FROM PARAMETER STORE

data "aws_ami" "amazon-2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  owners = ["amazon"]
}

# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR BASTION

resource "aws_launch_template" "three_tier_bastion" {
  name_prefix            = "3-Tier-Bastion"
  instance_type          = var.instance_type
  image_id               = data.aws_ami.amazon-2.id
  vpc_security_group_ids = [var.bastion_sg]
  key_name               = var.key_name

  tags = {
    Name = "Three Tier Bastion System"
  }
}

resource "aws_autoscaling_group" "bastion_auto_scaling" {
  name                = "Bastion Autoscaling"
  vpc_zone_identifier = var.public_subnets
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.three_tier_bastion.id
    version = "$Latest"
  }
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR FRONTEND APP TIER

resource "aws_launch_template" "three_tier_app" {
  name_prefix            = "three_tier_app"
  instance_type          = var.instance_type
  image_id               = data.aws_ami.amazon-2.id
  vpc_security_group_ids = [var.frontend_app_sg]
  key_name               = var.key_name

  tags = {
    Name = "three_tier_app"
  }
  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello World from $(hostname -f)" > /var/www/html/index.html
EOF
}

data "aws_lb_target_group" "three_tier_tg" {
  name = var.lb_tg_name
}

resource "aws_autoscaling_group" "three_tier_app" {
  name                = "App Autoscaling"
  vpc_zone_identifier = var.private_subnets
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  target_group_arns = [data.aws_lb_target_group.three_tier_tg.arn]

  launch_template {
    id      = aws_launch_template.three_tier_app.id
    version = "$Latest"
  }
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR BACKEND

resource "aws_launch_template" "three_tier_backend" {
  name_prefix            = "three_tier_backend"
  instance_type          = var.instance_type
  image_id               = data.aws_ami.amazon-2.id
  vpc_security_group_ids = [var.backend_app_sg]
  key_name               = var.key_name
  user_data              = <<-EOF
  #! /bin/bash
yum update -y
yum -y install curl
yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs
EOF
  tags = {
    Name = "Backend Template"
  }
}

resource "aws_autoscaling_group" "three_tier_backend" {
  name                = "Backend Autoscaling"
  vpc_zone_identifier = var.private_subnets
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.three_tier_backend.id
    version = "$Latest"
  }
}

# AUTOSCALING ATTACHMENT FOR APP TIER TO LOADBALANCER

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.three_tier_app.id
  lb_target_group_arn    = var.lb_tg
}