#!/bin/bash
ORIGEN="$HOME"
DESTINO="$HOME/respaldos"
FECHA=$(date +%Y%m%d_%H%M%S)
ARCHIVO="$DESTINO/respaldo_$FECHA.tar.gz"

tar -czf "$ARCHIVO" --exclude="$DESTINO" "$ORIGEN" 2>/dev/null
echo "Respaldo creado: $ARCHIVO"
