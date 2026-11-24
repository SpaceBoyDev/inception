#!/bin/bash
mkdir -p secrets

echo "db_password" >> secrets/db_password.txt
echo "db_root_password" >> secrets/db_root_password.txt
echo "wp_admin_password" >> secrets/wp_admin_password.txt
echo "wp_user_password" >> secrets/wp_user_password.txt
