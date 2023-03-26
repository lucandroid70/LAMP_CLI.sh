#!/bin/bash

###################### CREATED By Luca S. ITA Ministry of Defense employee ######################### 

sudo apt update
sudo apt upgrade

# install Apache web server
sudo apt install apache2 -y

# enable Apache modules
sudo a2enmod rewrite
sudo a2enmod ssl

sudo systemctl enable apache2 
sudo systemctl start apache2


# install MySQL server
sudo apt install mariadb-server -y
sudo systemctl enable mariadb 
sudo systemctl start mariadb

# secure the MySQL installation
sudo mysql_secure_installation





# install PHP and necessary modules
sudo apt install php libapache2-mod-php php-mysql phpmyadmin -y

# Enable the PHPMyAdmin Apache configuration file
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin


###################### CREATED By Luca S. ITA Ministry of Defense employee ######################### 

# prompt user for number of virtual hosts
read -p "How many virtual hosts do you want to add? " num_vhosts

# loop through virtual hosts
for ((i=1;i<=$num_vhosts;i++)); do
  # prompt user for virtual host name
  read -p "Enter virtual host name $i: " vhost_name


  # create virtual host directory
  sudo mkdir -p /var/www/html/$vhost_name

  # give ownership of directory to current user
  sudo chown -R www-data:www-data /var/www/html/$vhost_name

  # create virtual host configuration file
  sudo bash -c "cat <<EOF > /etc/apache2/sites-available/$vhost_name.conf
  <VirtualHost *:80>
    ServerName $vhost_name
    ServerAdmin webmaster@$vhost_name
    DocumentRoot /var/www/html/$vhost_name
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
  </VirtualHost>
EOF"

  # enable virtual host
  sudo a2ensite $vhost_name.conf

  # generate SSL certificates for the virtual host
  sudo openssl req -x509 -nodes -days 765 -newkey rsa:2048 -keyout /etc/ssl/private/$vhost_name.key -out /etc/ssl/certs/$vhost_name.crt

 sudo bash -c "cat <<EOF > /etc/apache2/sites-available/$vhost_name-ssl.conf
  <IfModule mod_ssl.c>
    <VirtualHost *:443>
      ServerName $vhost_name
      ServerAlias $vhost_name
      DocumentRoot /var/www/html/$vhost_name
      ErrorLog \${APACHE_LOG_DIR}/error.log
      CustomLog \${APACHE_LOG_DIR}/access.log combined
      SSLEngine on
      SSLCertificateFile /etc/ssl/certs/$vhost_name.crt
      SSLCertificateKeyFile /etc/ssl/private/$vhost_name.key
    </VirtualHost>
  </IfModule>
EOF"


  # enable the SSL virtual host
  sudo a2ensite $vhost_name-ssl.conf
done

# disable default virtual host
sudo a2ensite 000-default.conf

# restart Apache to apply changes
sudo systemctl restart apache2







# per errore mysql: 

# sudo mysql -u root
# use mysql;
# update user set plugin='' where User='root';
# flush privileges;
# exit;



###################### CREATED By Luca S. ITA Ministry of Defense employee #########################

