#!/usr/bin/env bash

# Set keyboard layout to swiss german
localectl set-keymap ch
localectl set-x11-keymap ch

# We will definitely need some packages from the EPEL repository.
# In addition the have latest PHP packages from a trustworthy source
# we go with Remi's RPM repostiory. See https://rpms.remirepo.net/wizard/
# for its usage.
rpm -q epel-release &>/dev/null || dnf -y install epel-release
rpm -q remi-release &>/dev/null || dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm

# First install the Aapche webserver
rpm -q httpd  &>/dev/null || dnf -y install httpd

if ! command -v php &>/dev/null
then
  # Install PHP 8.0 from its respective module
  # Documentation about the new concept of modularity in Enterprise Linxes can be
  # found at https://docs.pagure.org/modularity/
  dnf -y module reset php
  dnf -y module install php:remi-8.0
  # The above already installed the first six package from the list below. Nevertheless
  # mention them again and add some additionally need extensions that Flarum needs.
  dnf -y install \
    php \
    php-cli \
    php-common \
    php-fpm \
    php-mbstring \
    php-xml \
    php-mysqlnd
fi

# Place an PHP script to Apache's DocumentRoot to print out phpinfo()
phpinfo_file=/var/www/html/phpinfo.php
[ ! -f "${phpinfo_file}" ] && echo "<?php phpinfo();" > "${phpinfo_file}"

# Start Apache
systemctl is-enabled httpd &>/dev/null || (systemctl enable httpd &>/dev/null && echo "httpd enabled")
systemctl status httpd &>/dev/null || (systemctl start httpd && echo "httpd started")
