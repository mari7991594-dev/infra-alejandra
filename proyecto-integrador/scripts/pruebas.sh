#!/bin/bash
# pruebas.sh - Pruebas de humo de la plataforma (Semana 15)
IP="192.168.1.200"
OK=0
FALLO=0

prueba_http() {
  local nombre="$1" url="$2" codigo
  for intento in 1 2 3 4 5 6; do
    codigo=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$url")
    [ "$codigo" != "000" ] && break
    sleep 5
  done
  case "$codigo" in
    200|301|302|307|308) echo "[OK]    $nombre -> HTTP $codigo ($url)"; OK=$((OK+1));;
    *)           echo "[FALLO] $nombre -> HTTP $codigo ($url)"; FALLO=$((FALLO+1));;
  esac
}

prueba_cmd() {
  local nombre="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "[OK]    $nombre"; OK=$((OK+1))
  else
    echo "[FALLO] $nombre"; FALLO=$((FALLO+1))
  fi
}

echo "=== Pruebas de humo - $(date '+%d/%m/%Y %H:%M:%S') ==="
prueba_http "web1 (nginx)"        "http://$IP:8080"
prueba_http "web3 (nginx)"        "http://$IP:8081"
prueba_http "s7-nginx"            "http://$IP:8090"
prueba_http "p6-app"              "http://$IP:8091"
prueba_http "p6-adminer"          "http://$IP:8092"
prueba_http "p6-kuma"             "http://$IP:3001"
prueba_http "uptime-kuma (3002)"  "http://$IP:3002"
prueba_http "n8n"                 "http://$IP:5678"
prueba_http "p6-portainer"        "http://$IP:9000"
prueba_http "portainer (https)"   "https://$IP:9443"
prueba_cmd  "DNS app.alejandra.pe" sh -c "dig +short @$IP app.alejandra.pe | grep -qx $IP"
prueba_cmd  "DNS docker.alejandra.pe" sh -c "dig +short @$IP docker.alejandra.pe | grep -qx $IP"
prueba_cmd  "MariaDB p6-db" docker exec p6-db sh -c 'mariadb-admin ping -uroot -p"$MARIADB_ROOT_PASSWORD" --silent || mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent'
prueba_cmd  "MariaDB s7-db" docker exec s7-db sh -c 'mariadb-admin ping -uroot -p"$MARIADB_ROOT_PASSWORD" --silent || mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent'
prueba_cmd  "Firewall p6-firewall (iptables)" docker exec p6-firewall iptables -S

echo "=== Resumen: $OK aprobadas, $FALLO fallidas ==="
[ "$FALLO" -eq 0 ] || exit 1
