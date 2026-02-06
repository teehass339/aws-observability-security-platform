resource "aws_lb" "app-alb" {
  name               = "${var.env}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = aws_subnet.pub-subnet[*].id
  security_groups    = [aws_security_group.alb-sg.id]
  access_logs {
    bucket  = aws_s3_bucket.alb-logs.bucket
    enabled = true
  }

  tags = {
    Name        = "${var.env}-alb"
    Environment = var.env
  }

  depends_on = [
    aws_s3_bucket_policy.alb-logs,
    aws_s3_bucket_public_access_block.alb-logs,
    aws_s3_bucket_ownership_controls.alb-logs
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }
}

resource "aws_lb_target_group" "app-tg" {
  name        = "${var.env}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app-vpc.id
  target_type = "instance"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
