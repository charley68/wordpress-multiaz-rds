#!/bin/bash
sudo yum update
sudo yum -y install docker

sudo usermod -a -G docker ec2-user
sudo chmod 666 /var/run/docker.sock

# Ensure it auto starts after reboot
sudo systemctl enable docker

# Start Docker
sudo service docker start

# Install Docker Coompose
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose



cat <<EOF >/home/ec2-user/docker-compose.yml

services:
  wordpress:
    image: ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: ${DB_HOST}
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASS}
      WORDPRESS_DB_NAME: ${DB_NAME}
    volumes:
      - wordpress_data:/var/www/html

volumes:
  wordpress_data:

EOF

cat <<EOF2 >/home/ec2-user/start_wordpress.sh
#!/bin/bash
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
docker-compose up -d
EOF2

chown ec2-user:ec2-user /home/ec2-user/docker-compose.yml
chown ec2-user:ec2-user /home/ec2-user/start_wordpress.sh
chmod u+x  /home/ec2-user/start_wordpress.sh
