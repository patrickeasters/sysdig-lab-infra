# resource "random_password" "metric_stream_external_id" {
#   length = 30
# }

# resource "aws_cloudformation_stack" "metric_stream" {
#   name = "sysdig-metric-stream"

#   parameters = {
#     ApiKey = var.sysdig_monitor_api_token
#     SysdigSite = var.sysdig_monitor_url
#     Regions = var.aws_region
#     SysdigAwsAccountId = var.sysdig_aws_account_id
#     SysdigExternalId = random_password.metric_stream_external_id.result
#   }

#   capabilities = ["CAPABILITY_NAMED_IAM"]

#   template_url = "https://cf-templates-cloudwatch-metric-streams.s3-eu-west-1.amazonaws.com/latest/cloudwatch-metric-stream.yaml"
# }

# resource "aws_kinesis_firehose_delivery_stream" "sysdig-monitor" {
#   name        = "sysdig-monitor"
#   destination = "http_endpoint"

#   s3_configuration {
#     role_arn           = aws_iam_role.firehose.arn
#     bucket_arn         = aws_s3_bucket.bucket.arn
#     buffer_size        = 10
#     buffer_interval    = 400
#     compression_format = "GZIP"
#   }

#   http_endpoint_configuration {
#     url                = "${var.sysdig_monitor_url}api/awsmetrics/v1/input"
#     name               = "Sysdig"
#     access_key         = var.sysdig_monitor_api_token
#     buffering_size     = 5
#     buffering_interval = 60
#     role_arn           = aws_iam_role.firehose.arn
#     s3_backup_mode     = "FailedDataOnly"

    
#   }
# }