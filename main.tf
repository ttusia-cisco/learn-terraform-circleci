provider "vault" {
  # need the following env variables in terraform cloud
  # VAULT_ADDR = https://vault-cluster-public-vault-ab6b6e5f.9d5746b1.z1.hashicorp.cloud:8200
  auth_login {
    path = "auth/approle/login"
    parameters {
      role_id = "fakerole"
      secret_id =  "fakesecret"
    }
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = "aws"
  role    = "learn-terraform-circleci"
}

provider "aws" {
  region = var.region

  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key

  default_tags {
    tags = {
      hashicorp-learn = "circleci"
    }
  }
}

resource "random_uuid" "randomid" {}

resource "aws_s3_bucket" "app" {
  tags = {
    Name          = "App Bucket"
    public_bucket = true
  }

  bucket        = "${var.app}.${var.label}.${random_uuid.randomid.result}"
  force_destroy = true
}

resource "aws_s3_object" "app" {
  acl          = "public-read"
  key          = "index.html"
  bucket       = aws_s3_bucket.app.id
  content      = file("./assets/index.html")
  content_type = "text/html"
}

resource "aws_s3_bucket_acl" "bucket" {
  bucket = aws_s3_bucket.app.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "terramino" {
  bucket = aws_s3_bucket.app.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
