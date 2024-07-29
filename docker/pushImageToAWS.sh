#!/bin/bash

if [ -z "$1" ]; then
  echo "This script expects a version as a parameter."
  echo "Usage: $0 <version>"
  exit 1
fi

VERSION=$1

# either we need to pass this in or generate it from the tvars file somehow ??????
REPO="steve-wordpress-repo"
IMAGE="steve-wordpress"


docker build . -t ${IMAGE}

aws ecr get-login-password --region eu-west-2 |  docker login --username AWS --password-stdin 868171460502.dkr.ecr.eu-west-2.amazonaws.com
docker tag ${IMAGE}:latest  868171460502.dkr.ecr.eu-west-2.amazonaws.com/$REPO:$VERSION
docker tag ${IMAGE}:latest  868171460502.dkr.ecr.eu-west-2.amazonaws.com/$REPO:latest

docker push 868171460502.dkr.ecr.eu-west-2.amazonaws.com/$REPO:$VERSION
docker push 868171460502.dkr.ecr.eu-west-2.amazonaws.com/$REPO:latest

