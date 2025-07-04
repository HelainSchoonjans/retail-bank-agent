# bank customer support agent.

# IAM role for the Bedrock agent
resource "aws_iam_role" "bedrock_agent_role" {
  name = "bedrock-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })
}

# Basic berock/logging policy for the agent role
resource "aws_iam_role_policy" "bedrock_agent_policy" {
  name = "bedrock-agent-policy"
  role = aws_iam_role.bedrock_agent_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:*",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

data "aws_bedrock_foundation_model" "claude_haiku" {
  model_id = "anthropic.claude-3-haiku-20240307-v1:0"
}

# Bedrock agent
resource "aws_bedrockagent_agent" "bank_agent" {
  agent_name = "bank-agent"
  agent_resource_role_arn = aws_iam_role.bedrock_agent_role.arn
  foundation_model            = data.aws_bedrock_foundation_model.claude_haiku.model_arn
  
  instruction = <<-EOT
    You are a helpful banking assistant. Help customers with:
    - questions about the status of their recently opened bank account
    
    Always be professional, courteous and protect customer privacy.
    Do not share sensitive account information without proper verification.
    If unsure about any request, ask for clarification.
  EOT

}

module "knowledge-base" {
   source = "./knowledge-base"
   sid = local.env.sid
   environment = local.env.environment
   region_name = local.env.region_name
}

# Associate knowledge base with agent
resource "aws_bedrockagent_agent_knowledge_base_association" "agent_kb_association" {
  agent_id          = aws_bedrockagent_agent.bank_agent.id
  knowledge_base_id = module.knowledge-base.knowledge_base_id
  knowledge_base_state = "ENABLED"
  description      = "Use the knowledge base for any queries from the customer related to reason for this accountID status as pending"
}