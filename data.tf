data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"] # amazon
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_region" "this" {}

data "aws_caller_identity" "this" {}