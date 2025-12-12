# IAM Role for EC2 instances (using existing LabRole as mentioned in instructions)
# Note: The instructions mention using the existing LabInstanceProfile
# This configuration assumes the LabRole and LabInstanceProfile already exist
# If they don't exist in your environment, uncomment the resources below

# Uncomment if LabRole doesn't exist
# resource "aws_iam_role" "ec2_role" {
#   name = "LabRole"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
#
#   tags = {
#     Name = "${var.project_name}-ec2-role"
#   }
# }

# Uncomment if LabInstanceProfile doesn't exist
# resource "aws_iam_instance_profile" "ec2_profile" {
#   name = "LabInstanceProfile"
#   role = aws_iam_role.ec2_role.name
# }

# Uncomment to attach necessary policies
# resource "aws_iam_role_policy_attachment" "secrets_manager" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
# }

# User data script for web servers
data "template_file" "user_data" {
  template = file("${path.module}/../UserdataScript-phase-3.sh")
}

# Launch Template for Auto Scaling
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = "LabInstanceProfile"
  }

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(data.template_file.user_data.rendered)

  monitoring {
    enabled = false
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-web-server"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policy - Target Tracking (CPU)
resource "aws_autoscaling_policy" "cpu_tracking" {
  name                   = "${var.project_name}-cpu-tracking"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}
