resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "daily-trigger"
  description         = "Run covid etl lambda every day at 10AM UTC"
  schedule_expression = "cron(0 10 * * ? *)"
}

resource "aws_cloudwatch_event_target" "covid_etl_every_day" {
  arn       = aws_lambda_function.covid_etl_lambda_func.arn
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "covid_etl_lambda"
}

resource "aws_cloudwatch_event_rule" "five_minute_trigger" {
  name                = "five-minute-trigger"
  description         = "Run covid etl lambda every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "covid_etl_every_five_minutes" {
  arn       = aws_lambda_function.covid_etl_lambda_func.arn
  rule      = aws_cloudwatch_event_rule.five_minute_trigger.name
  target_id = "covid_etl_lambda"
}