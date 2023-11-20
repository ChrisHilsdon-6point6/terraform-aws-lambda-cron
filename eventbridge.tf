data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "scheduler_policy" {
  statement {
    effect    = "Allow"
    actions   = [
      "lambda:InvokeFunction",
    ]
    resources = [
        "${aws_lambda_function.cron_lambda.arn}:*",
        "${aws_lambda_function.cron_lambda.arn}",
    ]
  }
}

resource "aws_iam_role" "iam_role_scheduler" {
  name               = "iam_role_scheduler"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
}

resource "aws_iam_policy" "role_policy_scheduler" {
  name        = "role_policy_scheduler"
  description = "Give access to scheduler to trigger lambda"
  policy      = data.aws_iam_policy_document.scheduler_policy.json
}

resource "aws_iam_role_policy_attachment" "role_policy_scheduler_attach" {
  role       = aws_iam_role.iam_role_scheduler.name
  policy_arn = aws_iam_policy.role_policy_scheduler.arn
}

resource "aws_scheduler_schedule" "lambda_cron_schedule" {
  name       = "lambda_cron_schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0/5 * * * ? *)"

  target {
    arn = aws_lambda_function.cron_lambda.arn
    role_arn = aws_iam_role.iam_role_scheduler.arn
  }
}