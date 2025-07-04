
locals {
  aoss = {
    vector_index     = "bedrock-knowledge-base-default-index"
    vector_field     = "bedrock-knowledge-base-default-vector"
    text_field       = "AMAZON_BEDROCK_TEXT"
    metadata_field   = "AMAZON_BEDROCK_METADATA"
    vector_dimension = 1024
  }
}