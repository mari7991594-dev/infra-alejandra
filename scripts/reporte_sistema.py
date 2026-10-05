#!/usr/bin/env python3
"""Reporte del sistema usando solo la biblioteca estandar de Python 3."""

import os
import platform
import shutil
import socket
from datetime import datetime
from pathlib import Path

UMBRAL_DISCO = 80.0
CARPETA_REPORTES = Path.home() / "reportes"


def leer_meminfo():
    datos = {}
    with open("/proc/meminfo") as archivo:
        for linea in archivo:
            clave, valor = linea.split(":", 1)
            datos[clave] = int(valor.split()[0])
    total = datos["MemTotal"]
    disponible = datos["MemAvailable"]
    return total / 1024, (total - disponible) / 1024, (total - disponible) * 100 / total


def leer_uptime():
    with open("/proc/uptime") as archivo:
        segundos = int(float(archivo.read().split()[0]))
    dias, resto = divmod(segundos, 86400)
    horas, resto = divmod(resto, 3600)
    minutos = resto // 60
    return f"{dias} d {horas} h {minutos} min"


def main():
    ahora = datetime.now()
    total_mb, usada_mb, pct_ram = leer_meminfo()
    disco = shutil.disk_usage("/")
    pct_disco = disco.used * 100 / disco.total
    carga1, carga5, carga15 = os.getloadavg()

    lineas = [
        "REPORTE DEL SISTEMA",
        f"Fecha y hora: {ahora:%Y-%m-%d %H:%M:%S}",
        f"Equipo: {socket.gethostname()}",
        f"Sistema: {platform.system()} {platform.release()}",
        f"Tiempo encendido: {leer_uptime()}",
        f"Carga promedio (1, 5, 15 min): {carga1:.2f}, {carga5:.2f}, {carga15:.2f}",
        f"Memoria RAM: {usada_mb:.0f} MB usados de {total_mb:.0f} MB ({pct_ram:.1f} %)",
        f"Disco /: {disco.used / 2**30:.1f} GB usados de {disco.total / 2**30:.1f} GB ({pct_disco:.1f} %)",
    ]
    if pct_disco >= UMBRAL_DISCO:
        lineas.append(f"ALERTA: el disco supera el {UMBRAL_DISCO:.0f} %")

    texto = "\n".join(lineas)
    print(texto)

    CARPETA_REPORTES.mkdir(exist_ok=True)
    destino = CARPETA_REPORTES / f"reporte_sistema_{ahora:%Y%m%d_%H%M%S}.txt"
    destino.write_text(texto + "\n", encoding="utf-8")
    print(f"\nReporte guardado en: {destino}")


if __name__ == "__main__":
    main()
