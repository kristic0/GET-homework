resource "aws_sns_topic" "past_midnight_topic" {
  name = "PastMidnightTopic"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_sns_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "sns_publish_policy" {
  name = "sns_publish"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = aws_sns_topic.past_midnight_topic.arn
    }]
  })
}

data "archive_file" "code_arch" {
  type        = "zip"
  source_file = "${path.module}/lambda/send.py"
  output_path = "${path.module}/lambda/function.zip"
}

resource "aws_lambda_function" "send_msg_function" {
  filename      = data.archive_file.code_arch.output_path
  function_name = "msg_send_lf"
  role          = aws_iam_role.lambda_role.arn
  handler       = "send.lambda_handler"

  runtime          = "python3.14"
  source_code_hash = data.archive_file.code_arch.output_base64sha256

  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.past_midnight_topic.arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "daily_1am" {
  name                = "every-day-1am"
  schedule_expression = "cron(0 1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule = aws_cloudwatch_event_rule.daily_1am.name
  arn  = aws_lambda_function.send_msg_function.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_msg_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_1am.arn
}