resource "aws_dynamodb_table" "covid-db" {
  hash_key = "ID"
  range_key = "Date"
  name = "CovidData"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "Date"
    type = "S"
  }

}