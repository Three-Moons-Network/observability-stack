# Development Environment — Relaxed Thresholds

region      = "us-east-1"
project     = "mycompany"
environment = "dev"

# Only email alerts for dev
warning_email_addresses  = ["ops@example.com"]
critical_email_addresses = ["ops@example.com"]
critical_phone_numbers   = []

# Slack optional for dev
enable_slack      = false
slack_webhook_url = ""

# Relaxed thresholds for dev
lambda_error_threshold           = 10     # Higher threshold, noisier environment
lambda_duration_threshold_ms     = 30000  # 30 seconds (generous for dev)

api_gateway_5xx_threshold        = 5      # More lenient
api_gateway_latency_threshold_ms = 10000  # 10 seconds

dynamodb_error_threshold         = 10     # Higher tolerance

# Dashboard — 5-minute aggregation for quick iteration
dashboard_metric_period = 300

# Log retention — shorter for dev cost savings
log_retention_days = 7
