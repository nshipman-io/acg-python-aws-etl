data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "covid_etl_lambda_role" {
  name = "covid-etl-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "archive_file" "covid_lambda_package" {
  type = "zip"
  source_dir = "${path.module}/src/"
  output_path = "${path.module}/src/covid-etl.zip"
}

resource "aws_lambda_function" "covid_etl_lambda_func" {
  filename = "${path.module}/src/covid-etl.zip"
  function_name = "covid_etl_lambda_function"
  role = aws_iam_role.covid_etl_lambda_role.arn
  handler = "main.handler"
  runtime = "python3.9"
}

resource "aws_cloudwatch_event_rule" "every_day" {
  name = "covid-etl-five-minutes"
  description = "Run covid etl lambda every five minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "covid_etl_every_day_" {
  arn  = "${aws_lambda_function.covid_etl_lambda_func.arn}"
  rule = aws_cloudwatch_event_rule.every_day.name
  target_id = "covid_etl_lambda"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_covid_etl" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.covid_etl_lambda_func.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_day.arn}"
}
