#!/bin/bash
set -euox pipefail

# shellcheck disable=SC2034
# import entrypoint variables.
# shellcheck disable=SC1091
source /var/entrypoint/entrypoint-var.env

has_error() {
    [ ! -f "/var/www/logs/entrypoint_error.log" ]; touch /var/www/logs/entrypoint_error.log
    while getopts "m:" opt; do
        case $opt in
            m) multi+=("$OPTARG");;
            *) echo "Error: -m";;
        esac
    done
    shift $((OPTIND -1))
    for val in "${multi[@]}"; do
        printf "***Error: %s\n" "$val" >> /var/www/logs/entrypoint_error.log
    done
    exit 1
}

chown -R www-una:www-una /var/www/certs
sed -i 's/www-data/www-una/g' /etc/apache2/envvars
sed -i "/# Global/aServerName ${SITE_HOST}:80" /etc/apache2/apache2.conf
sed -i "s/${SITE_HOST}/${SITE_HOST}/g" /etc/apache2/sites-available/una.conf

if [ ! -d "/var/www/logs/php" ]; then
    mkdir -p /var/www/logs/php
    chmod 777 /var/log/php /var/www/logs/php
    ln -s /var/logs/php /var/www/logs/php
    ln -s /dev/stderr /var/www/logs/php/error-stderr.log
    chown -R www-una:www-una /var/www /var/log/php
fi

if [ -d "/var/www/html/install/" ] && [ ! -f "/var/www/html/inc/header.inc.php" ]; then
    chown -R www-una:www-una /var/www/html

    DB_PARAMS="--db_host=$MYSQL_HOST --db_port=$MYSQL_PORT --db_sock=$MYSQL_SOCK --db_name=$MYSQL_NAME --db_user=$MYSQL_USER --db_password=$MYSQL_PASS"
    SITE_PARAMS="--site_url=$SITE_URL --server_http_host=$SITE_HOST --server_php_self=$SITE_SELF --server_doc_root=$SITE_ROOT --site_title=$SITE_TITLE --site_email=$SITE_EMAIL"
    ADMIN_PARAMS="--admin_username=$ADMIN_USER --admin_email=$ADMIN_EMAIL --admin_password=$ADMIN_PASSWD"
    KEY_PARAMS="--oauth_key=$UNA_KEY --oauth_secret=$UNA_SECRET"
    
    if ! su -l www-una -c "php /var/www/html/install/cmd.php $DB_PARAMS $SITE_PARAMS $ADMIN_PARAMS $KEY_PARAMS"; then has_error -m "PHP CLI"; fi
    
    if [ ! -f "/var/www/html/inc/header.inc.php" ]; then 
        has_error -m "Missing header.inc.php"
    else
        rm -rf /var/www/html/install/
        chown -R www-una:www-una /var/www/html/
    fi
fi

exec "$@"