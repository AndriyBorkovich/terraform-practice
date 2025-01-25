terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "terraform-sandbox"
}

# spin up EC2 instance
resource "aws_instance" "app_server" {
  ami = "ami-011899242bb902164"
  instance_type = "t2.micro"
}