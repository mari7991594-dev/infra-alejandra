# Matriz de riesgos

Riesgo 1: la memoria de la máquina virtual es insuficiente para Zimbra, porque la máquina docker dispone de unos 3,8 GiB de RAM. Impacto: alto, porque el sexto contenedor no podría ejecutarse y el sistema de correo quedaría incompleto. Mitigación: ampliar la memoria de la máquina virtual desde Proxmox antes de desplegar Zimbra y configurar espacio de intercambio.

Riesgo 2: cambio de la dirección IP de la máquina virtual, algo que ya ocurrió al pasar de 192.168.1.60 a 192.168.1.200. Impacto: alto, porque el DNS y la página dejan de coincidir con la dirección real. Mitigación: reservar una IP fija en el servidor DHCP o en la configuración de red y concentrar la dirección en un solo lugar para actualizarla de una sola vez.

Riesgo 3: puertos duplicados entre servicios, porque dos contenedores no pueden publicar el mismo puerto del anfitrión. Impacto: medio, porque uno de los servicios no arrancaría. Mitigación: mantener un mapa de puertos en el diseño y validar el archivo con docker compose config antes de levantar.

Riesgo 4: pérdida de datos de MariaDB por borrado accidental del volumen o falla del disco. Impacto: alto, porque se perdería la información almacenada. Mitigación: usar volúmenes con nombre, ejecutar backup.sh con suma sha256 y probar periódicamente la restauración.

Riesgo 5: error de indentación en el archivo YAML. Impacto: medio, porque la plataforma no se levanta. Mitigación: usar 2 espacios, no usar tabulaciones y validar con docker compose config -q antes de cada despliegue.

Riesgo 6: falta de espacio en disco por acumulación de imágenes y registros, con un disco de 50 GB. Impacto: medio, porque los contenedores podrían detenerse. Mitigación: revisar el uso con docker system df y limpiar imágenes sin uso de forma periódica.
