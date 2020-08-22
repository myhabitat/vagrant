#filename: provision.sh
#!/usr/bin/env bash

###########################################
#                                         #
# + Apache                                #
# + PHP 5 / PHP 7.1 FPM                              #
# + MySQL 5.6 or MariaDB 10.1             #
# + NodeJs, Git, Composer, etc...         #
###########################################



# ---------------------------------------------------------------------------------------------------------------------
# Variables & Functions
# ---------------------------------------------------------------------------------------------------------------------
APP_DATABASE_NAME='dcm_sdsmanagement'
APP_DATABASE_NAME_1='dcm_app'
APP_DATABASE_NAME_2='dcm_simplesds'
APP_DATABASE_NAME_3='dcm_safetymanager'
APP_DATABASE_NAME_4='dcm_common'
PASSWORD='password'

echoTitle () {
    echo -e "\033[0;30m\033[42m -- $1 -- \033[0m"
}



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Virtual Machine Setup'
# ---------------------------------------------------------------------------------------------------------------------
# Update packages
apt-get update -qq
apt-get -y install git curl vim



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing and Setting: Apache'
# ---------------------------------------------------------------------------------------------------------------------
# Install packages
apt-get install -y apache2 libapache2-mod-fastcgi libapache2-mod-wsgi python-dev

# linking Vagrant directory to Apache 2.4 public directory
# rm -rf /var/www
# ln -fs /vagrant /var/www

# Add ServerName to httpd.conf
echo "ServerName localhost" > /etc/apache2/httpd.conf

# Setup hosts file
VHOST1=$(cat <<EOF
    <VirtualHost *:80>
      DocumentRoot "/var/www/ncps/public"
      ServerName test.ncps.com
      ServerAlias test.ncps.com
      <Directory "/var/www/ncps/public">
        AllowOverride All
        Require all granted
      </Directory>
      <IfModule mod_fastcgi.c>
          <FilesMatch ".+\.ph(p[345]?|t|tml)$">
             SetHandler php73-fcgi-www
          </FilesMatch>
       </IfModule>
    </VirtualHost>
EOF
)
echo "${VHOST1}" > /etc/apache2/sites-enabled/001-test.ncps.com.conf

VHOST2=$(cat <<EOF
    <VirtualHost *:80>
      DocumentRoot "/var/www/ncps-api/public"
      ServerName test.ncpsapi.com
      ServerAlias test.ncpsapi.com
      <Directory "/var/www/ncps-api/public">
        AllowOverride All
        Require all granted
      </Directory>
      <IfModule mod_fastcgi.c>
          <FilesMatch ".+\.ph(p[345]?|t|tml)$">
             SetHandler php73-fcgi-www
          </FilesMatch>
       </IfModule>
    </VirtualHost>
EOF
)
echo "${VHOST2}" > /etc/apache2/sites-enabled/002-test.ncpsapi.com.conf

# Setup hosts file
VHOST3=$(cat <<EOF
    <VirtualHost *:80>
      DocumentRoot "/var/www/app/public"
      ServerName dev.app.test
      ServerAlias dev.app.test
      <Directory "/var/www/app/public">
        AllowOverride All
        Require all granted
      </Directory>
       <IfModule mod_fastcgi.c>
          <FilesMatch ".+\.ph(p[345]?|t|tml)$">
             SetHandler php73-fcgi-www
          </FilesMatch>
       </IfModule>
    </VirtualHost>
EOF
)
echo "${VHOST3}" > /etc/apache2/sites-enabled/003-default.conf


VHOST4=$(cat <<EOF
   <VirtualHost *:80>
      DocumentRoot "/var/www/dosa/public/"
      ServerName test.dosa.com
      ServerAlias test.dosa.com
      <Directory "/var/www/dosa/public/">
        AllowOverride All
        Require all granted
      </Directory>
       <IfModule mod_fastcgi.c>
          <FilesMatch ".+\.ph(p[345]?|t|tml)$">
             SetHandler php73-fcgi-www
          </FilesMatch>
       </IfModule>
    </VirtualHost>
EOF
)
echo "${VHOST4}" > /etc/apache2/sites-enabled/004-test.dosa.com.conf

VHOST5=$(cat <<EOF
    <VirtualHost *:80>
      DocumentRoot "/var/www/dosa-api/public/"
      ServerName test.dosaapi.com
      ServerAlias test.dosaapi.com
      <Directory "/var/www/dosa-api/public/">
        AllowOverride All
        Require all granted
      </Directory>
       <IfModule mod_fastcgi.c>
          <FilesMatch ".+\.ph(p[345]?|t|tml)$">
             SetHandler php73-fcgi-www
          </FilesMatch>
       </IfModule>
    </VirtualHost>
EOF
)
echo "${VHOST5}" > /etc/apache2/sites-enabled/005-test.dosaapi.com.test.conf

