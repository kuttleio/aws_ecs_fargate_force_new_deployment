module "lambda_function_ecs_fargate_force_new_deployment" {
    source                  = "terraform-aws-modules/lambda/aws"
    version                 = "2.16.0"
    function_name           = "${var.name_prefix}-ECS-Fargate-Force-New-Deployment"
    description             = "ECS Fargate Force New Deployment"
    handler                 = "force-service.lambda_handler"
    runtime                 = "python3.9"
    source_path             = "${path.module}/src/force-service.py"
    timeout                 = 30
    memory_size             = 256
    maximum_retry_attempts  = 2
    attach_policy           = true
    policy                  = aws_iam_policy.policy_for_ecs_fargate_force_new_deployment_lambda.arn

    ## https://github.com/terraform-aws-modules/terraform-aws-lambda/issues/36
    create_current_version_allowed_triggers = false

    environment_variables = {
        ECS_CLUSTER     = var.ecs_cluster
        SQS_URL         = aws_sqs_queue.fargate_force_update.url
    }

    allowed_triggers = {
        Every15Min = {
            principal  = "events.amazonaws.com"
            source_arn = aws_cloudwatch_event_rule.action_schedule_rule.arn
        }
    }

    tags = merge(var.standard_tags,
    {
        Name    = "Force New Deployment - Fargate"
        Comment = "Managed by Terraform"
    })

}

resource "aws_iam_policy" "policy_for_ecs_fargate_force_new_deployment_lambda" {
    name        = "${var.name_prefix}-ECS-Fargate-Force-New-Deployment-Lambda"
    path        = "/"
    description = "Allow to list ECS Services & SQS"

    ### Policy looks complicated? Check this out why: https://stackoverflow.com/questions/59604987/why-i-am-getting-not-authorized-to-perform-ecslisttasks-on-resource-excep
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
            {
                Action = [
                    "ecs:ListServices",
                    "ecs:DescribeServices",
                    "ecs:UpdateService"
                ]
                Effect   = "Allow"
                Resource = "*"
                Condition = {
                    ArnEquals = {
                        "ecs:cluster" = var.ecs_cluster
                    }
                }
            },
            {
                Action = [
                    "sqs:ReceiveMessage",
                    "sqs:DeleteMessage",
                ]
                Effect   = "Allow"
                Resource = aws_sqs_queue.fargate_force_update.arn
            },
        ]
    })
}

resource "aws_cloudwatch_event_rule" "action_schedule_rule" {
    name                = var.action_rule.name
    description         = var.action_rule.description
    schedule_expression = var.action_rule.expression
}
