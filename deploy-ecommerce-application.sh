#! /bin/bash
# Installing Firewall 
echo "Installing firewall "
sudo yum -y install firewalld

if [ $? -eq 0 ]
then
        echo "Firewall Installed Successfully "
        echo "Starting & Enabling Firewall Service"
        sudo service firewalld start
i       sudo systemctl enable firewalld
else
        echo "Failed"
fi
# --------------------------------------------------------------------
echo "Installing MariaDB "
sudo yum install -y mariadb-server
if [ $? -eq 0 ]
then
        echo "Installed Successfully"
        sudo service mariadb start
        sudo systemctl enable mariadb
        echo "Configuring firewall to allow mariadb port"
        sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
        sudo systemctl restart firewalld
        echo "Configuring DataBase"
        sudo mysql -e "CREATE DATABASE ecomdb; CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword'; GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost'; FLUSH PRIVILEGES;"
else
echo "Failed"
fi
# -----------------------------------------------------------------------
echo "Installing & Configuring Web Server & Web App"
sudo yum install -y httpd php php-mysql
if [ $? -eq 0 ]
then
        echo "success"
        sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
        sudo firewall-cmd --reload
        echo "Configure httpd to run the app "
        sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf
        echo "Start Httpd service"
        sudo service httpd start
        sudo systemctl enable httpd
else
echo "failed"
fi
#------------------------------------------------------------------------------
echo "Install Source Code"
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/
echo "Importing Database Backup "
sudo mysql  < /var/www/html/assets/db-load-script.sql
echo "Configure The App With The DataBase "
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
