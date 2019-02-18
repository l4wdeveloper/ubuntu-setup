#!/bin/bash

#Check if running as root:
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root!" 1>&2
  exit 1
fi

sudo apt-get -y update

#MYSQL
# Install MySQL Server in a Non-Interactive mode. Default root password will be "password123"
echo "mysql-server-5.7 mysql-server/root_password password password123" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password password123" | sudo debconf-set-selections
sudo apt-get -y install mysql-client-core-5.7
sudo apt-get -y install mysql-server
sudo apt-get -y install libapache2-mod-auth-mysql php5-mysql

#APACHE
sudo apt-get -y install apache2
sudo a2enmod rewrite 
sudo a2enmod vhost_alias
sudo a2enmod ssl
sudo /etc/init.d/apache2 restart

#APACHE CONFIG
echo "Apache2 configuration..."
echo "<VirtualHost *:80>
ServerAlias localhost *.localhost
VirtualDocumentRoot /home/developer/www/%-2+/
UseCanonicalName Off
<Directory \"/home/developer/www\">
Options FollowSymLinks
AllowOverride All
Order allow,deny
Allow from all
Require all granted
</Directory>
</VirtualHost>

<IfModule mod_ssl.c>
<VirtualHost *:443>
  ServerAlias localhost *.localhost
  VirtualDocumentRoot /home/developer/www/%-2+/
  SSLEngine on
  SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
  SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
  UseCanonicalName Off
  <Directory \"/home/developer/www\">
    Options FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
    Require all granted
  </Directory>
</VirtualHost>
</IfModule>" >> /etc/apache2/sites-enabled/000-default.conf

#wiki
echo "10.10.1.5        l4w.db" | sudo tee --append /etc/hosts
echo "10.10.1.5   backend.bitbucket.pg" | sudo tee --append /etc/hosts
echo "10.10.1.5   bb.pg" | sudo tee --append /etc/hosts

#PHP 5.6
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt-get -y install php5.6
sudo apt-get -y install php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-xml
sudo apt-get -y install libapache2-mod-php5.6 php5.6-gd php5.6-curl
sudo apt-get -y install php5.6-cgi
sudo apt-get -y install php5.6-soap

#PHP 7.0
sudo apt-get install php7.0 php7.0-cgi php7.0-cli php7.0-common php7.0-curl php7.0-dev php7.0-gd php7.0-json php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache php7.0-readline php7.0-soap php7.0-xml

sudo update-alternatives --set php /usr/bin/php5.6

#XDEBUG
sudo apt-get -y install php5.6-xdebug

echo "xdebug configuration..."
echo "zend_extension = /usr/lib/php/20131226/xdebug.so"  >> /etc/php/5.6/cli/php.ini
echo "xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_mode=req
xdebug.remote_host=127.0.0.1
xdebug.remote_port=9001
xdebug.idkey=\"PHPSTORM\"" >> /etc/php/5.6/cli/php.ini

echo "zend_extension = /usr/lib/php/20131226/xdebug.so"  >> /etc/php/5.6/apache2/php.ini
echo "xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_mode=req
xdebug.remote_host=127.0.0.1
xdebug.remote_port=9001
xdebug.idkey=\"PHPSTORM\"" >> /etc/php/5.6/apache2/php.ini

#IONCUBE
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xzf ioncube_loaders_lin_x86-64.tar.gz
sudo cp ./ioncube/ioncube_loader_lin_5.6.so   /usr/lib/php/20131226/
echo "zend_extension=/usr/lib/php/20131226/ioncube_loader_lin_5.6.so" | sudo tee /etc/php5/apache2/conf.d/00-ioncube.ini
echo "zend_extension=/usr/lib/php/20131226/ioncube_loader_lin_5.6.so" | sudo tee /etc/php5/apache2/cli/00-ioncube.ini
rm ioncube_loaders_lin_x86-64.tar.gz
rm -rf ./ioncube/

#Apache restart for the above
sudo /etc/init.d/apache2 restart

#GIT
sudo apt-get -y install git
git config --global color.ui auto

#NPM
sudo apt-get -y install nodejs-legacy
sudo apt-get -y install npm

#LESS
sudo npm install less -g
lessc -v

#COMPOSER
sudo apt-get -y install composer

