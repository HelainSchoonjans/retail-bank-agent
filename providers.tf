
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Environment     = local.env.environment
      Service         = local.env.sid
    }
  }
}

terraform {
  backend "s3" {
    # create this bucket manually
    bucket = "terraform-state-creative-tech"
    key    = "retail-ai.tfstate"
    region = "eu-west-1"

    # Enable state locking
    # create this table manually with partitionKey LockID
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
