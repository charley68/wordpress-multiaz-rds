
/*resource "aws_s3_bucket" "wordpress-bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = "Bucket for storing our wordpress code to pull down onto EC2. Maybe put this in GIT at some point."
  }
}*/

locals {

  s3_bucket_arn = "arn:aws:s3:::${var.s3_bucket_name}"
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "s3_access_policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
         // "${aws_s3_bucket.wordpress-bucket.arn}",
         // "${aws_s3_bucket.wordpress-bucket.arn}/*"
         "${local.s3_bucket_arn}",
         "${local.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

