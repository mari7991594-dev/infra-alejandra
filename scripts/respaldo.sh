#!/bin/bash
# Respaldo comprimido de una carpeta origen con fecha en el nombre
ORIGEN="$HOME/s7-compose"
DESTINO="$HOME/respaldos"
FECHA=$(date +%Y%m%d_%H%M%S)
ARCHIVO="$DESTINO/respaldo_$FECHA.tar.gz"

mkdir -p "$DESTINO"

if [ ! -d "$ORIGEN" ]; then
    echo "$(date) ERROR: no existe $ORIGEN" >> "$DESTINO/respaldo.log"
    exit 1
fi

if tar -czf "$ARCHIVO" -C "$(dirname "$ORIGEN")" "$(basename "$ORIGEN")"; then
    echo "$(date) OK: $ARCHIVO" >> "$DESTINO/respaldo.log"
else
    echo "$(date) ERROR al crear $ARCHIVO" >> "$DESTINO/respaldo.log"
    exit 1
fi

# Conservar solo los respaldos de los últimos 7 días
find "$DESTINO" -name "respaldo_*.tar.gz" -mtime +7 -delete
