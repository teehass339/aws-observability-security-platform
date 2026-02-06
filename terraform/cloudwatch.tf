resource "aws_cloudwatch_log_metric_filter" "root-usage" {
  name           = "RootAccountUsage"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokeBy NOT EXISTS && $.eventType != \"AwsServiceEvent\"}"
  metric_transformation {
    name      = "RootAccountUsageCount"
    namespace = "Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root-usage-alarm" {
  alarm_name          = "RootAccountUsageDetected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "Security"
  metric_name         = aws_cloudwatch_log_metric_filter.root-usage.metric_transformation[0].name
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alert when root account is used"
  alarm_actions       = [aws_sns_topic.security-alerts.arn]
}

resource "aws_cloudwatch_log_metric_filter" "iam-changes" {
  name           = "IAMPolicyChanges"
  pattern        = "{ ($.eventName = \"PutUserPolicy\") || ($.eventName = \"AttachRolePolicy\") || ($.eventName = \"CreatePolicy\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name      = "IAMPolicyChangeCount"
    namespace = "Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_changes-alarm" {
  alarm_name          = "IAMChangesDetected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.iam-changes.metric_transformation[0].name
  period              = 300
  alarm_description   = "Alert when IAM change is detected"
  statistic           = "Sum"
  namespace           = "Security"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.security-alerts.arn]
}

resource "aws_cloudwatch_log_metric_filter" "failed-api-calls" {
  name           = "FailedAPICalls"
  pattern        = "{ ($.errorCode = \"AccessDenied\") || ($.errorCode= \"UnAuthorizedOperation\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name      = "FailedAPICallCount"
    namespace = "Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "failed-api-calls-alarm" {
  alarm_name          = "FailedAPICallsDetected"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.failed-api-calls.metric_transformation[0].name
  namespace           = "Security"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert when Failed Api calls are detected"
  alarm_actions       = [aws_sns_topic.security-alerts.arn]
}

resource "aws_cloudwatch_log_metric_filter" "sg-changes" {
  name           = "SecurityGroupChanges"
  pattern        = "{ ($.eventName = \"AuthorizeSecurityGroupIngress\") || ($.eventName = \"RevokeSecurityGroupIngress\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name      = "SecurityGroupChangeCount"
    namespace = "Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "sg-changes-alarm" {
  alarm_name          = "SecurityGroupChangeDetected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "Security"
  metric_name         = aws_cloudwatch_log_metric_filter.sg-changes.metric_transformation[0].name
  threshold           = 1
  period              = 300
  statistic           = "Sum"
  alarm_description   = "Alert when security group changes are detected"
  alarm_actions       = [aws_sns_topic.security-alerts.arn]

}