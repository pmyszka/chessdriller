#!/bin/sh
set -e

DB_FILE="/code/prisma/${DATABASE_URL}"

if [ ! -f "$DB_FILE" ] || [ ! -s "$DB_FILE" ]; then
  echo "Database not found or empty, initializing..."
  npx prisma generate
  npx prisma db push
else
  echo "Database exists, ensuring Prisma client is up-to-date..."
  npx prisma generate
fi

exec "$@"