VHOST6=$(cat <<EOF
    <VirtualHost *:80>
      DocumentRoot "/var/www/laravel201/public/"
      ServerName dev.laravel201.test
      ServerAlias dev.laravel201.test
      <Directory "/var/www/laravel201/public/">
        AllowOverride All
        Require all granted
      </Directory>
       <IfModule mod_fastcgi.c>
          <FilesMatch ".+\.ph(p[345]?|t|tml)$">
             SetHandler php73-fcgi-www
          </FilesMatch>
       </IfModule>
    </VirtualHost>
EOF
)
echo "${VHOST6}" > /etc/apache2/sites-enabled/006-dev.laravel201.test.conf


# Loading needed modules to make apache work
sudo a2enmod actions fastcgi alias proxy_fcgi
sudo service apache2 reload

# ---------------------------------------------------------------------------------------------------------------------
 echoTitle 'Maria-Database'
# ---------------------------------------------------------------------------------------------------------------------
# Remove MySQL if installed
sudo service mysql stop
apt-get remove --purge mysql-server-5.6 mysql-client-5.6 mysql-common-5.6
apt-get autoremove

rm -rf apt-get autoclean/var/lib/mysql/
rm -rf /etc/mysql/

# Install MariaDB
export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password password'
debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password password'
apt-get install -y mariadb-server

# ---------------------------------------------------------------------------------------------------------------------
 echoTitle 'Setting Up Databases'
# ---------------------------------------------------------------------------------------------------------------------

# Setup database
mysql -uroot -ppassword -e "CREATE DATABASE IF NOT EXISTS $APP_DATABASE_NAME DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';";
mysql -uroot -ppassword -e "CREATE DATABASE IF NOT EXISTS $APP_DATABASE_NAME_1 DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';";
mysql -uroot -ppassword -e "CREATE DATABASE IF NOT EXISTS $APP_DATABASE_NAME_2 DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';";
mysql -uroot -ppassword -e "CREATE DATABASE IF NOT EXISTS $APP_DATABASE_NAME_3 DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';";
mysql -uroot -ppassword -e "CREATE DATABASE IF NOT EXISTS $APP_DATABASE_NAME_4 DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';";


# Set MariaDB root user password and persmissions
mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'password';"

# Open MariaDB to be used with Sequel Pro
#sed -i 's|127.0.0.1|0.0.0.0|g' /etc/mysql/my.cnf
sed -i 's|127.0.0.1|0.0.0.0|g' /etc/mysql/mariadb.conf.d/50-server.cnf

# Restart MariaDB
sudo service mysql restart

# ---------------------------------------
#          PHP Setup
# ---------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing: PHP'
# ---------------------------------------------------------------------------------------------------------------------
# Add repository
add-apt-repository ppa:ondrej/php
apt-get update
apt-get install -y python-software-properties software-properties-common


# Install PHP 7.4
apt-get install -y php7.3 php7.3-fpm

apt-get install -y php7.3-mysql
apt-get install -y mcrypt php7.3-mcrypt
apt-get install -y php7.3-cli php7.3-curl php7.3-mbstring php7.3-xml php7.3-mysql
apt-get install -y php7.3-json php7.3-cgi php7.3-gd php-imagick php7.3-bz2 php7.3-zip php7.3-intl


# Creating the configurations inside Apache
cat > /etc/apache2/conf-available/php7.3-fpm.conf << EOF
<IfModule mod_fastcgi.c>
 AddHandler php73-fcgi-www .php
 Action php73-fcgi-www /php73-fcgi-www
 Alias /php73-fcgi-www /usr/lib/cgi-bin/php73-fcgi-www
 FastCgiExternalServer /usr/lib/cgi-bin/php73-fcgi-www -socket /run/php/php7.3-fpm.sock -idle-timeout 1800 -pass-header Authorization
 <Directory "/usr/lib/cgi-bin">
  Require all granted
 </Directory>
</IfModule>
EOF

# enable the Internationalization extension for PHP 7.3
sed -i 's|;extension=php_intl.dll|extension=php_intl.dll|g' /etc/php/7.3/fpm/php.ini

# Triggering changes in apache
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php7.3-fpm
sudo a2enmod rewrite
sudo service apache2 restart

# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing: Redis'
# ---------------------------------------------------------------------------------------------------------------------
apt-get install -y redis-server
apt-get install -y php-redis
sudo service apache2 restart

# ---------------------------------------------------------------------------------------------------------------------
# Others
# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing: Git'
apt-get install -y git

echoTitle 'Installing: Composer'
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer



# ---------------------------------------------------------------------------------------------------------------------
# Others
# ---------------------------------------------------------------------------------------------------------------------
# Output success message
echoTitle "Your machine has been provisioned"
echo "-------------------------------------------"
echo "MySQL is available on port 3306 with username 'root' and password 'password'"
echo "(you have to use 127.0.0.1 as opposed to 'localhost')"
echo "Apache is available on port 80"
echo -e "Head over to http://192.168.50.100 to get started"
