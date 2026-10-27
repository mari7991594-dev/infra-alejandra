#!/bin/bash
# Respaldo del proyecto integrador: bases de datos y configuración
DESTINO="$HOME/proyecto-integrador/backups"
FECHA=$(date +%Y%m%d_%H%M%S)
TMP=$(mktemp -d)
mkdir -p "$DESTINO"

for DB in p6-db s7-db; do
  if ! docker exec "$DB" sh -c 'mariadb-dump -uroot -p"$MARIADB_ROOT_PASSWORD" --all-databases' > "$TMP/$DB.sql"; then
    echo "$(date) ERROR: volcado de $DB" >> "$DESTINO/respaldo.log"
    rm -rf "$TMP"; exit 1
  fi
done

if tar -czf "$DESTINO/proyecto_$FECHA.tar.gz" --exclude='proyecto-integrador/backups' \
     -C "$TMP" p6-db.sql s7-db.sql \
     -C "$HOME" proyecto-integrador proyecto-6 monitoreo s7-compose; then
  echo "$(date) OK: proyecto_$FECHA.tar.gz" >> "$DESTINO/respaldo.log"
else
  echo "$(date) ERROR al crear proyecto_$FECHA.tar.gz" >> "$DESTINO/respaldo.log"
fi

rm -rf "$TMP"
find "$DESTINO" -name "proyecto_*.tar.gz" -mtime +7 -delete
