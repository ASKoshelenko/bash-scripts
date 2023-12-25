#!/bin/bash

function print_color(){
    NC='\033[0m'
    
    case $1 in
        "green") COLOR='\033[0;32m' ;;
        "red") COLOR='\033[0;31m' ;;
        "*") COLOR='\033[0m' ;;
    esac

    echo -e "${COLOR} $2 ${NC}"
}

function check_service_status(){
    is_service_active=$(systemctl is-active $1)

    if [ $is_service_active = "active" ]
    then
        print_color "green" "$1 service is active"
    else
        print_color "red" "$1 service is not active"
        exit 1
    fi
}

function is_firewalld_rule_configured(){
    firewalld_ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)

    if [[ $firewalld_ports = *$1* ]]
    then
        print_color "green" "Port $1 configured"
    else
        print_color "red" "Port $1 not configured"
        exit 1
    fi
}

function check_item(){
    if [[ $1 = *$2* ]]
    then
        print_color "green" "Item $2 is present on the web page"
    else
        print_color "red" "Item $2 is not present on the web page"
    fi
}

# ---------------- Database Configuration -----------------
# Install and configure Firewalld
print_color "green" "Instaling firewalld..."

sudo yum install -y firewalld
sudo service firewalld start
sudo systemctl enable firewalld

check_service_status firewalld

# Install and configure MariaDB
print_color "green" "Installing MariaDB..."

sudo yum install -y mariadb-server
sudo service mariadb start
sudo systemctl enable mariadb

check_service_status mariadb

# Add Firewalld rules for database
print_color "green" "Adding Firewall rules for DB..."
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 3306

#Configure Database
print_color "green" "Configuring DB..."
cat > configure-db.sql <<-EOF
MariaDB > CREATE DATABASE ecomdb;
MariaDB > CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
MariaDB > GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
MariaDB > FLUSH PRIVILEGES;
EOF

sudo mysql < configure-db.sql

#Load inventory data into Database
print_color "green" "Loading inventory data into DB..."
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
EOF

sudo mysql < db-load-script.sql

mysql_db_results=$(sudo mysql -e "ese ecomdb; select * from products;")

if [[ $mysql_db_results = *Laptop* ]]
then
    print_color "green" "Inventory data loaded"
else
    print_color "red" "Inventory data not loaded"
    exit 1
fi


# -------------- Web Server Configuration ---------------------

# Install apache web server and php
print_color "green" "Configuring Web Server..."
sudo yum install -y httpd php php-mysql

# Configure Firewall rules for web server
print_color "green" "Configuring Firewalld rules for web server..."
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 80

sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

# Start and enable httpd service
print_color "green" "Starting web server..."
sudo service httpd start
sudo systemctl enable httpd

check_service_status httpd

#Install git and download source code repository
print_color "green" "Cloning GIT Repo..."
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

# Replace database IP with localhost
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

print_color "green" "All set."

web_page=$(curl http://localhost)

for item in Laptop Drone VR Watch
do
    check_item "$web_page" $item
done