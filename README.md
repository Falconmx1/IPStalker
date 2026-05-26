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


📚 Guía de uso de las nuevas funcionalidades
1️⃣ Mapa para cada IP en modo batch (-m-all)
bash

# Abre un mapa en el navegador por cada IP del archivo
./ipstalker.sh -f ips.txt -m-all

2️⃣ Formato JSON (automático con extensión .json)
bash

# Exportar IP individual a JSON
./ipstalker.sh -i 8.8.8.8 -o resultado.json

# Exportar batch a JSON
./ipstalker.sh -f ips.txt -o resultados.json

# JSON + modo silencioso (solo genera archivo, sin output en pantalla)
./ipstalker.sh -f ips.txt -o datos.json -s

3️⃣ Barra de progreso (automática en modo batch sin exportación)
bash

# Verás algo como: [████████████░░░░░░░░] 60% (6/10)
./ipstalker.sh -f ips.txt

📄 Ejemplos de archivos generados
JSON output (resultados.json)
json

[
{
  "status": "success",
  "country": "United States",
  "countryCode": "US",
  "region": "CA",
  "regionName": "California",
  "city": "Mountain View",
  "zip": "94043",
  "lat": 37.4056,
  "lon": -122.0775,
  "timezone": "America/Los_Angeles",
  "isp": "Google LLC",
  "org": "Google LLC",
  "as": "AS15169 Google LLC",
  "query": "8.8.8.8"
},
{
  "status": "success",
  "country": "Australia",
  "countryCode": "AU",
  "region": "QLD",
  "regionName": "Queensland",
  "city": "Brisbane",
  "zip": "4000",
  "lat": -27.4679,
  "lon": 153.0325,
  "timezone": "Australia/Brisbane",
  "isp": "Cloudflare Inc",
  "org": "Cloudflare Inc",
  "as": "AS13335 Cloudflare Inc",
  "query": "1.1.1.1"
}
]

CSV output (resultados.csv)
csv

IP,País,Código,Región,Ciudad,Código Postal,Latitud,Longitud,ISP,Zona Horaria
"8.8.8.8","United States","US","California","Mountain View","94043","37.4056","-122.0775","Google LLC","America/Los_Angeles"
"1.1.1.1","Australia","AU","Queensland","Brisbane","4000","-27.4679","153.0325","Cloudflare Inc","Australia/Brisbane"
