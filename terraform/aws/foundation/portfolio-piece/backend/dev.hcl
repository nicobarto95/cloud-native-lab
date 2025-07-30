bucket         = "foundation-portfolio-dev"
key            = "terraform.tfstate"
region         = "eu-west-1"
dynamodb_table = "terraform-locks-dev"
encrypt        = true
environment = "dev"
vpc_cidr    = "10.10.0.0/16"
instance_type = "t3.micro"
