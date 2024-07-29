


docker build . -t steve-wordpress:1.0

aws ecr get-login-password --region eu-west-2 |  docker login --username AWS --password-stdin 868171460502.dkr.ecr.eu-west-2.amazonaws.com
docker tag imageID  868171460502.dkr.ecr.eu-west-2.amazonaws.com/steve-repo:1.2.3.4

docker push 868171460502.dkr.ecr.eu-west-2.amazonaws.com/steve-repo:1.2.3.4




#docker tag wordpress:latest mani2233/wordpress:new_version
docker push YOUR_DOCKER_HUB_USERNAME/wordpress:new_version
