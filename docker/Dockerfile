

FROM wordpress:latest

# Copy custom WordPress content (optional)
COPY ./custom-content/ /var/www/html/

# Install additional PHP extensions if needed
RUN apt-get update && apt-get install -y \
    libpng-dev \
    && docker-php-ext-install gd

# Additional customizations can go here
