
#!/bin/bash

# Defining  environment variables
ENV_FILE=".env"
APP_URL="https://techvblogs.com"
DB_CONNECTION="mysql"
DB_HOST="127.0.0.1"
DB_PORT="3306"
DB_DATABASE="techvblogs"
DB_USERNAME="admin"
DB_PASSWORD="password"

# Update Linux libraries
echo "Updating Linux libraries..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# Install Apache2 and PHP
echo "Installing Apache2 and PHP..."
sudo apt install apache2 php7.4-xml php -y

# Install MySQL server
echo "Installing MySQL server..."
sudo apt install mysql-server -y

# Create a new MySQL user and grant privileges
echo "Creating new MySQL user and granting privileges..."
sudo mysql -e "
CREATE USER '${DB_USERNAME}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_USERNAME}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;"
echo "MySQL user and privileges set successfully."

# Create a new MySQL database
echo "Creating new MySQL database..."
mysql -u${DB_USERNAME} -p${DB_PASSWORD} -e "CREATE DATABASE ${DB_DATABASE};"
echo "Database created successfully."

# Set up Composer for PHP
echo "Setting up Composer for PHP..."
cd /tmp/
mkdir Downloads
cd Downloads/
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Install PHP extensions needed by Laravel
echo "Installing PHP extensions needed by Laravel..."
sudo apt install git unzip php-zip php-mysql php-xml php-curl -y

# Switch to the default Apache2 directory and clone Laravel project
echo "Cloning Laravel project..."
cd /var/www/html
sudo rm index.html
sudo chown -R ubuntu:ubuntu .
sudo chown -R vagrant:vagrant .
sudo git clone https://github.com/laravel/laravel.git 
cd laravel
composer install
sudo chown -R www-data:www-data storage/

# Update .env file and generate an encryption key
echo "Updating .env file and generating encryption key..."
sudo cp .env.example .env
sudo php artisan key:generate

# Edit the .env file and define your database
echo "Defining database in .env file..."
sudo sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=$DB_CONNECTION /" $ENV_FILE
sudo sed -i "s/^DB_HOST=.*/DB_HOST=$DB_HOST/" $ENV_FILE
sudo sed -i "s/^DB_PORT=.*/DB_PORT=$DB_PORT/" $ENV_FILE
sudo sed -i "s/^DB_DATABASE=.*/DB_DATABASE=$DB_DATABASE/" $ENV_FILE
sudo sed -i "s/^DB_USERNAME=.*/DB_USERNAME=$DB_USERNAME/" $ENV_FILE
sudo sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" $ENV_FILE

# Migrate the database
echo "Migrating the database..."
sudo php artisan migrate

# Configure Apache for Laravel
echo "Configuring Apache for Laravel..."
cd /var/www/html

cat << EOF > techvblogs.conf

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

sudo mv techvblogs.conf  /etc/apache2/sites-available/

# Activate Apache rewrite module and site configuration, then restart Apache server
echo "Activating Apache rewrite module and site configuration, then restarting Apache server..."
sudo a2enmod rewrite
sudo a2ensite techvblogs.conf
sudo service apache2 restart

# Add IP address of slave machine to master machine's hosts file
HOSTNAME="web01"
IP_ADDRESS="192.168.56.31"
HOSTS_FILE="/etc/hosts"

echo "$IP_ADDRESS $HOSTNAME" | sudo tee -a $HOSTS_FILE

# Generate keypair for master to slave connection and copy it to slave machine from master 
ssh-keygen -t rsa

echo "In the next screen the password is vagrant, this is for test purposes only."
ssh-copy-id vagrant@web01

# Install Ansible 
echo "Installing Ansible..."
sudo apt install ansible -y

echo "Script execution completed."

