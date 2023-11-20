locals {
  lambda_filename = "cron_lambda"
}

data "archive_file" "python_lambda_package" {
  type             = "zip"
  output_file_mode = "0666"
  source_file      = "${path.module}/lambda/${local.lambda_filename}.py"
  output_path      = "${path.module}/lambda/${local.lambda_filename}.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda-basic" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda_log" {
  name = "/aws/lambda/${aws_lambda_function.cron_lambda.function_name}"
}

resource "aws_lambda_function" "cron_lambda" {
  function_name    = local.lambda_filename
  filename         = "${path.module}/lambda/${local.lambda_filename}.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "python3.11"
  handler          = "${local.lambda_filename}.lambda_handler"
  timeout          = 10
}