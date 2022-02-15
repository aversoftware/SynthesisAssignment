data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ecs_task_secrets_role_policy" {
  name = "ecs_task_secrets_role_policy"
  role = aws_iam_role.ecs_task_secrets_role.id
  policy = jsonencode({
    Version= "2012-10-17"
    Statement  =    [   
      { 
        Effect= "Allow"
        Action= [
            "secretsmanager:GetRandomPassword",
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:ListSecrets"
        ]
        Resource = ["*"]  
      },
    ]
    })    
}

resource "aws_iam_role" "ecs_task_secrets_role" {
  name               = "ecs-staging-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json 
}

# resource "aws_iam_role_policy_attachment" "attach-secrets" {
#   role       = aws_iam_role.ecs_task_secrets_role.name
#   policy_arn = data.aws_iam_policy.ecs_task_secrets_role.arn
# }


resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-staging-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}