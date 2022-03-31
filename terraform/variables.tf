variable "covid-python-layers" {
  type = list(string)
}

variable "dynamo-table-name" {
  type = string
}

variable "sns-topic-arn" {
  type = string
}

variable "sns-email-endpoint" {
  type = string
}