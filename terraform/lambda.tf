data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "covid_etl_lambda_role" {
  name               = "covid-etl-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy" "covid_etl_lambda_role_log_policy" {
  name   = "CovidETLLambdaRolePolicy"
  role   = aws_iam_role.covid_etl_lambda_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "covid_etl_lambda_role_sns_policy" {
  name   = "CovidETLAllowSNSPermissions"
  role   = aws_iam_role.covid_etl_lambda_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sns_topic.covid_table_updated.arn}"
    }
  ]
}
EOF
}

locals {
  lambda_src_path = "../"
  covid-python-layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSDataWrangler-Python39:1"
  ]

}
resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.lambda_src_path, "*.py"),
      fileset(local.lambda_src_path, "requirements.txt"),
    ) :
    filename => filemd5("${local.lambda_src_path}/${filename}")
  }
}

data "archive_file" "covid_lambda_package" {
  type        = "zip"
  source_dir  = local.lambda_src_path
  output_path = "${random_uuid.lambda_src_hash.result}.zip"
  excludes = [
    "__pycache__",
    "Pipfile",
    "terraform/*",
    "test/*"
  ]
}

resource "aws_lambda_function" "covid_etl_lambda_func" {
  function_name = "covid_etl_lambda_function"

  filename         = data.archive_file.covid_lambda_package.output_path
  source_code_hash = data.archive_file.covid_lambda_package.output_base64sha256

  role    = aws_iam_role.covid_etl_lambda_role.arn
  handler = "lambda.handler"
  runtime = "python3.9"

  layers = [for layer in local.covid-python-layers : layer]

  memory_size = 512
  timeout     = 900

  environment {
    variables = {
      DYNAMO_TABLE_NAME = var.dynamo-table-name
      SNS_ARN           = var.sns-topic-arn
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_covid_etl" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.covid_etl_lambda_func.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}

resource "aws_sns_topic" "covid_table_updated" {
  name = "covid-table-updated"
}

resource "aws_sns_topic_subscription" "covid_etl_updated" {
  endpoint  = var.sns-email-endpoint
  protocol  = "email"
  topic_arn = aws_sns_topic.covid_table_updated.arn
}