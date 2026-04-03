# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

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

# IAM Policy for CloudWatch
resource "aws_iam_role_policy" "cloudwatch" {
  name = "${var.project_name}-cloudwatch-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for ECR
resource "aws_iam_role_policy" "ecr" {
  name = "${var.project_name}-ecr-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# User Data Script
locals {
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    # Update system
    yum update -y

    # Install Docker
    amazon-linux-extras install docker -y
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Create app directory
    mkdir -p /opt/task-app
    cd /opt/task-app

    # Create docker-compose.yml
    cat > docker-compose.yml << 'DOCKER'
    version: '3.8'
    services:
      api:
        image: ${var.docker_image_uri}
        environment:
          DB_HOST: ${var.db_host}
          DB_PORT: 5432
          DB_USER: ${var.db_username}
          DB_PASSWORD: ${var.db_password}
          DB_NAME: ${var.db_name}
          JWT_SECRET: ${var.jwt_secret}
        ports:
          - "8000:8000"
        restart: always
        healthcheck:
          test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
          interval: 30s
          timeout: 10s
          retries: 3
          start_period: 40s
    DOCKER

    # Note: docker-compose up will be run manually after ECR image is pushed
    echo "Docker Compose configured at /opt/task-app"
  EOF
  )
}

# EC2 Instance
resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = local.user_data

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.volume_size
    delete_on_termination = true
    encrypted             = true
  }

  monitoring = true

  tags = merge(var.tags, {
    Name = var.instance_name
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for EC2
resource "aws_eip" "ec2" {
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-eip"
  })

  depends_on = [aws_instance.main]
}
