#!/usr/bin/env bash

dbserver=${1:-mariadb}

case $dbserver in
  mariadb)
    service="mariadb"
    server_package="mariadb-server"
    extras=""
    ;;
  mysql)
    service="mysqld"
    server_package="mysql-server"
    extras=""
    ;;
  *)
    echo "DB server not supported - ${dbserver}"
    exit 1
    ;;
esac

# Set keyboard layout to swiss german
localectl set-keymap ch
localectl set-x11-keymap ch

# Install packages
rpm -q $server_package &>/dev/null || dnf -y install $server_package $extras

# Place custom configuration
cp /vagrant/my.cnf.d/* /etc/my.cnf.d/

# Start the daemon and enable it on reboot
systemctl is-enabled $service &>/dev/null || systemctl enable $service &>/dev/null && echo "${service} enabled"
systemctl status $service &>/dev/null || systemctl start $service && echo "${service} started"


# Hardening stuff
if mysql -e "SELECT 1" &>/dev/null
then
  echo "Hardening the database server..."

  echo "- Drop test database"
  mysql -e "DROP DATABASE IF EXISTS test"

  echo "- Remove privileges on test database"
  mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"

  echo "- Remove anonymous users"
  mysql -e "DELETE FROM mysql.user WHERE User=''"

  echo "- Remove remote root"
  mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"

  echo "- Set password for user root to root12345"
  mysql -e "UPDATE mysql.user SET Password=PASSWORD('root12345') WHERE User='root'"

  # Reload privileges tables
  echo "- Flush privileges"
  mysql -e "FLUSH PRIVILEGES"

  echo "Hardening done"
else
  echo "Hardening already done probably"
fi

if ! mysql --user=demouser --password=demouser1 -e "SELECT 1" &>/dev/null
then
  echo "Provisioning an unprivileged user..."
  mysql_cmd="mysql --user=root --password=root12345"

  echo "- Add user demouser with password demouser1 without any permissions anything"
  $mysql_cmd -e "GRANT USAGE ON *.* TO 'demouser'@'%' IDENTIFIED BY 'demouser1'"

  echo "- Grant all privileges to the above demouser on the database wordpress"
  $mysql_cmd -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'demouser'"

  # Reload privileges tables
  echo "- Flush privileges"
  $mysql_cmd -e "FLUSH PRIVILEGES"

  echo "Provisioning an unprivileged user done"
else
  echo "Provisioned unprivileged user already"
fi
