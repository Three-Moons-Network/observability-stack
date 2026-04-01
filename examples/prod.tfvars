# Production Environment — Strict Thresholds and SMS Alerts

region      = "us-east-1"
project     = "mycompany"
environment = "prod"

# Multiple alert channels for production
warning_email_addresses = [
  "ops@example.com",
  "devops@example.com"
]

critical_email_addresses = [
  "ops@example.com",
  "devops@example.com",
  "cto@example.com"
]

# SMS for critical production issues
critical_phone_numbers = [
  "+14155552671", # On-call engineer
  "+14155552672"  # Secondary on-call
]

# Enable SMS for warnings too
enable_warning_sms    = true
warning_phone_numbers = ["+14155552671"]

# Slack integration for visibility
enable_slack      = true
slack_webhook_url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# PagerDuty for critical escalation
enable_pagerduty      = true
pagerduty_webhook_url = "https://events.pagerduty.com/v2/enqueue"

# Strict thresholds for production
lambda_error_threshold       = 1    # Alert immediately on errors
lambda_duration_threshold_ms = 5000 # 5 second p99 latency limit

api_gateway_5xx_threshold        = 1    # Any 5xx errors
api_gateway_latency_threshold_ms = 2000 # 2 second p99 latency limit

dynamodb_error_threshold = 1 # Strict error monitoring

# Dashboard — 1-minute granularity for real-time insight
dashboard_metric_period = 60

# Log retention — longer for audit and compliance
log_retention_days = 90
