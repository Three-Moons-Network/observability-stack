# Observability Stack

Reusable CloudWatch observability for serverless workloads (Lambda, API Gateway, DynamoDB, S3). Deploy once, use across multiple Lambda functions and APIs. Includes configurable dashboards, environment-specific alarm thresholds, and severity-based SNS alert routing (email, SMS, Slack, PagerDuty).

Built as a reference implementation by [Three Moons Network](https://threemoonsnetwork.net) — an AI consulting practice helping small businesses deploy production-grade infrastructure.

## Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                    Observability Stack                                 │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────┐    │
│  │ CloudWatch Dashboard                                         │    │
│  │  • Lambda: invocations, errors, duration, cold starts        │    │
│  │  • API Gateway: requests, 5xx, latency percentiles           │    │
│  │  • DynamoDB: capacity consumed, throttles, errors            │    │
│  │  • S3: objects, size, requests (optional)                    │    │
│  └──────────────────────────────────────────────────────────────┘    │
│                                                                        │
│  ┌──────────────────────┐          ┌──────────────────────┐           │
│  │ CloudWatch Alarms    │          │ SNS Topic Routing    │           │
│  │                      │          │                      │           │
│  │ Lambda Errors        │          │ Warning Topic        │           │
│  │ Lambda Duration p99  │  ────→   │ (email, SMS, Slack)  │  ──→      │
│  │ Lambda Throttles     │          │                      │           │
│  │                      │          │ Critical Topic       │           │
│  │ API Gateway 5xx      │  ────→   │ (SMS priority,       │  ──→      │
│  │ API Gateway Latency  │          │  PagerDuty)          │           │
│  │                      │          │                      │           │
│  │ DynamoDB Throttles   │  ────→   │                      │           │
│  │ DynamoDB Errors      │          └──────────────────────┘           │
│  └──────────────────────┘                                             │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────┐    │
│  │ CloudWatch Logs Insights (Pre-built Queries)               │    │
│  │  • Error rate by 5-minute intervals                         │    │
│  │  • Cold start detection                                     │    │
│  │  • Latency percentiles (p50, p99, p999)                     │    │
│  │  • Slow requests (>5sec)                                    │    │
│  │  • Request tracing by ID                                    │    │
│  └──────────────────────────────────────────────────────────────┘    │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

## What It Provides

| Component | Purpose | Metrics |
|-----------|---------|---------|
| **Dashboard** | Multi-service metrics visualization | Lambda, API GW, DynamoDB, S3 (configurable) |
| **Alarms** | Detect anomalies and errors | Error rate, latency, throttles (environment-specific) |
| **SNS Routing** | Alert multiplexing by severity | Warning (email/Slack) + Critical (SMS/PagerDuty) |
| **Logs Insights** | Pre-built debugging queries | Error rates, cold starts, latency, tracing |

## Quick Start

### Prerequisites

- AWS account with Lambda, API Gateway, and/or DynamoDB
- Terraform >= 1.5
- AWS CLI configured

### 1. Clone and configure

```bash
git clone git@github.com:Three-Moons-Network/observability-stack.git
cd observability-stack

# Start with development config
cp examples/dev.tfvars terraform.tfvars
# OR production config
cp examples/prod.tfvars terraform.tfvars

# Edit for your environment
vim terraform.tfvars
```

### 2. Validate

```bash
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

### 3. Plan and apply

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

Output includes dashboard URL and SNS topic ARNs.

### 4. Confirm SNS subscriptions

AWS sends confirmation emails to alert addresses. **Click the confirmation link** to activate subscriptions.

```bash
# Check subscription status
aws sns list-subscriptions-by-topic --topic-arn arn:aws:sns:region:account:project-warnings
```

## Project Structure

```
.
├── main.tf                          # Root composition of modules
├── variables.tf                     # Input variables
├── outputs.tf                       # Dashboard and alert topic outputs
├── terraform.tfvars.example         # Example config
├── backend.tf                       # Remote state config (commented)
├── .github/workflows/ci.yml         # GitHub Actions CI
├── examples/
│   ├── dev.tfvars                   # Dev: relaxed thresholds
│   └── prod.tfvars                  # Prod: strict thresholds + SMS/PagerDuty
├── modules/
│   ├── dashboard/                   # CloudWatch dashboard (Lambda, API GW, DynamoDB, S3)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alarms/                      # CloudWatch alarms (configurable by environment)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── sns-routing/                 # SNS topics with severity-based routing
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── log-insights/                # CloudWatch Logs Insights query definitions
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── .gitignore
└── README.md
```

## Alarm Thresholds

Thresholds differ by environment to balance alerting sensitivity:

### Development (examples/dev.tfvars)

| Alarm | Threshold | Notes |
|-------|-----------|-------|
| Lambda errors | > 10 per 5 min | High tolerance for development iteration |
| Lambda duration p99 | > 30 seconds | Generous for local/test code |
| API Gateway 5xx | > 5 per 5 min | More lenient for staging |
| API Gateway p99 latency | > 10 seconds | Lower sensitivity |
| DynamoDB errors | > 10 per 5 min | High tolerance |

### Production (examples/prod.tfvars)

| Alarm | Threshold | Escalation |
|-------|-----------|-----------|
| Lambda errors | > 1 per 5 min | Email + SMS |
| Lambda duration p99 | > 5 seconds | Email + SMS |
| API Gateway 5xx | > 1 per 5 min | Email + SMS + PagerDuty |
| API Gateway p99 latency | > 2 seconds | Email + SMS |
| DynamoDB errors | > 1 per 5 min | Email + SMS |

Customize thresholds in tfvars:

```hcl
lambda_error_threshold           = 1      # < 1 = strict, > 5 = relaxed
lambda_duration_threshold_ms     = 5000   # Lower = stricter
api_gateway_latency_threshold_ms = 2000   # Lower = stricter
```

## SNS Alert Routing

Severity-based routing ensures appropriate urgency:

### Warning-Level Alerts

Default: Email + optional Slack

Used for:
- Elevated error rates (but below critical threshold)
- Latency increases
- Non-critical service degradation

```hcl
warning_email_addresses = ["ops@example.com"]
enable_slack            = true
slack_webhook_url       = "https://hooks.slack.com/.../..."
```

### Critical-Level Alerts

Default: Email + SMS + optional PagerDuty

Used for:
- Service outages
- Critical errors exceeding threshold
- Throttling/capacity issues

```hcl
critical_email_addresses = ["ops@example.com", "cto@example.com"]
critical_phone_numbers   = ["+14155552671"]  # E.164 format
enable_pagerduty         = true
pagerduty_webhook_url    = "https://events.pagerduty.com/..."
```

## CloudWatch Logs Insights Queries

Pre-built queries for debugging and analysis:

### Error Rate

Find error count over time:

```
fields @timestamp, @message, @error
| filter @error like /./
| stats count() as error_count by bin(5m)
```

### Cold Start Detection

Identify cold starts (initialization duration > 0):

```
fields @timestamp, @duration, @initDuration
| filter @initDuration > 0
| stats count() as cold_starts, avg(@duration) as avg_duration by bin(5m)
```

### Latency Percentiles

Real-time latency analysis:

```
fields @timestamp, @duration
| stats avg(@duration) as avg_ms, pct(@duration, 50) as p50_ms,
        pct(@duration, 99) as p99_ms, pct(@duration, 99.9) as p999_ms by bin(1m)
```

### Slow Requests

Find requests slower than 5 seconds:

```
fields @timestamp, @message, @duration, @requestId
| filter @duration > 5000
| sort @duration desc
| limit 100
```

### Trace Request by ID

Debug a specific request across all logs:

```
fields @timestamp, @message, @duration, @requestId
| filter @requestId = "REQUEST_ID_HERE"
| sort @timestamp asc
```

Run these via AWS Console:
1. CloudWatch → Log Groups → Select log group
2. Logs Insights → Paste query → Run

## Cost Estimate

For a typical serverless workload (< 1M Lambda invocations/month):

| Component | Monthly Cost |
|-----------|--------------|
| CloudWatch Logs (Lambda output) | ~$1-3 (depends on volume) |
| Dashboard | ~$0.30 |
| Alarms (10 alarms) | ~$0.10 |
| SNS (email/SMS) | ~$0-5 (email free, SMS $0.00645/msg) |
| **Total** | ~$2-9 |

**Cost optimization:**
- Reduce `log_retention_days` to 7 (default 14) — saves ~$0.50/month
- Disable `enable_s3_metrics` if not needed — saves metrics API calls
- Use email over SMS for non-critical alerts — email is free

## Customization

### Create Environment-Specific Stacks

Deploy separate dashboards for dev/staging/prod with different thresholds:

```bash
# Dev environment
terraform workspace new dev
terraform apply -var-file=examples/dev.tfvars

# Prod environment
terraform workspace new prod
terraform apply -var-file=examples/prod.tfvars
```

### Add Custom Metrics

Subscribe Lambda functions to SNS topics and publish custom metrics:

```python
import boto3
import json

cloudwatch = boto3.client('cloudwatch')

def lambda_handler(event, context):
    # Your business logic
    ...

    # Publish custom metric
    cloudwatch.put_metric_data(
        Namespace='MyApp',
        MetricData=[{
            'MetricName': 'ProcessingTime',
            'Value': processing_time_ms,
            'Unit': 'Milliseconds'
        }]
    )
```

Then add to dashboard:

```hcl
# In modules/dashboard/main.tf, add to dashboard_body widgets:
{
  type = "metric"
  properties = {
    metrics = [["MyApp", "ProcessingTime"]]
    period = 300
    stat   = "Average"
    region = "us-east-1"
    title  = "Custom Processing Time"
  }
}
```

### Slack Message Formatting

For prettier Slack messages, deploy a Lambda to transform SNS messages:

```python
# slack-formatter.py
import json
import urllib3
import os

http = urllib3.PoolManager()

def lambda_handler(event, context):
    sns_message = json.loads(event['Records'][0]['Sns']['Message'])

    slack_message = {
        'text': f"CloudWatch Alarm: {sns_message['AlarmName']}",
        'blocks': [
            {
                'type': 'section',
                'text': {
                    'type': 'mrkdwn',
                    'text': f"*{sns_message['StateReason']}*"
                }
            },
            {
                'type': 'section',
                'text': {
                    'type': 'mrkdwn',
                    'text': f"```{sns_message.get('NewStateReason', 'No details')}```"
                }
            }
        ]
    }

    http.request(
        'POST',
        os.environ['SLACK_WEBHOOK'],
        body=json.dumps(slack_message),
        headers={'Content-Type': 'application/json'}
    )

    return {'statusCode': 200}
```

Then subscribe the Lambda to SNS topics.

### Enable Per-Metric Filters

Create metric filters to alert on specific log patterns:

```bash
aws logs put-metric-filter \
  --log-group-name /aws/lambda/my-function \
  --filter-name "error-filter" \
  --filter-pattern "[ERROR]" \
  --metric-transformations \
    metricName=CustomErrors,metricNamespace=MyApp,metricValue=1
```

## Integration with Other Stacks

### Use with terraform-aws-starter

The `terraform-aws-starter` provides account-level alerting. This stack provides application-level dashboards and alarms:

```hcl
# terraform-aws-starter/main.tf creates SNS topic
module "alerting" {
  source = "./modules/alerting"
  # ... outputs ops_alerts_topic_arn
}

# observability-stack uses this topic
terraform apply -var="alarm_sns_topic_arns=[aws_sns_topic.ops_alerts.arn]"
```

### Use with Lambda Functions

Reference dashboard and alarm outputs in Lambda stack:

```bash
# Get dashboard URL
DASHBOARD=$(terraform output -raw dashboard_name)
echo "View metrics: https://console.aws.amazon.com/cloudwatch/home#dashboards:name=$DASHBOARD"

# Get alarm topics
CRITICAL_TOPIC=$(terraform output -raw critical_topic_arn)
echo "Critical alerts: $CRITICAL_TOPIC"
```

## Known Limitations

1. **Slack requires Lambda transformer**: SNS native HTTPS doesn't format messages prettily. Deploy a Lambda to reformat (example provided above).

2. **Log Insights queries are static**: This module provides query definitions, not saved queries (AWS Terraform provider doesn't support this yet). Use AWS CLI to create saved queries:

```bash
aws logs put-query-definition \
  --name "error-rate-${PROJECT}" \
  --log-group-name-list "/aws/lambda/my-function" \
  --query-string "fields @timestamp, @error | filter @error like /./  | stats count() by bin(5m)"
```

3. **Cross-service correlation**: This stack monitors individual services. For end-to-end tracing, consider adding AWS X-Ray.

4. **Metric aggregation**: Dashboard aggregates across all functions. For per-function dashboards, deploy separate stacks per function with service filters.

## Tear Down

```bash
terraform destroy
```

Removes all alarms, dashboards, SNS topics, and log groups. **Does not** affect CloudTrail or other account-level resources from `terraform-aws-starter`.

## Next Steps

After deploying observability:

1. **Create custom dashboards** per team or service
2. **Set up on-call rotation** in PagerDuty
3. **Configure log retention** based on compliance needs
4. **Add distributed tracing** with X-Ray or Jaeger
5. **Implement cost tracking** with Cost Anomaly Detection

## License

MIT

## Author

Charles Harvey ([linuxlsr](https://github.com/linuxlsr)) — [Three Moons Network LLC](https://threemoonsnetwork.net)
