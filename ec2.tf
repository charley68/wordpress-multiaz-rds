data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    //values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-*-*-arm64-server-*"]
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

  tags = local.tags
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name

  tags = local.tags
}

/*resource "aws_iam_policy" "ecr_pull_policy" {
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
}*/



data "template_file" "user_data" {

  template = templatefile(var.script_path, {
    ACCOUNT_ID  = data.aws_caller_identity.current.account_id
    REGION = data.aws_region.current.name
    DB_HOST = aws_db_instance.rds_instance.endpoint
    DB_NAME = var.db_name
    DB_PASS = var.db_password
    DB_USER = var.db_username
    S3_BUCKET = var.s3_bucket_name
    EFS_NAME = aws_efs_file_system.wordpress_efs.dns_name
  })
}


resource "aws_instance" "wordpress" {


  count = length(var.availability_zone)
  //count = var.ec2Count  // Override this here for quicker testing with one EC2
  subnet_id = local.public_subnets[count.index]


  //ami  = var.ami_id
  ami  = data.aws_ami.ubuntu.image_id
  instance_type = var.instance
  key_name                    = "${var.project}-key"

  security_groups             = [aws_security_group.allow_ssh.id, aws_security_group.LB-SG.id, aws_security_group.rds_security_group.id]
  
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data     = data.template_file.user_data.rendered

  // Doing this ensures EC2 auto re-creates if we change the user data in template file.
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.tags,
    {
      Name = "${var.project} Instance ${count.index + 1}"
  })
}