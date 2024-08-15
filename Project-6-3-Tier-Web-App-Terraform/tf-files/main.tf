# Pre-requisite: 
# - An S3 Bucket to store the state file


# 1. Configure the providers

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

# 2. Configure the VPC and Subnets

resource "aws_vpc" "tf_project_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name      = "TF-Project-VPC"
    Terraform = "true"
  }
}

resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnet
  vpc_id   = aws_vpc.tf_project_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = element(data.aws_availability_zones.available.names, each.value - 1)
  map_public_ip_on_launch = true

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

resource "aws_subnet" "private_subnets_1" {
  for_each = var.private_subnet_1
  vpc_id   = aws_vpc.tf_project_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = element(data.aws_availability_zones.available.names, each.value - 1)

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

resource "aws_subnet" "private_subnets_2" {
  for_each = var.private_subnet_2
  vpc_id   = aws_vpc.tf_project_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value + length(var.private_subnet_1)) # Adjust for overlapping
  availability_zone = element(data.aws_availability_zones.available.names, each.value - 1)

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

# 3. Configure the Internet Gateway and Nat GW

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.tf_project_vpc.id

  tags = {
    Name      = "TF-IGW"
    Terraform = "true"
  }
}

resource "aws_eip" "nat_gateway_eip_1" {
  domain = "vpc"

  tags = {
    Name      = "Gateway_EIP_1"
    Terraform = "true"
  }
}

resource "aws_eip" "nat_gateway_eip_2" {
  domain = "vpc"

  tags = {
    Name      = "Gateway_EIP_2"
    Terraform = "true"
  }
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_eip_1.id
  subnet_id     = aws_subnet.public_subnets["public_1"].id

  tags = {
    Name = "Nat_Gateway_1"
  }
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_gateway_eip_2.id
  subnet_id     = aws_subnet.public_subnets["public_2"].id

  tags = {
    Name = "Nat_Gateway_2"
  }
}

# 4. Configure route tables

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.tf_project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }

  tags = {
    Name      = "Public Route Table"
    Terraform = "true"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.tf_project_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }

  tags = {
    Name      = "Private Route Table"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public_subnets
  subnet_id = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

locals {
  all_private_subnets = merge(aws_subnet.private_subnets_1, aws_subnet.private_subnets_2)
}

resource "aws_route_table_association" "private" {
  for_each = local.all_private_subnets
  subnet_id = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}


# 5. Configure the Security groups

resource "aws_security_group" "public_sg" {
  name = "allow http/https"
  description = "Allow traffic on port 80 and 433"
  vpc_id = aws_vpc.tf_project_vpc.id
  tags = {
    Name = "Public-SG"
  }
   ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# 6.1 Configure Front End (EC2 Instances and Auto Scaling)

resource "tls_private_key" "key_gen" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "aws_key_pair" "ec2_key" {
  key_name = "ec2_key"
  public_key = tls_private_key.key_gen.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.key_gen.private_key_pem
  filename = "C:/Users/paul_/Downloads/ec2_key.pem"
}

resource "aws_instance" "web_server_1" {
  instance_type = "t2.micro"
  ami = "ami-04ff98ccbfa41c9ad"
  security_groups = [aws_security_group.public_sg.id]
  key_name = aws_key_pair.ec2_key.id
  subnet_id = aws_subnet.public_subnets["public_1"].id
  user_data = base64encode(file("userdata.sh"))
  tags = {
    Name = "Terraform Server"
    Terraform = "true"
  }
}

resource "aws_launch_template" "web_server_template" {
  name_prefix = "web_sv_"
  image_id = "ami-04ff98ccbfa41c9ad"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ec2_key.key_name

  network_interfaces {
    security_groups = [ aws_security_group.public_sg.id ]
  }

  user_data = base64encode(file("userdata.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Terraform servers"
      Terraform = "true"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name = "auto_scaling_group"
  desired_capacity = 2
  max_size = 3
  min_size = 2
  vpc_zone_identifier = [ aws_subnet.public_subnets["public_1"].id, aws_subnet.public_subnets["public_2"].id ]

  launch_template {
    id = aws_launch_template.web_server_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.alb_tg.arn]

  tag {
    key = "Name"
    value = "Terraform ASG Instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "target_tracking_policy" {
  name                   = "target tracking policy"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  estimated_instance_warmup = 300
  autoscaling_group_name = aws_autoscaling_group.web_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [
    aws_subnet.public_subnets["public_1"].id,
    aws_subnet.public_subnets["public_2"].id
  ]

  enable_deletion_protection = false

  tags = {
    Name      = "app-lb"
    Terraform = "true"
  }
}


resource "aws_lb_target_group" "alb_tg" {
  name        = "tf-lb-alb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.tf_project_vpc.id
  
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}


# 6.2 Configure Back End

resource "aws_launch_template" "backend_template" {
  name_prefix   = "backend-"
  image_id      = "ami-04ff98ccbfa41c9ad" # Replace with your AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2_key.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.backend_sg.id] 
    subnet_id                   = aws_subnet.private_subnets_1["private_3"].id 
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = "Backend-Instance"
      Terraform = "true"
    }
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "Backend-SG"
  description = "Security group for the backend"

  vpc_id = aws_vpc.tf_project_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups =  [aws_security_group.public_sg.id]
  }

  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    security_groups          = [aws_security_group.public_sg.id] 
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name                      = "backend-asg"
  launch_template {
    id      = aws_launch_template.backend_template.id
    version = "$Latest"
  }
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 3
  vpc_zone_identifier       = [aws_subnet.private_subnets_1["private_3"].id] 
  target_group_arns         = [aws_lb_target_group.alb_tg.arn]

  tag {
    key                 = "Name"
    value               = "Backend-Instance"
    propagate_at_launch = true
  }
}



# 7. Configure RDS Instances

resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.public_subnets["public_1"].id, aws_subnet.private_subnets_1["private_3"].id]

  tags = {
    Name = "My DB subnet group"
  }
}

# 8. Configure CloudFront and WAF

resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = aws_lb.app_lb.dns_name 
    origin_id   = "ALB-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  web_acl_id = aws_wafv2_web_acl.web_acl.arn

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "ALB-origin"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_wafv2_web_acl" "web_acl" {
  name        = "my-web-acl"
  description = "Web ACL to protect my CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Add your rules here

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled  = true
    metric_name               = "WebACL"
  }
}

