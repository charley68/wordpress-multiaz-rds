# Use the latest WordPress image as the base
FROM wordpress:latest

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the wp-content directory from GitHub
RUN rm -rf /var/www/html/wp-content && \
    git clone https://github.com/charley68/wordpress.git /var/www/html/



# Ensure correct permissions (optional)
RUN chown -R www-data:www-data /var/www/html/wp-content

# Expose port 80
EXPOSE 80

