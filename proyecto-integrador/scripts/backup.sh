#!/bin/bash
FECHA=$(date +%F)
DESTINO="$HOME/respaldos"
mkdir -p "$DESTINO"
tar -czf "$DESTINO/datos-$FECHA.tar.gz" -C "$HOME" datos-prueba
( cd "$DESTINO" && sha256sum "datos-$FECHA.tar.gz" > "datos-$FECHA.tar.gz.sha256" )
echo "Respaldo creado: $DESTINO/datos-$FECHA.tar.gz"
