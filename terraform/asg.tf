resource "aws_autoscaling_group" "app-asg" {
  name                = "${var.env}-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = aws_subnet.app-subnet[*].id
  launch_template {
    id      = aws_launch_template.app-lt.id
    version = "$Latest"
  }
  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true

  target_group_arns = [
    aws_lb_target_group.app-tg.arn
  ]

  depends_on = [aws_lb_target_group.app-tg]

  tag {
    key                 = "Name"
    value               = "${var.env}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale-up" {
  name                   = "scale_up_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app-asg.name
}

resource "aws_autoscaling_policy" "scale-down" {
  name                   = "scale_down_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app-asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale-up-alarm" {
  alarm_name          = "scale_up_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Scale up if CPU utilization is over 75%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app-asg.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale-up.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "scale-down-alarm" {
  alarm_name          = "scale_down_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale down if CPU utilization is under 30%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app-asg.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale-down.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "unhealthy-targets" {
  alarm_name          = "alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "ALB has unhealthy targets"
  dimensions = {
    TargetGroup          = aws_lb_target_group.app-tg.arn_suffix
    LoadBalancer         = aws_lb.app-alb.arn_suffix
    AutoScalingGroupName = aws_autoscaling_group.app-asg.name
  }
}
