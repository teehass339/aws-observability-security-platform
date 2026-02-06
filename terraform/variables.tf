variable "public_cidr_block" {
  type    = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "private_cidr_block" {
  type    = list(string)
  default = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
}
variable "vpc_cidr_block" {
  default = "10.1.0.0/16"
}
variable "env" {
  default = "Dev"
}

variable "ami_image" {
  default = "al2023-ami-2023*-kernel-6.1-x86_64"
}

variable "public_key_location" {
  default = "~/.ssh/id_rsa.pub"
}

variable "avail_zone" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "region" {
  default = "us-east-1"

}
variable "instance_type" {
  default = "t3.micro"
}