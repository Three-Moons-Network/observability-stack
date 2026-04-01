output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.this.dashboard_name
}

output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = "arn:aws:cloudwatch::${data.aws_caller_identity.current.account_id}:dashboard/${aws_cloudwatch_dashboard.this.dashboard_name}"
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = try(aws_cloudwatch_log_group.application[0].name, null)
}

data "aws_caller_identity" "current" {}
