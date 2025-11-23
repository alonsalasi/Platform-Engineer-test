# ECS Auto Scaling Groups managed by K8s Platform
# This file is auto-updated by GitHub Actions

# ASGs will appear here after creation

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
}

