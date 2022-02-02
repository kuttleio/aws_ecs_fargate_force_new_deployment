module "lambda_function_list_services" {
    source                  = "terraform-aws-modules/lambda/aws"
    version                 = "2.16.0"
    function_name           = "${var.name_prefix}-ECS-Fargate-List-Services"
    description             = "List ECS Fargate Services"
    handler                 = "list-services.lambda_handler"
    runtime                 = "python3.9"
    source_path             = "${path.module}/src/list-services.py"
    timeout                 = 30
    memory_size             = 256
    maximum_retry_attempts  = 2
    attach_policy           = true
    policy                  = aws_iam_policy.policy_for_list_services_lambda.arn

    ## https://github.com/terraform-aws-modules/terraform-aws-lambda/issues/36
    create_current_version_allowed_triggers = false

    environment_variables = {
        ECS_CLUSTER     = var.ecs_cluster
        SQS_URL         = aws_sqs_queue.fargate_force_update.url
    }

    allowed_triggers = {
        OnceAWeek = {
            principal  = "events.amazonaws.com"
            source_arn = aws_cloudwatch_event_rule.run_every_week.arn
        }
    }

    tags = merge(var.standard_tags,
    {
        Name    = "List ECS Fargate Services"
        Comment = "Managed by Terraform"
    })
}

resource "aws_sqs_queue" "fargate_force_update" {
    name = "${var.name_prefix}-fargate-force-update"

    tags = merge(var.standard_tags,
    {
        Name    = "List ECS Fargate Services"
        Comment = "Managed by Terraform"
    })
}

resource "aws_iam_policy" "policy_for_list_services_lambda" {
    name        = "${var.name_prefix}-List-ECS-Services-Lambda"
    path        = "/"
    description = "Allow to list ECS Services & Push messages to SQS"

    ### Policy looks complicated? Check this out why: https://stackoverflow.com/questions/59604987/why-i-am-getting-not-authorized-to-perform-ecslisttasks-on-resource-excep
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
            {
                Action = [
                    "ecs:ListServices"
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
                    "sqs:SendMessage",
                ]
                Effect   = "Allow"
                Resource = aws_sqs_queue.fargate_force_update.arn
            },
        ]
    })
}

resource "aws_cloudwatch_event_rule" "run_every_week" {
    name                = "run-every-week"
    description         = "Fires Lambda every Sunday morning"
    schedule_expression = "cron(0 7 ? * SUN *)"
}