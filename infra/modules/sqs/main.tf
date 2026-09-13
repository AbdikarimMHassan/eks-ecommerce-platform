resource "aws_sqs_queue" "dlq" {
  name                      = "${var.environment}-ecommerce-dlq"
  message_retention_seconds = 1209600

  tags = {
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "main" {
  name                       = "${var.environment}-ecommerce-orders"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 30
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Environment = var.environment
  }
}