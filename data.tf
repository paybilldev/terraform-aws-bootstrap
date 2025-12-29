################################################
## imports
################################################
data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

################################################
## iam
################################################
data "aws_iam_policy_document" "policy" {
  ## Enforce SSL/TLS on all objects
  statement {
    sid    = "enforce-tls"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = ["${local.bucket_arn}/*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "inventory-and-analytics"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${local.bucket_arn}/*"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [local.bucket_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}