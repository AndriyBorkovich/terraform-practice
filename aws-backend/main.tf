terraform {
  # switch to remote backend
  backend "s3" {
    bucket         = "tf-state-demo-andrew"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

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
#resource "aws_instance" "app_server" {
#  ami = "ami-011899242bb902164"
#  instance_type = "t2.micro"
#}

resource "aws_s3_bucket" "terraform_state_backend" {
  bucket = "tf-state-demo-andrew"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "tf_state_bucket_acl" {
  bucket = aws_s3_bucket.terraform_state_backend.id
  acl = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.terraform_state_backend.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_versioning" "tf_bucket_v" {
  bucket = aws_s3_bucket.terraform_state_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.terraform_state_backend.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tf_locks" {
  name = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockId"
  attribute {
    name = "LockId"
    type = "S"
  }
}