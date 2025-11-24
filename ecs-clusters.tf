# ECS Clusters managed by K8s Platform
# This file is auto-updated by GitHub Actions

# Clusters will appear here after creation



resource "aws_ecs_cluster" "cluster_test" {
  name = "test"
  
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  
  tags = {
    Name = "test"
    ManagedBy = "K8s-GitOps"
    CreatedBy = "k8s-platform"
  }
}

resource "aws_ecs_capacity_provider" "cluster_test_cp" {
  name = "test-capacity-provider"
  
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg_test.arn
    managed_termination_protection = ""
    
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 
      maximum_scaling_step_size = 
      minimum_scaling_step_size = 
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_test_assoc" {
  cluster_name       = aws_ecs_cluster.cluster_test.name
  capacity_providers = [aws_ecs_capacity_provider.cluster_test_cp.name]
  
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cluster_test_cp.name
    weight            = 1
  }
}
