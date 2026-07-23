#!/bin/sh
set -e

if [ -z "$DATABASE_URL" ]; then
  echo "DATABASE_URL is not set" >&2
  exit 1
fi

DB_PATH="${DATABASE_URL#file:}"

case "$DB_PATH" in
  /*) DB_FILE="$DB_PATH" ;;
  *)  DB_FILE="/code/prisma/$DB_PATH" ;;
esac

if [ ! -f "$DB_FILE" ] || [ ! -s "$DB_FILE" ]; then
  echo "Database file '$DB_FILE' not found or empty, creating a new database..."
  npx prisma db push --skip-generate
fi

exec "$@"
