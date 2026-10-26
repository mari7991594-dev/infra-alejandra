PROYECTO INTEGRADOR: PLATAFORMA EMPRESARIAL DE TI

Esta plataforma corre en una máquina virtual con Ubuntu Server 20.04 llamada docker, con dirección IP 192.168.1.200, creada sobre Proxmox. Reúne quince contenedores distribuidos en cuatro proyectos de Docker Compose, con servicios web, base de datos, DNS, firewall, monitoreo, automatización y gestión de contenedores. Autora: María Alejandra Ortega Dávila. Docente: Ing. Carlos Abilio Angulo Zegarra.

REQUISITOS

Se necesita Docker Engine instalado desde el repositorio oficial y el plugin Docker Compose versión 2, que se comprueba con los comandos docker --version y docker compose version. También se necesitan curl y dig, este último incluido en el paquete dnsutils, que se instala con sudo apt install -y dnsutils. Los proyectos que usan MariaDB leen sus contraseñas de un archivo .env ubicado junto a cada compose.yaml, con las variables MARIADB_ROOT_PASSWORD y MARIADB_PASSWORD; ese archivo no se sube a Git.

SERVICIOS Y PUERTOS

El proyecto s7-compose, en la carpeta ~/s7-compose, contiene s7-nginx en el puerto 8090, s7-app y s7-db con MariaDB. El proyecto proyecto-6, en la carpeta ~/proyecto-6, contiene p6-app con Nginx en el puerto 8091, p6-db con MariaDB, p6-dns con dnsmasq en 192.168.1.200 puerto 53, p6-firewall con reglas de iptables, p6-adminer en el puerto 8092, p6-kuma con Uptime Kuma en el puerto 3001 y p6-portainer en el puerto 9000. El proyecto monitoreo, en la carpeta ~/monitoreo, contiene una segunda instancia de Uptime Kuma en el puerto 3002. El proyecto proyecto-integrador, definido en ~/proyecto-integrador/compose/compose.yaml, contiene web1 en el puerto 8080, web3 en el puerto 8081, n8n en el puerto 5678 y Portainer con HTTPS en el puerto 9443.

DESPLIEGUE

Los proyectos se levantan en este orden, cada uno desde su carpeta, y Compose aplica automáticamente el archivo compose.override.yaml cuando existe:

    cd ~/s7-compose && docker compose up -d
    cd ~/proyecto-6 && docker compose up -d
    cd ~/monitoreo && docker compose up -d

El proyecto integrador usa tres volúmenes externos que deben existir antes de levantarlo. En una instalación nueva se crean con el primer comando y luego se levanta el proyecto con el segundo:

    docker volume create datos-lab && docker volume create n8n_data && docker volume create portainer_data
    docker compose -f ~/proyecto-integrador/compose/compose.yaml up -d

Para comprobar que los cuatro proyectos están en ejecución se usa docker compose ls, que debe listar monitoreo, proyecto-6, proyecto-integrador y s7-compose, y docker ps, que debe mostrar los quince contenedores.

PRUEBAS

El script ~/proyecto-integrador/scripts/pruebas.sh ejecuta quince pruebas de humo: diez consultas HTTP con curl que validan el código de respuesta, dos consultas DNS con dig a los nombres app.alejandra.pe y docker.alejandra.pe, dos pruebas de conexión a las bases de datos p6-db y s7-db y una revisión de las reglas de iptables de p6-firewall. Se ejecuta con el comando siguiente, que además guarda la salida como evidencia:

    ~/proyecto-integrador/scripts/pruebas.sh | tee ~/proyecto-integrador/evidencias/salida_pruebas.txt

Se aceptan como respuesta válida los códigos HTTP 200, 301, 302, 307 y 308, y el script reintenta hasta seis veces con cinco segundos de pausa cuando un servicio todavía no acepta conexiones. Termina con un resumen de pruebas aprobadas y fallidas y con código de salida 1 si alguna falla. El resultado esperado es quince aprobadas y cero fallidas. Los defectos encontrados y sus correcciones están en docs/registro_defectos.txt, y docs/panel.html es un panel visual de estado que se sirve con python3 -m http.server 8099 desde la carpeta docs. El panel lee el archivo estado.json, que genera cada minuto el script scripts/generar_estado.sh programado en cron con la línea * * * * * ~/proyecto-integrador/scripts/generar_estado.sh, y que mide cada servicio con curl desde la máquina virtual.

RESPALDO Y RECUPERACIÓN

El script ~/scripts/backup.sh respalda la carpeta ~/s7-compose hacia ~/respaldos y genera su suma de verificación con sha256sum. Los datos de n8n y de Portainer se respaldan desde sus volúmenes con estos comandos, que crean archivos comprimidos con la fecha del día en la carpeta ~/respaldos:

    docker run --rm -v n8n_data:/data -v ~/respaldos:/backup alpine tar czf /backup/n8n_data_$(date +%Y%m%d).tgz -C /data .
    docker run --rm -v portainer_data:/data -v ~/respaldos:/backup alpine tar czf /backup/portainer_data_$(date +%Y%m%d).tgz -C /data .

Para restaurar un volumen se detiene el contenedor correspondiente y se extrae el archivo comprimido dentro del volumen, por ejemplo para n8n:

    docker stop n8n
    docker run --rm -v n8n_data:/data -v ~/respaldos:/backup alpine sh -c "cd /data && tar xzf /backup/n8n_data_AAAAMMDD.tgz"
    docker start n8n

Antes de confiar en un respaldo se verifica su integridad con sha256sum y se prueba la restauración en una carpeta temporal, como se hizo en la Semana 12.

SEGURIDAD

El firewall UFW de la máquina virtual está activo con política de denegar el tráfico entrante y solo permite los puertos 22 y 80 por TCP. Cualquier puerto adicional, como el 8099 del panel, se abre solo mientras se usa y se cierra después con sudo ufw delete allow seguido de la regla.

OTROS CONTENEDORES

Además de los quince contenedores en ejecución, existen tres contenedores detenidos, prometheus, grafana y node-exporter, que corresponden al trabajo de monitoreo de la Semana 11. Se crearon fuera de Docker Compose y no forman parte de la plataforma desplegada en esta actividad, cuyo monitoreo de disponibilidad se realiza con las dos instancias de Uptime Kuma. Si se necesitan de nuevo, se inician con el comando siguiente:

    docker start prometheus grafana node-exporter
