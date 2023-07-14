resource "aws_kms_key" "prototype_architecture_key" {
  description = "Key used for encrypting Lambda Env Vars, S3 buckets, etc for the prototyping spam and ham ML application."
  policy      = data.aws_iam_policy_document.key_policy.json
}

resource "aws_kms_alias" "prototype_architecture_key_alias" {
  name          = "alias/prototype-ham-spam-key"
  target_key_id = aws_kms_key.prototype_architecture_key.key_id
}

data "aws_iam_policy_document" "key_policy" {
  statement {
    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "s3.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = [var.trusted_role_arn, aws_iam_role.label_lambda_role.arn, aws_iam_role.model_lambda_role.arn, aws_iam_role.endpoint_query_lambda_role.arn, aws_iam_role.comprehend_data_access_role.arn]
    }
  }
}