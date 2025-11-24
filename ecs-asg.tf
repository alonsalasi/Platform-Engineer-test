# ECS Auto Scaling Groups managed by K8s Platform
# This file is auto-updated by GitHub Actions

# ASGs will appear here after creation

data "aws_ami" "ecs_optimized_test" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_template" "ecs_lt_test" {
  name_prefix   = "test-"
  image_id      = data.aws_ami.ecs_optimized_test.id
  instance_type = "t3.micro"
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile_test.name
  }
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=temp-cluster >> /etc/ecs/ecs.config
  EOF
  )
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "test-instance"
      ManagedBy = "K8s-GitOps"
    }
  }
}

resource "aws_autoscaling_group" "ecs_asg_test" {
  name                = "test"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  vpc_zone_identifier = ["subnet-0315f97df3d9be14d", "subnet-0fbcaf451e77e245d"]
  
  launch_template {
    id      = aws_launch_template.ecs_lt_test.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "test"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "CapacityProviderTargetCapacity"
    value               = "60"
    propagate_at_launch = false
  }
  
  tag {
    key                 = "CapacityProviderMaxScalingStep"
    value               = "10"
    propagate_at_launch = false
  }
  
  tag {
    key                 = "CapacityProviderMinScalingStep"
    value               = "1"
    propagate_at_launch = false
  }
  
  tag {
    key                 = "CapacityProviderTerminationProtection"
    value               = "DISABLED"
    propagate_at_launch = false
  }
}

resource "aws_iam_role" "ecs_instance_role_test" {
  name = "test-instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_test" {
  role       = aws_iam_role.ecs_instance_role_test.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile_test" {
  name = "test-instance-profile"
  role = aws_iam_role.ecs_instance_role_test.name
}
