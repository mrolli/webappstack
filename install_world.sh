#!/usr/bin/env bash

mysql_cmd="mysql --user=root --password=root12345"

# First create user for the task if necessary
if ! mysql --user=globe --password=trotter -e "SELECT 1" &>/dev/null
then
  echo "Provisioning an unprivileged user..."

  echo "- Add user globe with password trotter without any permissions on anything"
  $mysql_cmd -e "GRANT USAGE ON *.* TO 'globe'@'%' IDENTIFIED BY 'trotter'"

  # Reload privileges tables
  echo "- Flush privileges"
  $mysql_cmd -e "FLUSH PRIVILEGES"

  echo "Provisioning an unprivileged user done"
else
  echo "Unprivileged user already provisioned"
fi

echo "Building the world"

echo "- Deleting old world if necessary"
$mysql_cmd -e "DROP DATABASE IF EXISTS world"

echo "- Grant all privileges to the above demouser on the database wordpress"
$mysql_cmd -e "GRANT SELECT ON world.* TO 'globe'"

# Reload privileges tables
echo "- Flush privileges"
$mysql_cmd -e "FLUSH PRIVILEGES"

echo "- Fetching world data"
world_url="https://downloads.mysql.com/docs/world-db.tar.gz"
world_archive=$(basename "${world_url}")
wget "${world_url}" &>/dev/null
wait

echo "- Storing world data"
tar xf "${world_archive}"
$mysql_cmd < world-db/world.sql

echo "- Clean up WALL-E"
rm "${world_archive}"
rm -rf "world-db"

echo "The world is ready!"
