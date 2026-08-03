#!/bin/bash
set -euo pipefail
: "${MANTIS_DB_HOST:?MANTIS_DB_HOST is required}" "${MANTIS_DB_PASSWORD:?MANTIS_DB_PASSWORD is required}" "${MANTIS_ADMIN_PASSWORD:?MANTIS_ADMIN_PASSWORD is required}" "${MANTIS_BASE_URL:?MANTIS_BASE_URL is required}"
mkdir -p /var/www/html/config
chown -R www-data:www-data /var/www/html/config
sed -ri 's/Listen 80/Listen 8000/' /etc/apache2/ports.conf
sed -ri 's/:80>/:8000>/' /etc/apache2/sites-available/000-default.conf
rm -f /etc/apache2/mods-enabled/mpm_event.load /etc/apache2/mods-enabled/mpm_event.conf /etc/apache2/mods-enabled/mpm_worker.load /etc/apache2/mods-enabled/mpm_worker.conf /etc/apache2/mods-enabled/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.conf
a2enmod mpm_prefork >/dev/null
apache2-foreground &
app=$!
trap 'kill -TERM "$app" 2>/dev/null || true; wait "$app"' TERM INT
for i in $(seq 1 120); do curl -fsS http://127.0.0.1:8000/ >/dev/null 2>&1 && break; sleep 2; done
if [ ! -s /var/www/html/config/config_inc.php ]; then
  for i in $(seq 1 120); do
    response=$(curl -sS -X POST http://127.0.0.1:8000/admin/install.php \
      --data-urlencode 'install=2' --data-urlencode 'db_type=mysqli' \
      --data-urlencode "hostname=${MANTIS_DB_HOST}:${MANTIS_DB_PORT:-3306}" \
      --data-urlencode "db_username=${MANTIS_DB_USER:-mantisbt}" \
      --data-urlencode "db_password=${MANTIS_DB_PASSWORD}" \
      --data-urlencode "database_name=${MANTIS_DB_NAME:-mantisbt}" \
      --data-urlencode "admin_username=${MANTIS_DB_USER:-mantisbt}" \
      --data-urlencode "admin_password=${MANTIS_DB_PASSWORD}" \
      --data-urlencode 'log_queries=0' || true)
    echo "$response" | grep -q 'MantisBT was installed successfully' && break
    sleep 3
  done
  [ -s /var/www/html/config/config_inc.php ] || { echo 'MantisBT installation failed' >&2; exit 1; }
fi
sed -i '/railway-base-url/d' /var/www/html/config/config_inc.php
printf "\n\$g_path = '%s'; // railway-base-url\n" "${MANTIS_BASE_URL%/}/" >> /var/www/html/config/config_inc.php
php -r 'define("CLI", true); require "/var/www/html/core.php"; $id=user_get_id_by_name("administrator"); user_set_password($id, getenv("MANTIS_ADMIN_PASSWORD"), true);'
kill -TERM "$app"
wait "$app" || true
apache2-foreground &
app=$!
for i in $(seq 1 60); do curl -fsS http://127.0.0.1:8000/login_page.php >/dev/null 2>&1 && break; sleep 1; done
[ ! -d /var/www/html/admin ] || mv /var/www/html/admin /var/www/html/.admin
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
proxy=$!
wait -n "$app" "$proxy"
status=$?
kill -TERM "$app" "$proxy" 2>/dev/null || true
wait || true
exit "$status"
