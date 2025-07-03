
# openapi bucket access policy for my agent
resource "aws_iam_role_policy" "agent_s3_access" {
  name = "agent_s3_access"
  role = aws_iam_role.bedrock_agent_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.openapi_bucket_name}",
          "arn:aws:s3:::${local.openapi_bucket_name}/*"
        ]
      }
    ]
  })
}

# agent actions defined through a s3 bucket containing openapi specs plus references to my lambda functions
resource "aws_bedrockagent_agent_action_group" "openapi_action_group" {
  agent_id = aws_bedrockagent_agent.bank_agent.id
  action_group_name = "openapi_actions"
  agent_version = "DRAFT"
  action_group_executor {
    lambda = aws_lambda_function.newBankAccountStatus.arn
  }
  
  api_schema {
    s3 {
        s3_bucket_name = local.openapi_bucket_name
        s3_object_key      = "newBankAccountStatus.yaml"
    }
  }
}