# infra-equipo

Repositorio de infraestructura del laboratorio de Administración de Centros de Cómputo.

## Descripción
Despliegue con Docker Compose de Nginx, Apache httpd y MariaDB con red propia y volumen persistente.

## Requisitos
- Ubuntu Server 20.04 con Docker y el plugin Docker Compose v2
- Archivo .env creado a partir de .env.example, con las contraseñas de MariaDB (no se sube al repositorio)

## Cómo desplegar
    cp .env.example .env
    docker compose up -d
    docker compose ps
Para detener el entorno: docker compose down
