resource "aws_cloudwatch_event_rule" "cron_invoke_label_lambda" {
  name        = "cron-invoke-label-lambda"
  description = "Schedule to trigger a new Comprehend Model training once a day."

  schedule_expression = "cron(0 6 * * ? *)" // Every day, 12 PM
}

resource "aws_cloudwatch_event_target" "label_lambda" {
  rule      = aws_cloudwatch_event_rule.cron_invoke_label_lambda.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.label_lambda.arn
}

# Temp event for triggering an event when training is complete?
# {
#   "source": [
#     "aws.codecommit"
#   ],
#   "detail-type": [
#     "AWS API Call via CloudTrail"
#   ],
#   "detail": {
#     "eventSource": [
#       "codecommit.amazonaws.com"
#     ]
#   }
# }