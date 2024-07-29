https://medium.com/@i.mani/deploying-wordpress-on-aws-with-rds-using-terraform-and-docker-c17f2b7ab0d8

cd docker
docker-compose -f docker-compose-local.yml up -d






aws ecr get-login-password --region eu-west-2 |  docker login --username AWS --password-stdin 868171460502.dkr.ecr.eu-west-2.amazonaws.com
docker tag 83e02a2d0088  868171460502.dkr.ecr.eu-west-2.amazonaws.com/steve-repo:1.2.3.4
docker push 868171460502.dkr.ecr.eu-west-2.amazonaws.com/steve-repo:1.2.3.4


