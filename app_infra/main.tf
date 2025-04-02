# Create ALB in Public Subnet

resource "aws_security_group" "alb_sg" {
  name        = join("-", [var.branch, var.appname, "ALB_sg"])
  description = "Security group for NGINX server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name                       = "my-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [aws_subnet.public.id]
  enable_deletion_protection = true
  access_logs {
    bucket  = var.logs_bucket
    enabled = true
  }
}

# NGINX can be configured to run on port 443
# For this scenario we are using port 80

resource "aws_lb_target_group" "nginx" {
  name     = "nginx-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}


# Create EC2 instance in Private Subnet
# The protocol can be changed to HTTPS to provide end-to-end encryption

resource "aws_security_group" "nginx_sg" {
  name        = join("-", [var.branch, var.appname, "nginx_sg"])
  description = "Security group for NGINX server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow SSH access from 10.0.0.0/8 (Private Network)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Restricts SSH access to private network
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "nginx" {
  name                 = "nginx-launch-configuration"
  image_id             = var.custom_ami_id # Use custom AMI ID
  instance_type        = var.instance_type
  key_name             = "your-ssh-key" # Replace with your SSH key name
  security_groups      = [aws_security_group.nginx_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y

              # Install NGINX
              sudo amazon-linux-extras enable nginx1
              sudo yum install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx

              # Install CloudWatch Agent
              sudo yum install -y amazon-cloudwatch-agent

              # Create CloudWatch Agent Config
              cat <<END | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/var/log/nginx/access.log",
            "log_stream_name": "{instance_id}-access",
            "timestamp_format": "%d/%b/%Y:%H:%M:%S %z"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/var/log/nginx/error.log",
            "log_stream_name": "{instance_id}-error",
            "timestamp_format": "%d/%b/%Y:%H:%M:%S %z"
          }
        ]
      }
    }
  }
}
END

              # Start CloudWatch Agent
              sudo amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json -s

              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "EC2LoggingRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ec2_cloudwatch_s3_policy" {
  name        = "EC2CloudWatchS3Policy"
  description = "Policy for EC2 to write logs to CloudWatch and access S3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::belong-coding-challenge",
        "arn:aws:s3:::belong-coding-challenge/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.ec2_cloudwatch_s3_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}


# Create ASG with combination of reserved instances and spot instances

resource "aws_autoscaling_group" "nginx_asg" {
  desired_capacity     = var.desired_capacity
  min_size             = var.min_size
  max_size             = var.max_size
  launch_configuration = aws_launch_configuration.nginx.id
  vpc_zone_identifier  = local.private_subnets

  health_check_type         = "EC2"
  health_check_grace_period = 300

  force_delete = true

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1                    # Ensure at least 1 On-Demand instance
      on_demand_percentage_above_base_capacity = 30                   # 30% On-Demand, 70% Spot
      spot_allocation_strategy                 = "capacity-optimized" # Optimize for available Spot capacity
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.nginx_lt.id
        version            = "$Latest"
      }
    }
  }

  target_group_arns = [aws_lb_target_group.nginx.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "nginx" {
  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.nginx.id
  port             = 80
}