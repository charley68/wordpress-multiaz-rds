project = "steve"
region="eu-west-2"
instance="t3.micro"
script_path = "templates/awslinux2.sh"
availability_zone = ["eu-west-2a", "eu-west-2b"]
ec2Count = 1

db_engine                    = "mysql"
db_engine_version            = "8.0.37"
db_name="wordpress_db"
db_username = "steve"
db_password = "steve12345"
wordpress_docker_image = "wordpress"