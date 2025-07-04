terraform {
  required_providers {
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.3.0"
    }
  }
}

provider "opensearch" {
  url        = aws_opensearchserverless_collection.collection.collection_endpoint
  aws_region = var.region_name

  healthcheck = false
}