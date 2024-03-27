#!/bin/bash

 
sudo apt -qqq --yes update
sudo apt install apt-transport-https ca-certificates curl software-properties-common git collectd awscli -y

exec > >(tee /var/log/user-data.log|logger -t user-data-extra -s 2>/dev/console) 2>&1

sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "metrics": {
        "metrics_collected": {
            "cpu": {
                "measurement": ["cpu_usage_idle"],
                "metrics_collection_interval": 60,
                "resources": ["*"],
                "totalcpu": true
            },
            "disk": {
                "measurement": ["used_percent"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "diskio": {
                "measurement": ["write_bytes", "read_bytes", "writes", "reads"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "mem": {
                "measurement": ["mem_used_percent"],
                "metrics_collection_interval": 60
            },
            "net": {
                "measurement": ["bytes_sent", "bytes_recv", "packets_sent", "packets_recv"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "swap": {
                "measurement": ["swap_used_percent"],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
sleep 240

# Install Apache, PHP, and extensions
sudo apt install apache2 php php-fpm php-mysql php-mbstring php-xml -y

cd  /var/www
# Clone the repo
git clone https://github.com/ibukun-oyedeji/assessment.git -b master
# sudo cp assessment /var/www/assessment
cd assessment

sudo apt install curl php-cli php-mbstring git unzip

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer


# Configure Apache 
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/laravel.conf

# Modify DocumentRoot and DirectoryIndex for Laravel's 'public' directory 
sudo sed -i -e 's|/var/www/html|/var/www/assessment/public|' -e 's|DirectoryIndex index.html|DirectoryIndex index.php|' /etc/apache2/sites-available/laravel.conf

# Configure PHP-FPM proxy in Apache
sudo sh -c 'echo "\
<Proxy fcgi://127.0.0.1:9000>
  ProxySet disablereuse=off
</Proxy>
<FilesMatch \.php$>
  SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>" >> /etc/apache2/sites-available/laravel.conf'

sudo a2ensite laravel.conf
sudo a2enmod proxy_fcgi setenvif
sudo systemctl restart apache2
sudo service apache2 restart

# Start PHP-FPM 
sudo systemctl start php8.1-fpm 
sudo systemctl enable php8.1-fpm

# Laravel Permissions 
sudo mkdir -p /var/www/assessment
sudo chown -R www-data:www-data /var/www/assessment 
sudo find /var/www/assessment -type d -exec chmod 755 {} \;
sudo find /var/www/assessment -type f -exec chmod 644 {} \;
sudo mkdir -p /var/www/assessment/storage
sudo chmod -R 775 /var/www/assessment/storage
sudo mkdir -p /var/www/assessment/bootstrap/cache
sudo chmod -R 775 /var/www/assessment/bootstrap/cache

# 7. Set up the cron job
(sudo crontab -l 2>/dev/null; echo "*/1 * * * * cd /var/www/assessment && php artisan schedule:run >> /dev/null 2>&1") | sudo crontab - 


