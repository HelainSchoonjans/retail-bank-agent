# creates a bucket with the openapi description of our custom action

resource "aws_s3_bucket" "accountstatusopenapi" {
  bucket = "accountstatusopenapi"
}

resource "aws_s3_bucket_public_access_block" "accountstatusopenapi" {
  bucket = aws_s3_bucket.accountstatusopenapi.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "accountstatusopenapi" {
  bucket = aws_s3_bucket.accountstatusopenapi.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "openapi_spec" {
  bucket = aws_s3_bucket.accountstatusopenapi.id
  key    = "newBankAccountStatus.yaml"
  source = "newBankAccountStatus.yaml"
  etag   = filemd5("newBankAccountStatus.yaml")
}