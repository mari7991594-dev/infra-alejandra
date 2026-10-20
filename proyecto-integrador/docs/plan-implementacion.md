# Plan de implementación

El plan se ordena en etapas, cada una con su responsable, su fecha y su evidencia. La responsable de todas las etapas es María Alejandra Ortega Dávila.

Etapa 1, preparación de la infraestructura. Consiste en crear en Proxmox una máquina virtual nueva llamada docker, instalar Ubuntu Server 20.04 con disco de 50 GB y activar SSH. Responsable: María Alejandra Ortega Dávila. Fecha: octubre de 2026. Evidencia: captura de ip a y de hello-world ejecutado.

Etapa 2, instalación de Docker y práctica de Compose. Consiste en instalar Docker desde el repositorio oficial y levantar Nginx, httpd y MariaDB con red y volumen. Responsable: María Alejandra Ortega Dávila. Fecha: octubre de 2026. Evidencia: captura de docker compose ps y de la persistencia comprobada.

Etapa 3, despliegue de los servicios del proyecto. Consiste en levantar MariaDB, Nginx en el puerto 8091, dnsmasq en el puerto 53, el contenedor de firewall con iptables y Uptime Kuma para Proxmox. Responsable: María Alejandra Ortega Dávila. Fecha: octubre de 2026. Evidencia: captura de docker ps y resolución de los nombres con dig.

Etapa 4, seguridad y respaldo. Consiste en activar UFW con política de denegar por defecto, crear el script backup.sh y probar la restauración con sha256sum. Responsable: María Alejandra Ortega Dávila. Fecha: octubre de 2026. Evidencia: captura de ufw status y de la comprobación sha256.

Etapa 5, diseño y documentación de la arquitectura. Consiste en redactar los requerimientos, dibujar el diagrama por capas, elaborar este plan y la matriz de riesgos, y subir todo al repositorio. Responsable: María Alejandra Ortega Dávila. Fecha: 16 de noviembre de 2026. Evidencia: carpeta docs del repositorio en GitHub.

Etapa 6, servidor de correo Zimbra en contenedor. Consiste en ampliar la memoria de la máquina virtual y desplegar Zimbra como sexto contenedor sobre el dominio alejandra.pe. Responsable: María Alejandra Ortega Dávila. Fecha: 30 de noviembre de 2026. Evidencia: captura del panel de administración de Zimbra.

La estructura del repositorio es la siguiente: la carpeta docs guarda los documentos de diseño, compose guarda el archivo de definición de los servicios, scripts guarda los scripts de respaldo y verificación, backups guarda los respaldos y evidencias guarda las capturas de cada etapa.
