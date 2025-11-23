# ECS Clusters managed by K8s Platform
# This file is auto-updated by GitHub Actions

# Clusters will appear here after creation

resource "aws_ecs_cluster" "cluster_test" {
  cluster_name = "test"
  capacity_providers = ["FARGATE"]
  
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 1
  }
  
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

resource "aws_ecs_cluster" "cluster_test" {
  cluster_name = "test"
  capacity_providers = ["FARGATE"]
  
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 1
  }
  
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
