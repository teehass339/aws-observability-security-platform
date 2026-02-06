data "aws_ami" "latest-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [var.ami_image]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}


resource "aws_launch_template" "app-lt" {
  name_prefix   = "${var.env}-launch-template"
  image_id      = data.aws_ami.latest-linux-image.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh-key.key_name
  user_data     = filebase64("user_data.sh")
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-profile.name
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app-sg.id]
  }
  lifecycle {
    create_before_destroy = true
  }
}