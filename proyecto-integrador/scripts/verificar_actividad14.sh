#!/bin/bash
# Verificación de la actividad de la Semana 14
# Uso: ~/scripts/verificar_actividad14.sh [REPO] [PROYECTO] [IP]
REPO="${1:-$HOME/infra-alejandra}"
PROY="${2:-$HOME/proyecto-6}"
IP="${3:-192.168.1.200}"
OK=0; FAIL=0

ok(){ echo "[OK]    $1"; OK=$((OK+1)); }
fail(){ echo "[FALLA] $1"; FAIL=$((FAIL+1)); }
check(){ if eval "$2" >/dev/null 2>&1; then ok "$1"; else fail "$1"; fi; }
buscar(){ find "$REPO" -maxdepth 3 -type f -iname "$1" -not -path '*/.git/*' 2>/dev/null | head -1; }

echo "=== 1. Estructura de carpetas del repositorio ($REPO) ==="
check "El repositorio existe" "[ -d '$REPO' ]"
for d in docs compose scripts backups; do
  check "Carpeta $d" "[ -d '$REPO/$d' ]"
done

echo
echo "=== 2. Evidencias de diseño ==="
REQ=$(buscar '*requerim*')
if [ -n "$REQ" ]; then
  ok "Archivo de requerimientos: $REQ"
  RF=$(grep -ciE '(^|[^A-Za-z])RF[- ]?[0-9]' "$REQ")
  RNF=$(grep -ciE '(^|[^A-Za-z])RNF[- ]?[0-9]' "$REQ")
  [ "$RF" -ge 3 ] && ok "Requerimientos funcionales: $RF (mínimo 3)" || fail "Requerimientos funcionales: $RF (mínimo 3)"
  [ "$RNF" -ge 3 ] && ok "Requerimientos no funcionales: $RNF (mínimo 3)" || fail "Requerimientos no funcionales: $RNF (mínimo 3)"
  check "Los RNF incluyen algo medible (cifra o porcentaje)" "grep -iE 'RNF' '$REQ' | grep -qE '[0-9]'"
else
  fail "No se encontró archivo de requerimientos (nombre con 'requerim')"
fi

DIAG=$(find "$REPO" -maxdepth 3 -type f \( -iname '*arquitectura*' -o -iname '*diagrama*' \) \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.svg' -o -iname '*.pdf' -o -iname '*.drawio' -o -iname '*.vsdx' \) \
  -not -path '*/.git/*' 2>/dev/null | head -1)
[ -n "$DIAG" ] && ok "Diagrama de arquitectura: $DIAG" || fail "No se encontró diagrama (imagen/pdf/drawio con 'arquitectura' o 'diagrama')"

PLAN=$(buscar '*plan*')
if [ -n "$PLAN" ]; then
  ok "Plan de implementación: $PLAN"
  for p in etapa responsable fecha; do
    check "El plan menciona '$p'" "grep -qi '$p' '$PLAN'"
  done
else
  fail "No se encontró plan de implementación (nombre con 'plan')"
fi

RIE=$(buscar '*riesgo*')
if [ -n "$RIE" ]; then
  ok "Matriz de riesgos: $RIE"
  for p in riesgo impacto mitigaci; do
    check "La matriz menciona '$p'" "grep -qi '$p' '$RIE'"
  done
  N=$(grep -c '[^[:space:]]' "$RIE")
  [ "$N" -ge 4 ] && ok "La matriz tiene contenido suficiente ($N líneas)" || fail "La matriz es muy corta ($N líneas)"
else
  fail "No se encontró matriz de riesgos (nombre con 'riesgo')"
fi

echo
echo "=== 3. Archivo compose y errores comunes ==="
C=$(find "$PROY" "$REPO" -maxdepth 2 -type f \( -name 'compose.y*ml' -o -name 'docker-compose.y*ml' \) 2>/dev/null | head -1)
if [ -n "$C" ]; then
  ok "Archivo compose: $C"
  check "YAML válido (docker compose config)" "docker compose -f '$C' config -q"
  check "Sin tabulaciones en el YAML" "! grep -qP '\t' '$C'"
  DUP=$(docker compose -f "$C" config --format json 2>/dev/null | python3 -c 'import json,sys,collections; d=json.load(sys.stdin); c=collections.Counter((p.get("published"),p.get("protocol","tcp")) for s in d["services"].values() for p in s.get("ports",[]) if p.get("published")); print(" ".join("%s/%s"%k for k,v in c.items() if v>1))')
  [ -z "$DUP" ] && ok "Sin puertos duplicados" || fail "Puertos duplicados: $DUP"
else
  fail "No se encontró compose.yaml"
fi

echo
echo "=== 4. Plataforma en funcionamiento ==="
N=$(docker ps -q | wc -l)
[ "$N" -ge 5 ] && ok "Contenedores en ejecución: $N" || fail "Contenedores en ejecución: $N (se esperaban 5 o más)"
check "Todos con política de reinicio" "[ \$(docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' \$(docker ps -q) | grep -cE '^(no)?\$') -eq 0 ]"
check "Ningún contenedor reiniciándose" "! docker ps --format '{{.Status}}' | grep -qi restarting"
check "Web responde en $IP:8091" "[ \$(curl -s -o /dev/null -w '%{http_code}' http://$IP:8091) = 200 ]"
check "Uptime Kuma responde en $IP:3001" "curl -s -o /dev/null -w '%{http_code}' http://$IP:3001 | grep -qE '^(200|301|302)\$'"
command -v dig >/dev/null || echo "(Instala dig con: sudo apt install -y dnsutils)"
check "DNS resuelve docker.alejandra.pe" "dig +short @$IP docker.alejandra.pe | grep -qx '$IP'"
check "DNS resuelve app.alejandra.pe" "dig +short @$IP app.alejandra.pe | grep -qx '$IP'"
DB=$(docker ps --format '{{.Names}} {{.Image}}' | grep -i mariadb | awk '{print $1}' | head -1)
db_vivo(){ docker exec "$DB" sh -c 'mariadb-admin ping -uroot -p"${MARIADB_ROOT_PASSWORD:-$MYSQL_ROOT_PASSWORD}" 2>&1 || mysqladmin ping -uroot -p"${MARIADB_ROOT_PASSWORD:-$MYSQL_ROOT_PASSWORD}" 2>&1' | grep -qi alive; }
db_vivo(){ docker exec "$DB" sh -c 'mariadb-admin ping -uroot -p"${MARIADB_ROOT_PASSWORD:-$MYSQL_ROOT_PASSWORD}" 2>&1 || mysqladmin ping -uroot -p"${MARIADB_ROOT_PASSWORD:-$MYSQL_ROOT_PASSWORD}" 2>&1' | grep -qi alive; }
[ -n "$DB" ] && check "MariaDB ($DB) activa" db_vivo || fail "No hay contenedor de MariaDB"
check "UFW activo" "sudo ufw status | grep -q 'Status: active'"

echo
echo "=== 5. Repositorio Git ==="
check "Es un repositorio Git" "git -C '$REPO' rev-parse --is-inside-work-tree"
check "Tiene commits" "git -C '$REPO' log -1"
check "Remoto de GitHub configurado" "git -C '$REPO' remote -v | grep -q github.com"
check "Sin cambios pendientes de commit" "[ -z \"\$(git -C '$REPO' status --porcelain)\" ]"

echo
echo "=============================="
echo "Correctas: $OK   Fallidas: $FAIL"
[ "$FAIL" -eq 0 ] && echo "Actividad 14 verificada." || echo "Revisa las líneas [FALLA]."
exit $FAIL
