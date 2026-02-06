resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/security"
  retention_in_days = 90
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "aws-security-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail-logs.bucket
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_logging                = true
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail-role.arn

   depends_on = [
    aws_s3_bucket_policy.cloudtrail-logs
  ]
}