#GULP
sudo npm cache clean -f
sudo npm install -g n
sudo n 5.11.1
sudo npm install --global gulp-cli
sudo npm install --save-dev gulp
sudo apt-get -y install graphicsmagick

#OTHER TOOLS

#keepassx
sudo apt-get -y install keepassx

#chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get -y update
sudo apt-get -y install google-chrome-stable

#slack
wget https://downloads.slack-edge.com/linux_releases/slack-desktop-2.3.4-amd64.deb
sudo dpkg -i slack-desktop-2.3.4-amd64.deb
rm slack-desktop-2.3.4-amd64.deb

#fixy po instalacji slacka
sudo apt -y --fix-broken install

#guake terminal
sudo apt-get -y install guake
sudo mkdir /etc/gconf/schemas
sudo ln -s /usr/share/gconf/schemas/guake.schemas /etc/gconf/schemas/guake.schemas
cp /usr/share/applications/guake.desktop /etc/xdg/autostart/

#TLP Thinkpad only
if [ $(cat /sys/devices/virtual/dmi/id/chassis_vendor) = "LENOVO" ]
then
  sudo add-apt-repository -y ppa:linrunner/tlp
  sudo apt-get -y update
  sudo apt-get -y install tlp tlp-rdw
  sudo tlp start
fi

#Magerun
wget https://files.magerun.net/n98-magerun.phar
curl -L -o n98-magerun.phar https://files.magerun.net/n98-magerun.phar
chmod +x ./n98-magerun.phar
sudo mv ./n98-magerun.phar /usr/local/bin/
echo "suhosin.executor.include.whitelist=\"phar\"" >> /etc/php/5.6/apache2/php.ini 

#PhpStorm
sudo snap install phpstorm --classic

#Adminer
sudo mkdir /home/developer/www/adminer
sudo wget "http://www.adminer.org/latest.php" -O /home/developer/www/adminer/index.php

#skype
sudo apt-get -y install skype

#zoom
sudo apt-get -y install libxcb-xtest0
wget https://zoom.us/client/latest/zoom_amd64.deb
sudo dpkg -i zoom*.deb
rm zoom_amd64.deb

#docker
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get -y update
sudo apt-get -y install docker-ce
sudo groupadd docker
sudo gpasswd -a ${USER} docker
sudo service docker restart

#dropbox
sudo apt -y install nautilus-dropbox

#gimp
sudo apt-get -y install gimp

#pip
sudo apt-get -y install python-pip

#autokey
sudo apt-get -y install autokey-gtk
mkdir ~/.config/autokey
mkdir ~/.config/autokey/data 
mkdir ~/.config/autokey/data/My\ Phrases
echo "{
    \"usageCount\": 2, 
    \"omitTrigger\": false, 
    \"prompt\": false, 
    \"description\": \"Comment\", 
    \"abbreviation\": {
        \"wordChars\": \"[^ \\n]\", 
        \"abbreviations\": [
            \"*test\"
        ], 
        \"immediate\": false, 
        \"ignoreCase\": false, 
        \"backspace\": true, 
        \"triggerInside\": false
    }, 
    \"hotkey\": {
        \"hotKey\": null, 
        \"modifiers\": []
    }, 
    \"modes\": [
        1
    ], 
    \"showInTrayMenu\": false, 
    \"matchCase\": false, 
    \"filter\": {
        \"regex\": null, 
        \"isRecursive\": false
    }, 
    \"type\": \"phrase\", 
    \"sendMode\": \"kb\"
}" >> ~/.config/autokey/data/My\ Phrases/.Comment1.json

echo "To test on: (TEST/DEV/STAGING/LIVE)
To test on: (mobile, desktop, both)
Link - 
Description - *[Co zostalo zrobione/zmienione (funkcjonalnosc, nie opis kodu) i jak powinno dzialac/wygladac obecnie.]*

Attachments:
*[Zrzut ekranu/filmik (jezeli przydatny)]*
*[Design (jezeli dotyczy taska)]*
*[Plik z contentem do wstawienia (jezeli dotyczy taska)]*" >> ~/.config/autokey/data/My\ Phrases/Comment1.txt

sudo chown -R developer ~/.config/autokey

echo "[D-BUS Service] 
Name=org.autokey.service 
Exec=/usr/bin/autokey" | sudo tee /usr/share/dbus-1/services/org.autokey.service2

#ZSH - pyta o hasło
sudo apt -y install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
