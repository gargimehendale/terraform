terraform {
  backend "s3" {
    bucket = "gargimbucket"
    key = "terraform.tfstate"
    region = "us-east-1"     
    dynamodb_table = "terraformstate"
  }

}
