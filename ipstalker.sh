#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
banner() {
    clear
    echo -e "${BLUE}"
    echo "  ██▓▒░ IPStalker v1.0 ░▒▓██"
    echo "  ============================"
    echo -e "      ${GREEN}Tracking IP - Linux/Termux${NC}"
    echo ""
}

# Verificar dependencias
check_deps() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}[!] curl no instalado. Instalando...${NC}"
        sudo apt install curl -y 2>/dev/null || pkg install curl -y 2>/dev/null
    fi
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}[!] jq no instalado. Instalando...${NC}"
        sudo apt install jq -y 2>/dev/null || pkg install jq -y 2>/dev/null
    fi
}

# Obtener información de IP
track_ip() {
    local ip=$1
    echo -e "${YELLOW}[!] Rastreando: ${ip}${NC}\n"
    
    response=$(curl -s "http://ip-api.com/json/${ip}")
    status=$(echo "$response" | jq -r '.status')
    
    if [ "$status" == "success" ]; then
        echo -e "${GREEN}IP:${NC}      $(echo "$response" | jq -r '.query')"
        echo -e "${GREEN}País:${NC}    $(echo "$response" | jq -r '.country') ($(echo "$response" | jq -r '.countryCode'))"
        echo -e "${GREEN}Región:${NC}  $(echo "$response" | jq -r '.regionName')"
        echo -e "${GREEN}Ciudad:${NC}  $(echo "$response" | jq -r '.city')"
        echo -e "${GREEN}Código postal:${NC} $(echo "$response" | jq -r '.zip')"
        echo -e "${GREEN}Lat/Lon:${NC} $(echo "$response" | jq -r '.lat') , $(echo "$response" | jq -r '.lon')"
        echo -e "${GREEN}ISP:${NC}     $(echo "$response" | jq -r '.isp')"
        echo -e "${GREEN}Zona horaria:${NC} $(echo "$response" | jq -r '.timezone')"
    else
        echo -e "${RED}[!] Error: IP inválida o no alcanzable.${NC}"
    fi
}

# Main
main() {
    banner
    check_deps
    
    if [ -n "$1" ]; then
        track_ip "$1"
    else
        read -p " Ingresa la IP a rastrear: " target
        if [ -n "$target" ]; then
            track_ip "$target"
        else
            echo -e "${RED}[!] No ingresaste ninguna IP.${NC}"
        fi
    fi
    echo ""
}

main "$1"
