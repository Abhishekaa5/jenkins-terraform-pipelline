terraform {
  backend "s3"{
    bucket = "unic109"
    region = "ap-south-1"
    key = "main"
  }
}