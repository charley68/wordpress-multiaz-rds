#!/bin/bash
# Update package list and install necessary packages
apt-get update -y


# Get rid of the default pache welcome page to force index.php to run instead.
mv /var/www/html/index.html  /var/www/html/ubuntu.html

cat > /home/ubuntu/pullLatestWPCodeFromS3.sh << 'EOL'
#!/bin/bash

#if we want to install wp from scratch .......
#cd /var/www/html
#sudo curl -O https://wordpress.org/latest.tar.gz
#sudo tar -xzf latest.tar.gz
#sudo mv wordpress/* .
#sudo rm -rf wordpress latest.tar.gz


# Download WordPress files from S3
aws s3 cp s3://${S3_BUCKET}/wordpress.zip /tmp
unzip /tmp/wordpress.zip


# Configure database connection (replace with your actual DB credentials)
cat > /var/www/html/wp-config.php << 'EOL2'
<?php
define('DB_NAME', '${DB_NAME}');
define('DB_USER', '${DB_USER}');
define('DB_PASSWORD', '${DB_PASS}');
define('DB_HOST', '${DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
define('AUTH_KEY',         'wR?=#phrLD=|0C@6u|5+}zx=K&%~Rb~?fe]%iQ4rR2R-DrZgTW$U^1y-K+#G&5Q=');
define('SECURE_AUTH_KEY',  'D&G%M.u~Be~?Sa(x@f-P!)@> 9~V8rCJXN@DEpLxNa_{U)|#A`w@^[P%t=:w(7#?');
define('LOGGED_IN_KEY',    'X^w)ac/r5,n@?:+L8x5l$vTq.<i=:]>#kr=V ikN`fN_b*lm6&O8uGyq&;D!_v-e');
define('NONCE_KEY',        '-87jGw4R*]7b;{`t3{v jo;$7WxsI xPy*{}`{~50E_+ve|RBu(W=V!q7L4;^W7R');
define('AUTH_SALT',        '+ZXQO1yB@fVQM){+zwUI.bH$jMgyM75=R/b5+9s5z)Ii:cP)#$$$gPQRDr*YZga,');
define('SECURE_AUTH_SALT', 'b/V|p1((lm&0;1/NmoQ}=~1%[pn<%`Y`<v=<47v*n4g92Y~R&&Ff5&3cCr+!o_`b');
define('LOGGED_IN_SALT',   '`T>g9P=u,+V8Q^wj?O-;&%mCy*2-$7%-0r$V+uC87%@P>F$GFVW|I6}{vX$)4yDM');
define('NONCE_SALT',       '+_i&=& =[UZGmEe.j>I!Pm:QPA/5-+edK|e%N;Po7xjqmYy%MgjL3+Z st_d!2Z<');
$table_prefix  = 'wp_';
define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');

EOL2
chown -R ubuntu:ubuntu /var/www/html/wp-config.php
chmod -R 755 /var/www/html/wp-config.php

# Restart Apache to apply changes
systemctl restart apache2

EOL

/home/ubuntu/pullLatestWPCodeFromS3.sh

chown ubuntu /home/ubuntu/pullLatestWPCodeFromS3.sh
chmod u+x /home/ubuntu/pullLatestWPCodeFromS3.sh

# Set permissions
chown -R ubuntu:ubuntu /var/www/html
chmod -R 755 /var/www/html

# Add the sudoers configuration for the ubuntu user.  This is so our script running as ubunto has permision to restart apache.
echo 'ubuntu ALL=NOPASSWD: /usr/sbin/service apache2 restart' | sudo tee /etc/sudoers.d/ubuntu_apache

# Set correct permissions for the sudoers file
chmod 0440 /etc/sudoers.d/ubuntu_apache
