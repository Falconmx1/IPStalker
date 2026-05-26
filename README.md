# 🔍 IPStalker – Rastreador de IP para Linux y Termux

**IPStalker** es una herramienta sencilla y rápida para obtener información detallada de una dirección IP: país, región, ciudad, coordenadas, ISP, zona horaria y más. Funciona en **Linux** y **Termux** (Android).

![Banner](https://via.placeholder.com/800x200/0a0a0a/00ffcc?text=IPStalker+-+Track+Any+IP)

---

## 📦 Características
- 🌍 Geolocalización completa (país, región, ciudad, latitud/longitud)
- 🏢 Nombre del ISP
- 🕒 Zona horaria
- 📡 Código postal (si está disponible)
- 🎨 Banner atractivo en la terminal
- ⚡ Resultados en JSON formateado

---

## 📱 Instalación

### En Linux (Debian/Ubuntu/Arch)
```bash
git clone https://github.com/Falconmx1/IPStalker.git
cd IPStalker
chmod +x ipstalker.sh

En Termux (Android)
bash

pkg update && pkg upgrade
pkg install git curl jq
git clone https://github.com/Falconmx1/IPStalker.git
cd IPStalker
chmod +x ipstalker.sh

🚀 Uso
bash

./ipstalker.sh

Luego ingresa la IP que deseas rastrear (ej: 8.8.8.8)

    También puedes pasar la IP directamente:
    bash

    ./ipstalker.sh 8.8.8.8

🖼️ Ejemplo de salida
text

[!] Rastreando: 8.8.8.8

IP: 8.8.8.8
País: United States (US)
Región: California
Ciudad: Mountain View
Código postal: 94043
Latitud / Longitud: 37.4056, -122.0775
ISP: Google LLC
Zona horaria: America/Los_Angeles

🛠️ Dependencias

    curl – para consultar la API

    jq – para parsear JSON

    bash 4+

Se instalan automáticamente con el script si no existen (excepto en Termux, hazlo manualmente con pkg install).
