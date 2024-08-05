FROM wordpress:latest

# Copy custom WordPress content (optional)

RUN mv /var/www/html/wp-content /var/www/html/wp-content.old
COPY ./custom-content/wp-content /var/www/html/wp-content

# Install additional PHP extensions if needed
RUN apt-get update && apt-get install -y \
    libpng-dev \
    && docker-php-ext-install gd

#ENV DEBIAN_FRONTEND=noninteractive

#RUN apt-get update && apt-get install -y gnupg dirmngr

#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9 && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131 && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F8D2585B8783D481

# Update package lists and install curl
#RUN apt-get update && apt-get install -y curl && \
#    apt-get clean && rm -rf /var/lib/apt/lists/*




# Additional customizations can go here
