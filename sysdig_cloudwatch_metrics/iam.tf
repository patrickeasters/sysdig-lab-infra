# Sysdig <-> Stream Ingestion

resource "aws_iam_role" "sysdig_to_cloudwatch" {
  name                = "sysdig_metrics_stream_ingest"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${local.sysdig_aws_account}:root"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "${local.stream_external_id}"
                }
            }
        }
    ]
}  
POLICY
}

resource "aws_iam_role_policy" "cloudwatch_read" {
  name = "cloudwatch_read"
  role = aws_iam_role.sysdig_to_cloudwatch.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "firehose:DescribeDeliveryStream"
            ],
            "Effect": "Allow",
            "Resource": "${aws_kinesis_firehose_delivery_stream.stream.arn}"
        },
        {
            "Action": [
                "cloudwatch:GetMetricStream",
                "cloudwatch:ListMetricStreams",
                "cloudwatch:ListTagsForResource"
            ],
            "Effect": "Allow",
            "Resource": "${aws_cloudwatch_metric_stream.stream.arn}"
        },
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketTagging",
                "s3:GetObject",
                "s3:GetObjectAttributes"
            ],
            "Effect": "Allow",
            "Resource": [
                "${aws_s3_bucket.stream_fallback.arn}",
                "${aws_s3_bucket.stream_fallback.arn}/*"
            ]
        }
    ]
}
POLICY
}

# Stream -> S3

resource "aws_iam_role" "firehose_to_s3" {
  name                = "sysdig_firehose_service_role"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "firehose.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy" "firehose_read_s3" {
  name = "s3_read"
  role = aws_iam_role.firehose_to_s3.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject",
                "s3:PutBucketTagging"
            ],
            "Resource": [
                "${aws_s3_bucket.stream_fallback.arn}",
                "${aws_s3_bucket.stream_fallback.arn}/*"
            ],
            "Effect": "Allow"
        }
    ]
}
POLICY
}

# Cloudwatch -> Stream

resource "aws_iam_role" "cloudwatch_to_firehose" {
  name                = "sysdig_cloudwatch_service_role"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "streams.metrics.cloudwatch.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy" "kinesis_write" {
  name = "kinesis_write"
  role = aws_iam_role.cloudwatch_to_firehose.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": [
                "${aws_kinesis_firehose_delivery_stream.stream.arn}"
            ],
            "Effect": "Allow"
        }
    ]
}
POLICY
}
