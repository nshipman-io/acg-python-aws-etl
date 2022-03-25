resource "aws_dynamodb_table" "covid-db" {
  hash_key = "date"
  name = "CovidData"
  billing_mode = "PAY_PER_REQUEST"


  attribute {
    name = "date"
    type = "S"
  }

}