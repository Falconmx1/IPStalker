#!/bin/bash

# ==============================================
# IPStalker v2.0 - Modo batch, CSV, mapa, silencioso
# ==============================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuración por defecto
SILENT_MODE=false
OUTPUT_FILE=""
BATCH_FILE=""
OPEN_MAP=false

# Banner (se omite en modo silencioso)
banner() {
    if [ "$SILENT_MODE" = false ]; then
        clear
        echo -e "${BLUE}"
        echo "  ██▓▒░ IPStalker v2.0 ░▒▓██"
        echo "  ============================"
        echo -e "      ${GREEN}Tracking IP - Batch + CSV + Mapa${NC}"
        echo ""
    fi
}

# Mostrar ayuda
show_help() {
    echo -e "${CYAN}Uso: $0 [OPCIÓN] [IP o archivo]${NC}"
    echo ""
    echo "Opciones:"
    echo "  -i IP               Rastrear una sola IP"
    echo "  -f archivo.txt      Rastrear múltiples IPs desde un archivo (una por línea)"
    echo "  -o archivo.csv      Exportar resultados a CSV (o TXT si es .txt)"
    echo "  -m                  Abrir mapa en navegador con las coordenadas"
    echo "  -s                  Modo silencioso (solo muestra IP y país)"
    echo "  -h                  Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 -i 8.8.8.8"
    echo "  $0 -i 8.8.8.8 -m"
    echo "  $0 -f ips.txt -o resultados.csv"
    echo "  $0 -f ips.txt -s"
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

# Abrir mapa en navegador
open_map_url() {
    local lat=$1
    local lon=$2
    local url="https://www.google.com/maps?q=${lat},${lon}"
    
    if [ "$OPEN_MAP" = true ]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open "$url" 2>/dev/null
        elif command -v termux-open &> /dev/null; then
            termux-open "$url" 2>/dev/null
        elif command -v open &> /dev/null; then
            open "$url" 2>/dev/null
        else
            echo -e "${YELLOW}[!] No se pudo abrir navegador. URL: $url${NC}"
        fi
    fi
}

# Obtener información de IP (modo normal)
track_ip_normal() {
    local ip=$1
    local output_mode=$2  # "" = pantalla, "csv" = formato CSV
    
    response=$(curl -s "http://ip-api.com/json/${ip}")
    status=$(echo "$response" | jq -r '.status')
    
    if [ "$status" == "success" ]; then
        local query=$(echo "$response" | jq -r '.query')
        local country=$(echo "$response" | jq -r '.country')
        local countryCode=$(echo "$response" | jq -r '.countryCode')
        local region=$(echo "$response" | jq -r '.regionName')
        local city=$(echo "$response" | jq -r '.city')
        local zip=$(echo "$response" | jq -r '.zip')
        local lat=$(echo "$response" | jq -r '.lat')
        local lon=$(echo "$response" | jq -r '.lon')
        local isp=$(echo "$response" | jq -r '.isp')
        local timezone=$(echo "$response" | jq -r '.timezone')
        
        if [ "$output_mode" == "csv" ]; then
            # Formato CSV: IP,País,Código,Región,Ciudad,Código Postal,Lat,Lon,ISP,Zona Horaria
            echo "\"$query\",\"$country\",\"$countryCode\",\"$region\",\"$city\",\"$zip\",\"$lat\",\"$lon\",\"$isp\",\"$timezone\""
        else
            # Modo normal (pantalla)
            echo -e "${GREEN}IP:${NC}      $query"
            echo -e "${GREEN}País:${NC}    $country ($countryCode)"
            echo -e "${GREEN}Región:${NC}  $region"
            echo -e "${GREEN}Ciudad:${NC}  $city"
            echo -e "${GREEN}Código postal:${NC} $zip"
            echo -e "${GREEN}Lat/Lon:${NC} $lat , $lon"
            echo -e "${GREEN}ISP:${NC}     $isp"
            echo -e "${GREEN}Zona horaria:${NC} $timezone"
            echo ""
            
            # Abrir mapa si está activado
            open_map_url "$lat" "$lon"
        fi
        return 0
    else
        if [ "$output_mode" != "csv" ]; then
            echo -e "${RED}[!] Error: IP inválida o no alcanzable: $ip${NC}"
            echo ""
        fi
        return 1
    fi
}

# Obtener información de IP (modo silencioso - solo IP y país)
track_ip_silent() {
    local ip=$1
    response=$(curl -s "http://ip-api.com/json/${ip}")
    status=$(echo "$response" | jq -r '.status')
    
    if [ "$status" == "success" ]; then
        local country=$(echo "$response" | jq -r '.country')
        echo "$ip -> $country"
        return 0
    else
        echo "$ip -> [ERROR]"
        return 1
    fi
}

# Procesar una sola IP
process_single_ip() {
    local ip=$1
    
    if [ "$SILENT_MODE" = true ]; then
        track_ip_silent "$ip"
    else
        echo -e "${YELLOW}[!] Rastreando: ${ip}${NC}\n"
        track_ip_normal "$ip"
    fi
}

# Procesar archivo batch
process_batch() {
    local batch_file=$1
    local is_csv_export=false
    
    if [ ! -f "$batch_file" ]; then
        echo -e "${RED}[!] Archivo no encontrado: $batch_file${NC}"
        exit 1
    fi
    
    # Contar IPs
    local total_ips=$(grep -c -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' "$batch_file")
    if [ $total_ips -eq 0 ]; then
        echo -e "${RED}[!] No se encontraron IPs válidas en el archivo${NC}"
        exit 1
    fi
    
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${CYAN}[+] Procesando $total_ips IPs...${NC}\n"
    fi
    
    # Si hay archivo de salida, preparar CSV
    if [ -n "$OUTPUT_FILE" ]; then
        is_csv_export=true
        # Crear archivo CSV con cabecera
        echo "IP,País,Código,Región,Ciudad,Código Postal,Latitud,Longitud,ISP,Zona Horaria" > "$OUTPUT_FILE"
    fi
    
    # Leer cada línea del archivo
    local counter=0
    while IFS= read -r ip; do
        # Validar formato IP simple
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            counter=$((counter + 1))
            
            if [ "$SILENT_MODE" = false ] && [ "$is_csv_export" = false ]; then
                echo -e "${CYAN}[$counter/$total_ips]${NC} Procesando: $ip"
            fi
            
            if [ "$SILENT_MODE" = true ]; then
                track_ip_silent "$ip"
            elif [ "$is_csv_export" = true ]; then
                # Exportar a CSV
                track_ip_normal "$ip" "csv" >> "$OUTPUT_FILE"
            else
                # Modo normal pantalla
                echo -e "${YELLOW}[!] Rastreando: ${ip}${NC}\n"
                track_ip_normal "$ip"
            fi
        fi
    done < "$batch_file"
    
    if [ "$SILENT_MODE" = false ] && [ "$is_csv_export" = true ]; then
        echo -e "${GREEN}[✓] Resultados exportados a: $OUTPUT_FILE${NC}"
    fi
}

# Parsear argumentos
parse_args() {
    while getopts "i:f:o:msh" opt; do
        case $opt in
            i)
                SINGLE_IP="$OPTARG"
                ;;
            f)
                BATCH_FILE="$OPTARG"
                ;;
            o)
                OUTPUT_FILE="$OPTARG"
                ;;
            m)
                OPEN_MAP=true
                ;;
            s)
                SILENT_MODE=true
                ;;
            h)
                show_help
                exit 0
                ;;
            \?)
                echo -e "${RED}[!] Opción inválida: -$OPTARG${NC}" >&2
                show_help
                exit 1
                ;;
        esac
    done
}

# Main
main() {
    parse_args "$@"
    
    # Si no hay argumentos, mostrar ayuda
    if [ $OPTIND -eq 1 ]; then
        show_help
        exit 0
    fi
    
    check_deps
    
    # Prioridad: batch > single
    if [ -n "$BATCH_FILE" ]; then
        # Modo silencioso no muestra banner
        if [ "$SILENT_MODE" = false ]; then
            banner
        fi
        process_batch "$BATCH_FILE"
    elif [ -n "$SINGLE_IP" ]; then
        if [ "$SILENT_MODE" = false ]; then
            banner
        fi
        process_single_ip "$SINGLE_IP"
    else
        echo -e "${RED}[!] Debes especificar una IP (-i) o un archivo (-f)${NC}"
        show_help
        exit 1
    fi
}

main "$@"
