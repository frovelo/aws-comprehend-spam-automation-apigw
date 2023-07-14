resource "aws_iam_role" "label_lambda_role" {
  name        = "label-lambda-role"
  description = "IAM Role for Comprehend Labeling Lambda."

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_role" "model_lambda_role" {
  name        = "model-lambda-role"
  description = "IAM Role for Comprehend Modeling Lambda."

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_role" "endpoint_query_lambda_role" {
  name        = "endpoint-query-lambda-role"
  description = "IAM Role for Comprehend Endpoint Query Lambda."

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_role" "comprehend_data_access_role" {
  name        = "comprehend-data-access-role"
  description = "IAM Role for Comprehend Data Access to S3."

  assume_role_policy = data.aws_iam_policy_document.comprehend_data_access_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "label_lambda_policy-label_lambda_role" {
  role       = aws_iam_role.label_lambda_role.name
  policy_arn = aws_iam_policy.label_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "model_lambda_policy-model_lambda_role" {
  role       = aws_iam_role.model_lambda_role.name
  policy_arn = aws_iam_policy.model_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "endpoint_query_lambda_policy-endpoint_query_lambda_role" {
  role       = aws_iam_role.endpoint_query_lambda_role.name
  policy_arn = aws_iam_policy.endpoint_query_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "comprehend_data_access_policy-comprehend_data_access_role" {
  role       = aws_iam_role.comprehend_data_access_role.name
  policy_arn = aws_iam_policy.comprehend_data_access_policy.arn
}

resource "aws_iam_policy" "label_lambda_policy" {
  name        = "label-lambda-policy"
  path        = "/"
  description = "IAM Policy for Comprehend Labeling Lambda."
  policy      = data.aws_iam_policy_document.label_lambda_policy_document.json
}

resource "aws_iam_policy" "model_lambda_policy" {
  name        = "model-lambda-policy"
  path        = "/"
  description = "IAM Policy for Comprehend Modeling Lambda."
  policy      = data.aws_iam_policy_document.model_lambda_policy_document.json
}

resource "aws_iam_policy" "endpoint_query_lambda_policy" {
  name        = "endpoint-query-lambda-policy"
  path        = "/"
  description = "IAM Policy for Comprehend Endpoint Query Lambda."
  policy      = data.aws_iam_policy_document.endpoint_query_lambda_policy_document.json
}

resource "aws_iam_policy" "comprehend_data_access_policy" {
  name        = "comprehend-data-access-policy"
  path        = "/"
  description = "IAM Policy for Comprehend data access to S3."
  policy      = data.aws_iam_policy_document.comprehend_data_access_policy_document.json
}

// Re-use
data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "comprehend_data_access_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["comprehend.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "label_lambda_policy_document" {
  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = [aws_s3_bucket.prototype_ham_spam_bucket.arn, "${aws_s3_bucket.prototype_ham_spam_bucket.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ListAliases",
    ]
    resources = [
      aws_kms_key.prototype_architecture_key.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "model_lambda_policy_document" {
  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = [aws_s3_bucket.prototype_ham_spam_bucket.arn, "${aws_s3_bucket.prototype_ham_spam_bucket.arn}/*"]
  }

  statement {
    actions   = ["comprehend:*"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ListAliases",
    ]
    resources = [
      aws_kms_key.prototype_architecture_key.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.comprehend_data_access_role.arn
    ]
  }
}

data "aws_iam_policy_document" "endpoint_query_lambda_policy_document" {
  statement {
    actions   = ["comprehend:*"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ListAliases"
    ]
    resources = [
      aws_kms_key.prototype_architecture_key.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "comprehend_data_access_policy_document" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"]
    effect    = "Allow"
    resources = [aws_s3_bucket.prototype_ham_spam_bucket.arn, "${aws_s3_bucket.prototype_ham_spam_bucket.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ListAliases",
    ]
    resources = [
      aws_kms_key.prototype_architecture_key.arn,
    ]
  }
}

####################################
# API GATEWAY RESOURCE PERMISSIONS #
####################################
data "aws_iam_policy_document" "api_gateway_pd" {
  statement {
    actions   = ["execute-api:Invoke"]
    resources = ["*"]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}