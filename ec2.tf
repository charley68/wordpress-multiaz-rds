data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy" "ecr_pull_policy" {
  name        = "ecr-pull-policy"
  description = "Policy to allow pulling images from ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ecr_pull_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ecr_pull_policy.arn
}


# Data block to fetch subnets after creation
data "aws_subnet" "public1" {
  depends_on = [aws_subnet.public1]
  id         = aws_subnet.public1.id
}

data "aws_subnet" "public2" {
  depends_on = [aws_subnet.public2]
  id         = aws_subnet.public2.id
}


data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.this.id]
  }

  tags = {
    Type = "Public"   // CHange this to Private for PRODUCTION.
  }

  depends_on = [data.aws_subnet.public1, data.aws_subnet.public2]
}

resource "aws_instance" "wordpress" {


  depends_on = [ aws_subnet.public1, aws_subnet.public2 ]

  //count = length(var.availability_zone)
  count = var.ec2Count
  subnet_id = data.aws_subnets.subnets.ids[count.index]

  
  ami  = data.aws_ami.ubuntu.image_id
  instance_type = var.instance
  key_name                    = "${var.project}-key"

  security_groups             = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = templatefile(var.script_path, {
    ACCOUNT_ID  = data.aws_caller_identity.current.account_id
    REGION = data.aws_region.current.name
    DB_HOST = aws_db_instance.rds_instance.endpoint
    DB_NAME = var.db_name
    DB_PASS = var.db_password
    DB_USER = var.db_username
    //REPO = "${var.project}-${var.wordpress_docker_image}-repo"
    S3_BUCKET = var.s3_bucket_name
  })
}