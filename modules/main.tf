locals {
  template_vars = {
    account_id                = var.account_id
    region                    = var.region
    endpoint_query_lambda_uri = aws_lambda_function.endpoint_query_lambda.invoke_arn
  }
}