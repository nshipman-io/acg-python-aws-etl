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

resource "aws_iam_role_policy_attachment" "covid_etl_lambda_role_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = "${aws_iam_role.covid_etl_lambda_role.name}"
}

locals {
  lambda_src_path = "${path.module}/src"
}
resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.lambda_src_path, "*.py"),
      fileset(local.lambda_src_path, "requirements.txt"),
  ):
    filename => filemd5("${local.lambda_src_path}/${filename}")
  }
}

data "archive_file" "covid_lambda_package" {
  type = "zip"
  source_dir = local.lambda_src_path
  output_path = "${random_uuid.lambda_src_hash.result}.zip"
  depends_on = [null_resource.install_dependencies]
  excludes = [
    "__pycache__",
    "Pipfile"
  ]
}

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ${local.lambda_src_path}/requirements.txt -t ${path.module}/ --upgrade"
  }
  triggers = {
    dependencies_versions =  filemd5("${local.lambda_src_path}/requirements.txt")
  }
}

resource "aws_lambda_function" "covid_etl_lambda_func" {
  function_name = "covid_etl_lambda_function"

  filename = data.archive_file.covid_lambda_package.output_path
  source_code_hash = data.archive_file.covid_lambda_package.output_base64sha256

  role = aws_iam_role.covid_etl_lambda_role.arn
  handler = "main.handler"
  runtime = "python3.9"
}

resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name = "covid-etl-five-minutes"
  description = "Run covid etl lambda every five minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "covid_etl_every_day_" {
  arn  = "${aws_lambda_function.covid_etl_lambda_func.arn}"
  rule = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = "covid_etl_lambda"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_covid_etl" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.covid_etl_lambda_func.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_five_minutes.arn}"
}

resource "aws_sns_topic" "covid_table_updated" {
  name = "covid-table-updated"
}

resource "aws_sns_topic_subscription" "covid_etl_updated" {
  endpoint  = "norman@nshipman.io"
  protocol  = "email"
  topic_arn = "${aws_sns_topic.covid_table_updated.arn}"
}