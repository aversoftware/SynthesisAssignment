resource "aws_cloudwatch_log_group" "synthesisapi" {
  name = "awslogs-synthesisapi-staging"

  tags = local.tags
}