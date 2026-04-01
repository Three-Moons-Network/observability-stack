output "warnings_topic_arn" {
  description = "SNS topic ARN for warning-level alerts"
  value       = aws_sns_topic.warnings.arn
}

output "warnings_topic_name" {
  description = "SNS topic name for warning-level alerts"
  value       = aws_sns_topic.warnings.name
}

output "critical_topic_arn" {
  description = "SNS topic ARN for critical-level alerts"
  value       = aws_sns_topic.critical_alerts.arn
}

output "critical_topic_name" {
  description = "SNS topic name for critical-level alerts"
  value       = aws_sns_topic.critical_alerts.name
}
