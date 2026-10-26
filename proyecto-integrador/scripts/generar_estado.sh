#!/bin/bash
# Genera estado.json con el codigo HTTP real de cada servicio (curl desde la VM)
export LC_ALL=C
IP="192.168.1.200"
SALIDA="$HOME/proyecto-integrador/docs/estado.json"
TMP="$SALIDA.tmp"
echo "{" > "$TMP"
primero=1
for p in 8080 8081 8090 8091 8092 3001 3002 5678 9000; do
  r=$(curl -sk -o /dev/null -w "%{http_code} %{time_total}" --max-time 5 "http://$IP:$p")
  codigo=${r%% *}
  ms=$(awk -v t="${r##* }" 'BEGIN{printf "%d", t*1000}')
  [ $primero -eq 0 ] && echo "," >> "$TMP"
  primero=0
  printf '"%s": {"codigo": "%s", "ms": %s}' "$p" "$codigo" "$ms" >> "$TMP"
done
echo "" >> "$TMP"
echo "}" >> "$TMP"
mv "$TMP" "$SALIDA"
