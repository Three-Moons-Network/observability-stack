output "lambda_errors_alarm_arn" {
  description = "Lambda errors alarm ARN (if enabled)"
  value       = try(aws_cloudwatch_metric_alarm.lambda_errors[0].arn, null)
}

output "lambda_duration_alarm_arn" {
  description = "Lambda duration p99 alarm ARN (if enabled)"
  value       = try(aws_cloudwatch_metric_alarm.lambda_duration_p99[0].arn, null)
}

output "api_gateway_5xx_alarm_arn" {
  description = "API Gateway 5xx alarm ARN (if enabled)"
  value       = try(aws_cloudwatch_metric_alarm.api_gateway_5xx[0].arn, null)
}

output "dynamodb_read_throttles_alarm_arn" {
  description = "DynamoDB read throttles alarm ARN (if enabled)"
  value       = try(aws_cloudwatch_metric_alarm.dynamodb_read_throttles[0].arn, null)
}

output "dynamodb_write_throttles_alarm_arn" {
  description = "DynamoDB write throttles alarm ARN (if enabled)"
  value       = try(aws_cloudwatch_metric_alarm.dynamodb_write_throttles[0].arn, null)
}
