#!/bin/bash
set -e

# Check if POSTGRES_USER and POSTGRES_PASSWORD are set
if [ -n "$POSTGRES_USER" ] && [ -n "$POSTGRES_PASSWORD" ]; then
  # Create a temporary file to store the password securely
  passfile=$(mktemp)
  echo "$POSTGRES_PASSWORD" > "$passfile"
  chmod 600 "$passfile"

  # Use su to switch user and execute PostgreSQL commands
  su -c "createuser -r -s -e --encrypted --no-password pos_admin" postgres
  echo "ALTER USER pos_admin WITH PASSWORD '$POS_ADMIN_PASSWORD';" | su -c "psql" postgres
  echo "pos_admin user is added."

  su -c "createuser -r -s -e --encrypted --no-password app_owner" postgres
  echo "ALTER USER app_owner WITH PASSWORD '$APP_OWNER_PASSWORD';" | su -c "psql" postgres
  echo "app_owner user is added."

  su -c "createuser -r -s -e --encrypted --no-password app_user" postgres
  echo "ALTER USER app_user WITH PASSWORD '$APP_USER_PASSWORD';" | su -c "psql" postgres
  echo "app_user user is added."

  su -c "createdb -e -O pos_admin defaultdb" postgres
  echo "defaultdb database is created."

  # Remove the temporary password file
  rm -f "$passfile"
else
  # If variables are not set, start PostgreSQL normally
  exec "$@"
fi
