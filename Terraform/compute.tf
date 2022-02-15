resource "aws_ecr_repository" "service" {
  name                 = local.repo
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "repo-policy" {
  repository = aws_ecr_repository.service.name
  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep image deployed with tag latest",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["latest"],
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep last 2 any images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 2
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
  depends_on = [aws_ecr_repository.service]
}


data "template_file" "synthesisapp" {
  template = file("./synthesis-task.json.tpl")
  vars = {
    aws_ecr_repository = aws_ecr_repository.service.repository_url
    tag                = "latest"
    app_port           = 80
    region             = var.region
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "synthesis-taskdefinition"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_secrets_role.arn 
  #task_role_arn            = aws_iam_role.ecs.arn
  cpu                      = 256
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.synthesisapp.rendered
  
  tags = local.tags
}

resource "aws_ecs_cluster" "Synthesis-cluster" {
  name = "Synthesis-cluster"
}

resource "aws_ecs_service" "Synthesis-Service" {
  name            = "Synthesis-Service"
  cluster         = aws_ecs_cluster.Synthesis-cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = [aws_subnet.synthesis-subnet-private-3.id, aws_subnet.synthesis-subnet-private-4.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.staging.arn
    container_name   = local.applicationName
    container_port   = 80
  }

  depends_on = [aws_lb_listener.https_forward, aws_iam_role_policy_attachment.ecs_task_execution_role]

  tags = local.tags
}






# resource "aws_apigatewayv2_vpc_link" "vpc_link" {
#   name               = "vpc_link"
#   security_group_ids = [aws_subnet.synthesis-subnet-public-1,aws_subnet.synthesis-subnet-public-2]
#   subnet_ids         =  [aws_subnet.synthesis-subnet-public-1.id, aws_subnet.synthesis-subnet-public-2.id]

#   tags = {
#     Usage = "example"
#   }
# }

# resource "aws_apigatewayv2_integration" "example" {
#   api_id           = aws_apigatewayv2_api.example.id
#   #credentials_arn  = aws_iam_role.example.arn
#   description      = "Example with a load balancer"
#   integration_type = "HTTP_PROXY"
#   integration_uri  = aws_lb_listener.https_forward.arn

#   integration_method = "ANY"
#   connection_type    = "VPC_LINK"
#   connection_id      = aws_apigatewayv2_vpc_link.vpc_link.id

#   # tls_config {
#   #   server_name_to_verify = "example.com"
#   # }

#   request_parameters = {
#     "append:header.authforintegration" = "$context.authorizer.authorizerResponse"
#     "overwrite:path"                   = "staticValueForIntegration"
#   }

#   response_parameters {
#     status_code = 403
#     mappings = {
#       "append:header.auth" = "$context.authorizer.authorizerResponse"
#     }
#   }

#   response_parameters {
#     status_code = 200
#     mappings = {
#       "overwrite:statuscode" = "204"
#     }
#   }
# }