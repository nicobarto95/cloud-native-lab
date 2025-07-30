provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "your-unique-portfolio-bucket"
  acl    = "public-read"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  tags = {
    Name = "DevOpsPortfolioS3"
  }
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "s3:GetObject",
      Resource = "${aws_s3_bucket.website_bucket.arn}/*"
    }]
  })
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  origins {
    domain_name = aws_s3_bucket.website_bucket.website_endpoint
    origin_id   = "portfolioS3"
    custom_origin_config {
      http_port  = 80
      https_port = 443
      origin_protocol_policy = "http-only"
    }
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "portfolioS3"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  tags = {
    Name = "DevOpsPortfolioCF"
  }
}

resource "aws_sns_topic" "deploy_notifications" {
  name = "portfolio-deploy-topic"
}

output "website_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
