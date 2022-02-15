output "aws_lb_staging_dns_name"{
  description = "The Amazon Application Load Balancer DNS Name"
  value       = aws_lb.staging.dns_name
}

output "aws_ecr_repository_url"{
  description = "The Amazon ECR Repository URL"
  value       = aws_ecr_repository.service.repository_url
}

output "aws_ecs_cluster_name"{
  description = "The Amazon ECS Cluster name"
  value       = aws_ecs_cluster.Synthesis-cluster.name
}

output "aws_ecs_service_name"{
  description = "The Amazon ECS Service name"
  value=aws_ecs_service.Synthesis-Service.name
}
 