output "aws_iam_role_name" {
    value = aws_iam_role.sysdig_to_cloudwatch.name
}

data "aws_caller_identity" "current" {}

output "aws_account_id" {
    value = data.aws_caller_identity.current.account_id
}
