# Requerimientos del proyecto integrador

La plataforma se ejecuta en la máquina virtual docker, con Ubuntu Server 20.04 y Docker Compose, alojada en Proxmox, con la dirección 192.168.1.200 y el dominio alejandra.pe. Los requerimientos se redactan de forma medible para poder comprobarlos uno por uno.

## Requerimientos funcionales

RF1. La plataforma debe publicar una página web mediante un servidor Nginx accesible desde la red local por el puerto 8091.

RF2. La plataforma debe resolver los nombres docker.alejandra.pe y app.alejandra.pe hacia la dirección 192.168.1.200 mediante un servidor DNS dnsmasq que atienda el puerto 53.

RF3. La plataforma debe almacenar datos de forma persistente en un servidor MariaDB que use un volumen propio, de modo que la información sobreviva al reinicio del contenedor.

RF4. La plataforma debe permitir supervisar el estado de los servicios y del servidor Proxmox mediante Uptime Kuma, accesible por el puerto 3001.

## Requerimientos no funcionales

RNF1. Disponibilidad: todos los contenedores deben tener la política de reinicio unless-stopped y volver a estar activos en menos de 5 minutos tras reiniciar la máquina virtual. Se comprueba con el comando docker ps.

RNF2. Seguridad: el firewall UFW debe estar activo con política de denegar por defecto, permitiendo solo el tráfico necesario, y el acceso administrativo debe hacerse únicamente por SSH. Se comprueba con sudo ufw status verbose.

RNF3. Recuperación: debe existir un respaldo comprimido con suma sha256 cuya restauración coincida al 100 % con el original. Se comprueba con sha256sum -c y con diff.

RNF4. Escalabilidad y mantenimiento: toda la plataforma debe definirse en un único archivo compose versionado en Git, sin puertos duplicados, de manera que agregar un servicio nuevo requiera menos de 10 líneas y no obligue a rediseñar. Se comprueba con docker compose config.

RNF5. Rendimiento: la página web debe responder con código HTTP 200 en menos de 2 segundos. Se comprueba con curl y la opción -w '%{time_total}'.
