resource "aws_api_gateway_rest_api" "api" {
  name        = "EndpointQueryAPIGW"
  description = "API GW for querying a Comprehend Endpoint. This API GW has a GET method with lambda proxy integration acting as a Comprehend Endpoint query engine."
  policy      = data.aws_iam_policy_document.api_gateway_pd.json
  body        = templatefile("${path.module}/src/json/swagger.json", local.template_vars)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  stage_description = "Initial stage deployment."

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  stage_name           = "v1"
  rest_api_id          = aws_api_gateway_rest_api.api.id
  deployment_id        = aws_api_gateway_deployment.api_deployment.id
  xray_tracing_enabled = true
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = "v1"
  }

  depends_on = [aws_api_gateway_stage.stage]
}

resource "aws_api_gateway_method_settings" "api_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "v1"
  method_path = "*/*"

  settings {
    # metrics_enabled = true
    # logging_level   = "ERROR"
  }

  depends_on = [aws_api_gateway_stage.stage]
}
