
resource "aws_dynamodb_table" "customer_account_status" {
  name           = "customerAccountStatus"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "AccountID"

  attribute {
    name = "AccountID"
    type = "N"
  }
}

# let's insert a few rows in our table:

resource "aws_dynamodb_table_item" "customer_account_first_item" {
  table_name = aws_dynamodb_table.customer_account_status.name
  hash_key   = aws_dynamodb_table.customer_account_status.hash_key

  item = jsonencode({
    AccountID = {N = "5555"}
    AccountName = {S = "John"}  
    AccountStatus = {S = "Active"}
    Reason = {S = "Active"}
  })
}

resource "aws_dynamodb_table_item" "customer_account_second_item" {
  table_name = aws_dynamodb_table.customer_account_status.name
  hash_key   = aws_dynamodb_table.customer_account_status.hash_key

  item = jsonencode({
    AccountID = {N = "6666"}
    AccountName = {S = "Thomas"}  
    AccountStatus = {S = "Pending"}
    Reason = {S = "InvalidIdentification"}
  })
}

resource "aws_dynamodb_table_item" "customer_account_third_item" {
  table_name = aws_dynamodb_table.customer_account_status.name
  hash_key   = aws_dynamodb_table.customer_account_status.hash_key

  item = jsonencode({
    AccountID = {N = "7777"}
    AccountName = {S = "Manju"}  
    AccountStatus = {S = "Pending"}
    Reason = {S = "InvalidAddressProof"}
  })
}