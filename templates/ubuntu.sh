#!/bin/bash

apt-get update -y
apt-get install -y apache2 php php-mysql nfs-common unzip  mysql-client-core-8.0

mv /var/www/html/index.html /var/www/html/apache.html
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install


# Mount EFS
mkdir -p /var/www/html
echo "${EFS_NAME}:/ /var/www/html nfs4 defaults,_netdev 0 0" >> /etc/fstab
mount -a

cat > /home/ubuntu/pullLatestWPCodeFromS3.sh << 'EOL'
#!/bin/bash


# Download WordPress files from S3
aws s3 cp s3://${S3_BUCKET}/wp-content.zip /tmp
unzip -u  /tmp/wp-content.zip -d /

chown -R ubuntu:ubuntu /var/www/html
chmod -R 755 /var/www/html/

# Restart Apache to apply changes
systemctl restart apache2

EOL
chown ubuntu /home/ubuntu/pullLatestWPCodeFromS3.sh
chmod u+x /home/ubuntu/pullLatestWPCodeFromS3.sh
# Add the sudoers configuration for the ubuntu user.  This is so our script running as ubunto has permision to restart apache.
echo 'ubuntu ALL=NOPASSWD: /usr/sbin/service apache2 restart' | sudo tee /etc/sudoers.d/ubuntu_apache

# Set correct permissions for the sudoers file
chmod 0440 /etc/sudoers.d/ubuntu_apache


cat > /home/ubuntu/updateDB.sh << 'EOL'

#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename.sql>"
    exit 1
fi

# Parameters
SQL_FILE=$1
DB_HOST="${DB_HOST}"          
DB_PORT="3306"                   
DB_NAME="${DB_NAME}"         
DB_USER="${DB_USER}"            
DB_PASSWORD="${DB_PASS}"       

# Check if the file exists
if [ ! -f "$SQL_FILE" ]; then
    echo "File not found: $SQL_FILE"
    exit 1
fi

# Execute the SQL file against the RDS database
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p"$DB_PASSWORD" $DB_NAME < $SQL_FILE

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "SQL statements executed successfully."
else
    echo "Failed to execute SQL statements."
    exit 1
fi

EOL

chown ubuntu:ubuntu /home/ubuntu/updateDB.sh
chmod u+x /home/ubuntu/updateDB.sh

# Check if WordPress is already installed
if [ ! -f /var/www/html/wp-config.php ]; then

    cd /var/www/html
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mv wordpress/* .
    rmdir wordpress
    rm latest.tar.gz

    # Configure database connection (replace with your actual DB credentials)
    cat > /var/www/html/wp-config.php << 'EOL'
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
EOL

    # Pull in any custom wp-content data and overlay wordpress install
    /home/ubuntu/pullLatestWPCodeFromS3.sh
fi

EOF