data "aws_caller_identity" "current" {}

# Creates a collection
resource "aws_opensearchserverless_collection" "collection" {
  name             = "${var.sid}"
  type             = "VECTORSEARCH"
  standby_replicas = "DISABLED"

  depends_on = [aws_opensearchserverless_security_policy.encryption_policy]
}

# Creates an encryption security policy
resource "aws_opensearchserverless_security_policy" "encryption_policy" {
  name        = "${var.sid}-encryption-policy"
  type        = "encryption"
  description = "encryption policy for ${var.sid}"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${var.sid}"
        ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

# TODO in enterprise setup use VPC endpoints instead of public
# it is more expensive however.
# Creates a network security policy
resource "aws_opensearchserverless_security_policy" "network_policy" {
  name        = "${var.sid}-network-policy"
  type        = "network"
  description = "public access for dashboard, VPC access for collection endpoint"
  policy = jsonencode([
    ###References for using VPC endpoints
    # {
    #   Description = "VPC access for collection endpoint",
    #   Rules = [
    #     {
    #       ResourceType = "collection",
    #       Resource = [
    #         "collection/${var.sid}}"
    #       ]
    #     }
    #   ],
    #   AllowFromPublic = false,
    #   SourceVPCEs = [
    #     aws_opensearchserverless_vpc_endpoint.vpc_endpoint.id
    #   ]
    # },
    {
      Description = "Public access for dashboards and collection",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${var.sid}"
          ]
        },
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${var.sid}"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ])
}

# Creates a data access policy
resource "aws_opensearchserverless_access_policy" "data_access_policy" {
  name        = "${var.sid}-data-access-policy"
  type        = "data"
  description = "allow index and collection access"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/${var.sid}/*"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/${var.sid}"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        data.aws_caller_identity.current.arn,
        aws_iam_role.bedrock_kb_role.arn,
      ]
    }
  ])
}

resource "opensearch_index" "this" {
  name = local.aoss.vector_index

  index_knn = true

  lifecycle {
    ignore_changes = [ mappings ]
  }

  mappings = jsonencode({
    properties = {
      "${local.aoss.metadata_field}" = {
        type  = "text"
        index = false
      }

      "${local.aoss.text_field}" = {
        type  = "text"
        index = true
      }

      "${local.aoss.text_field}_CHUNK" = {
        type  = "text"
        index = true
      }

      "${local.aoss.vector_field}" = {
        type      = "knn_vector"
        dimension = "${local.aoss.vector_dimension}"
        method = {
          engine = "faiss"
          name   = "hnsw"
        }
      }
    }
  })
  # can be destroyed and recreated on changes in terraform
  force_destroy = true

  depends_on = [aws_opensearchserverless_collection.collection]
}