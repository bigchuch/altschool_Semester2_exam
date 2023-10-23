#/bin/bash

ENV_FILE=".env"

APP_URL=https://techvblogs.com
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=techvblogs
DB_USERNAME=admin
DB_PASSWORD=password



#Updating linux libraris
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update



#installing apache2
sudo apt install apache2 -y
sudo apt install php7.4-xml -y


#installing PHP 
sudo apt-get install php -y

#installing mysql-server
sudo apt install mysql-server -y

#creating database user for mysql server 
# sudo mysql;
# CREATE DATABASE techvblogs;
# CREATE USER 'admin'@'localhost’ IDENTIFIED WITH mysql_native_password BY 'password’;
# GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost’ WITH GRANT OPTION;

# Exit;


# sudo mysql -e "
# CREATE USER '${DB_USERNAME}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASSWORD}';
# GRANT ALL PRIVILEGES ON *.* TO '${DB_USERNAME}'@'localhost' WITH GRANT OPTION;
# FLUSH PRIVILEGES;"
# echo "MySQL commands executed successfully."

# mysql -u'${DB_USERNAME}' -p'${DB_PASSWORD}
# CREATE DATABASE '${DB_DATABASE}';
# Exit;


# Create a new user and grant privileges
sudo mysql -e "
CREATE USER '${DB_USERNAME}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_USERNAME}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;"
echo "MySQL user and privileges set successfully."

# Create a new database
mysql -u${DB_USERNAME} -p${DB_PASSWORD} -e "CREATE DATABASE ${DB_DATABASE};"
echo "Database created successfully."





#setting up composer for php
cd /tmp/
mkdir Downloads
cd Downloads/
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php
sudo mv composer.phar /usr/local/bin/composer

#installing php extension need by lavarel
sudo apt install git unzip php-zip php-mysql php-xml php-curl -y

#switching to the default apache2 directory
cd /var/www/html
sudo rm index.html

#changing owner of html folder the current user 
sudo chown -R ubuntu:ubuntu .

sudo git clone https://github.com/laravel/laravel.git 
cd laravel
composer install
sudo chown -R www-data:www-data storage/

#update ENV file and Generate an encryption key
sudo cp .env.example .env
sudo php artisan key:generate

 
#Next, edit the .env file and define your database:

sudo sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=$DB_CONNECTION /" $ENV_FILE
sudo sed -i "s/^DB_HOST=.*/DB_HOST=$DB_HOST/" $ENV_FILE
sudo sed -i "s/^DB_PORT=.*/DB_PORT=$DB_PORT/" $ENV_FILE
sudo sed -i "s/^DB_DATABASE=.*/DB_DATABASE=$DB_DATABASE/" $ENV_FILE
sudo sed -i "s/^DB_USERNAME=.*/DB_USERNAME=$DB_USERNAME/" $ENV_FILE
sudo sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" $ENV_FILE

#migration of database
sudo php artisan migrate


#configuring Apache for Laravel

cd /var/www/html

sudo cat << EOF > techvblogs.conf

<VirtualHost *:80>

    ServerAdmin admin@127.0.0.1.com
    ServerName techvblogs.com
    DocumentRoot /var/www/html/public

    <Directory /var/www/html/public>
       Options +FollowSymlinks
       AllowOverride All
       Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

EOF

sudo mv /var/www/html/techvblogs.conf  /etc/apache2/sites-available/

#activating apache rewrite module
sudo a2enmod rewrite
sudo a2ensite techvblogs.conf


#restart apache server
sudo service apache2 restart





