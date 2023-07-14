resource "aws_s3_bucket" "prototype_ham_spam_bucket" {
  bucket = "prototype-ham-spam-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prototype_ham_spam_bucket_sse" {
  bucket = aws_s3_bucket.prototype_ham_spam_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.prototype_architecture_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "restrict_access_to_s3_bucket" {
  bucket = aws_s3_bucket.prototype_ham_spam_bucket.id
  policy = data.aws_iam_policy_document.restrict_access_to_s3_bucket.json
}

data "aws_iam_policy_document" "restrict_access_to_s3_bucket" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.trusted_role_arn, aws_iam_role.label_lambda_role.arn, aws_iam_role.model_lambda_role.arn, aws_iam_role.endpoint_query_lambda_role.arn, aws_iam_role.comprehend_data_access_role.arn]
    }

    actions = ["s3:*"]

    resources = [aws_s3_bucket.prototype_ham_spam_bucket.arn, "${aws_s3_bucket.prototype_ham_spam_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.prototype_ham_spam_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.model_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "Input/"
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.s3_invoke_model_lambda]
}