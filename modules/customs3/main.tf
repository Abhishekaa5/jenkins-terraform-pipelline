#iam role
resource "aws_iam_role" "allow_instance_s3" {
  name = "${var.bucket_name}-allow_instance_s3"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "sts:AssumeRole"
          ],
          "Principal" : {
            "Service" : [
              "ec2.amazonaws.com"
            ]
          }
        }
      ]
  })
  tags = var.common_tags
}

# attach role in instance
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.bucket_name}_instance_profile"
  role = aws_iam_role.allow_instance_s3.name
}

# iam role policy
resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_instance_s3.name

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "s3:*"
          ],
          "Effect" : "Allow",
          "Resource" : [
            "arn:aws:s3:::${var.bucket_name}",
            "arn:aws:s3:::${var.bucket_name}/*"
          ]
        }
      ]
  })
}

# s3_bucket

resource "aws_s3_bucket" "web_bucket" {
  bucket        = var.bucket_name
  acl = "private"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.bucket
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "${var.elb_service_account_arn}"
          },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${var.bucket_name}/alb-logs/*"
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "delivery.logs.amazonaws.com"
          },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${var.bucket_name}/alb-logs/*",
          "Condition" : {
            "StringEquals" : {
              "s3:x-amz-acl" : "bucket-owner-full-control"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "delivery.logs.amazonaws.com"
          },
          "Action" : "s3:GetBucketAcl",
          "Resource" : "arn:aws:s3:::${var.bucket_name}"
        }
      ]
    }
  )
}


