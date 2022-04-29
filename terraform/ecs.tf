resource "aws_cloudwatch_log_group" "ecs_test" {
  name              = "/ecs/test"
  retention_in_days = 30
}

resource "aws_ecs_cluster" "test" {
  name = "test"
}

### ECS Task Execution Role

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role-for-test"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_assume_role_policy.json

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "ecs_task_execution_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

### ECS Task Role

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs-task-role-for-test"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_role_policy.json

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "ecs_task_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_task_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"] # tfsec:ignore:aws-iam-no-policy-wildcards
  }
}

resource "aws_iam_policy" "ecs_task_role" {
  policy = data.aws_iam_policy_document.ecs_task_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role" {
  policy_arn = aws_iam_policy.ecs_task_role.arn
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "ecs" {
  name_prefix = "test-"
  vpc_id      = aws_default_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "egress" {
  description       = "Allow access to anywhere"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.ecs.id
  cidr_blocks       = ["0.0.0.0/0"] # tfsec:ignore:aws-vpc-no-public-egress-sgr
}
