# this file contains the infrastructure of the lambda function providing an action to our agent

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "newBankAccountStatus" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "newBankAccountStatus"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.12"
  timeout = 60

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.customer_account_status.name
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "newBankAccountStatus_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# lambda access to our dynamoDB database
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "newBankAccountStatus_dynamodb_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.customer_account_status.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# resource policy to ensure our function can be called by bedrock agents
resource "aws_lambda_permission" "bedrock_invoke" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.newBankAccountStatus.function_name
  principal     = "bedrock.amazonaws.com"
  # only the banking agent should access this function
  source_arn    = aws_bedrockagent_agent.bank_agent.agent_arn
}