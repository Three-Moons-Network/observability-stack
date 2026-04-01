output "log_group_name" {
  description = "CloudWatch log group name for Insights"
  value       = try(aws_cloudwatch_log_group.insights[0].name, null)
}

# These outputs are defined inline in main.tf for query definitions and guide
