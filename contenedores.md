# Contenedores instalados

Actualizado: 08/10/2026 00:51

| Nombre | Imagen | Estado | Puertos |
|---|---|---|---|
| p6-portainer | portainer/portainer-ce:lts | Up 52 minutes | 8000/tcp, 9443/tcp, 0.0.0.0:9000->9000/tcp, [::]:9000->9000/tcp |
| p6-adminer | adminer | Up 52 minutes | 0.0.0.0:8092->8080/tcp, [::]:8092->8080/tcp |
| p6-app | nginx:alpine | Up 52 minutes | 0.0.0.0:8091->80/tcp, [::]:8091->80/tcp |
| p6-dns | strm/dnsmasq | Up 52 minutes | 192.168.1.60:53->53/tcp, 192.168.1.60:53->53/udp |
| p6-firewall | alpine:3.20 | Up 52 minutes |  |
| p6-kuma | louislam/uptime-kuma:1 | Up 52 minutes (healthy) | 0.0.0.0:3001->3001/tcp, [::]:3001->3001/tcp |
| p6-db | mariadb:11 | Up 52 minutes | 3306/tcp |
| s7-nginx | nginx:latest | Exited (255) 2 days ago | 0.0.0.0:8090->80/tcp, [::]:8090->80/tcp |
| s7-app | httpd:2.4 | Exited (255) 2 days ago | 80/tcp |
| s7-db | mariadb:11 | Exited (255) 2 days ago | 3306/tcp |
| web3 | nginx | Up 52 minutes | 0.0.0.0:8081->80/tcp, [::]:8081->80/tcp |
| web1 | nginx | Up 52 minutes | 0.0.0.0:8080->80/tcp, [::]:8080->80/tcp |
| clever_heisenberg | hello-world | Exited (0) 9 days ago |  |
