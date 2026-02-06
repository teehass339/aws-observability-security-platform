data "aws_instances" "asg_ec2" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-asg-instance"]
  }
}

output "ec2_ips" {
  value = data.aws_instances.asg_ec2.private_ips
}

output "alb_dns_name" {
  value = aws_lb.app-alb.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.app-asg.name
}