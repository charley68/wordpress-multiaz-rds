project = "maxai"
region="eu-west-2"
instance="t4g.medium"
script_path = "templates/ubuntu.sh"
availability_zone = ["eu-west-2a", "eu-west-2b"]

db_engine                    = "mysql"
db_engine_version            = "8.0.37"
db_name="wordpress"
db_username = "wordpressuser"
db_password = "!soRebreck"
s3_bucket_name = "maxai-code"
