output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.dashboard.dashboard_name
}

output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = module.dashboard.dashboard_arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.dashboard.log_group_name
}

output "warnings_topic_arn" {
  description = "SNS topic ARN for warning-level alerts"
  value       = module.sns_routing.warnings_topic_arn
}

output "critical_topic_arn" {
  description = "SNS topic ARN for critical-level alerts"
  value       = module.sns_routing.critical_topic_arn
}

output "lambda_errors_alarm_arn" {
  description = "Lambda errors alarm ARN"
  value       = module.alarms.lambda_errors_alarm_arn
}

output "api_gateway_5xx_alarm_arn" {
  description = "API Gateway 5xx alarm ARN"
  value       = module.alarms.api_gateway_5xx_alarm_arn
}

output "dynamodb_read_throttles_alarm_arn" {
  description = "DynamoDB read throttles alarm ARN"
  value       = module.alarms.dynamodb_read_throttles_alarm_arn
}
