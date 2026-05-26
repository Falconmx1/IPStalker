#!/bin/bash

# ==============================================
# IPStalker v3.0 - Mapa por IP + JSON + Barra de progreso
# ==============================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuración por defecto
SILENT_MODE=false
OUTPUT_FILE=""
BATCH_FILE=""
OPEN_MAP=false
MAP_EACH_IP=false  # Nueva: abrir mapa para cada IP en batch
OUTPUT_FORMAT="csv"  # Nueva: csv o json

# Barra de progreso
PROGRESS_BAR_LENGTH=40

# Banner
banner() {
    if [ "$SILENT_MODE" = false ]; then
        clear
        echo -e "${BLUE}"
        echo "  ██▓▒░ IPStalker v3.0 ░▒▓██"
        echo "  ============================"
        echo -e "      ${GREEN}Tracking IP - Batch + JSON + Mapa${NC}"
        echo ""
    fi
}

# Mostrar ayuda
show_help() {
    echo -e "${CYAN}Uso: $0 [OPCIÓN] [IP o archivo]${NC}"
    echo ""
    echo "Opciones:"
    echo "  -i IP               Rastrear una sola IP"
    echo "  -f archivo.txt      Rastrear múltiples IPs desde un archivo"
    echo "  -o archivo.json/csv Exportar resultados (JSON o CSV según extensión)"
    echo "  -m                  Abrir mapa en navegador con coordenadas"
    echo "  -m-all              Abrir mapa para CADA IP en modo batch"
    echo "  -s                  Modo silencioso (solo IP y país)"
    echo "  -h                  Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 -i 8.8.8.8"
    echo "  $0 -i 8.8.8.8 -m"
    echo "  $0 -f ips.txt -o resultados.json"
    echo "  $0 -f ips.txt -o resultados.csv -m-all"
    echo "  $0 -f ips.txt -s -o resultados.json"
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

# Barra de progreso
show_progress() {
    local current=$1
    local total=$2
    local percentage=$((current * 100 / total))
    local filled=$((percentage * PROGRESS_BAR_LENGTH / 100))
    local empty=$((PROGRESS_BAR_LENGTH - filled))
    
    printf "\r${CYAN}[${GREEN}"
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "${CYAN}] ${percentage}%% ${YELLOW}($current/$total)${NC}"
}

# Abrir mapa en navegador
open_map_url() {
    local lat=$1
    local lon=$2
    local ip=$3
    local url="https://www.google.com/maps?q=${lat},${lon}"
    
    if [ "$OPEN_MAP" = true ] || [ "$MAP_EACH_IP" = true ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${MAGENTA}[+] Abriendo mapa para $ip...${NC}"
        fi
        
        if command -v xdg-open &> /dev/null; then
            xdg-open "$url" 2>/dev/null
        elif command -v termux-open &> /dev/null; then
            termux-open "$url" 2>/dev/null
        elif command -v open &> /dev/null; then
            open "$url" 2>/dev/null
        else
            echo -e "${YELLOW}[!] No se pudo abrir navegador. URL: $url${NC}"
        fi
        
        # Pequeña pausa para no sobrecargar el navegador
        sleep 1
    fi
}

# Obtener información de IP y devolver en formato JSON
track_ip_json() {
    local ip=$1
    response=$(curl -s "http://ip-api.com/json/${ip}")
    status=$(echo "$response" | jq -r '.status')
    
    if [ "$status" == "success" ]; then
        # Devolver el JSON completo de la API
        echo "$response"
        return 0
    else
        # JSON de error
        echo "{\"status\":\"fail\",\"query\":\"$ip\",\"message\":\"IP inválida o no alcanzable\"}"
        return 1
    fi
}

# Obtener información de IP (modo CSV - una línea)
track_ip_csv() {
    local ip=$1
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
        
        echo "\"$query\",\"$country\",\"$countryCode\",\"$region\",\"$city\",\"$zip\",\"$lat\",\"$lon\",\"$isp\",\"$timezone\""
        return 0
    else
        echo "\"$ip\",\"ERROR\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\""
        return 1
    fi
}

# Mostrar en pantalla (modo normal)
track_ip_display() {
    local ip=$1
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
        
        echo -e "${GREEN}IP:${NC}      $query"
        echo -e "${GREEN}País:${NC}    $country ($countryCode)"
        echo -e "${GREEN}Región:${NC}  $region"
        echo -e "${GREEN}Ciudad:${NC}  $city"
        echo -e "${GREEN}Código postal:${NC} $zip"
        echo -e "${GREEN}Lat/Lon:${NC} $lat , $lon"
        echo -e "${GREEN}ISP:${NC}     $isp"
        echo -e "${GREEN}Zona horaria:${NC} $timezone"
        echo ""
        
        # Abrir mapa (si está activado el modo individual o batch-all)
        open_map_url "$lat" "$lon" "$ip"
        return 0
    else
        echo -e "${RED}[!] Error: IP inválida o no alcanzable: $ip${NC}"
        echo ""
        return 1
    fi
}

# Modo silencioso (solo IP y país)
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
    elif [ "$OUTPUT_FORMAT" = "json" ] && [ -n "$OUTPUT_FILE" ]; then
        # Exportar a JSON (single)
        track_ip_json "$ip" > "$OUTPUT_FILE"
        echo -e "${GREEN}[✓] Resultados exportados a: $OUTPUT_FILE${NC}"
    elif [ "$OUTPUT_FORMAT" = "csv" ] && [ -n "$OUTPUT_FILE" ]; then
        # Exportar a CSV (single)
        echo "IP,País,Código,Región,Ciudad,Código Postal,Latitud,Longitud,ISP,Zona Horaria" > "$OUTPUT_FILE"
        track_ip_csv "$ip" >> "$OUTPUT_FILE"
        echo -e "${GREEN}[✓] Resultados exportados a: $OUTPUT_FILE${NC}"
    else
        echo -e "${YELLOW}[!] Rastreando: ${ip}${NC}\n"
        track_ip_display "$ip"
    fi
}

# Procesar archivo batch con barra de progreso
process_batch() {
    local batch_file=$1
    
    if [ ! -f "$batch_file" ]; then
        echo -e "${RED}[!] Archivo no encontrado: $batch_file${NC}"
        exit 1
    fi
    
    # Contar IPs válidas
    local total_ips=$(grep -c -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' "$batch_file")
    if [ $total_ips -eq 0 ]; then
        echo -e "${RED}[!] No se encontraron IPs válidas en el archivo${NC}"
        exit 1
    fi
    
    # Preparar archivo de salida si es necesario
    if [ -n "$OUTPUT_FILE" ]; then
        if [ "$OUTPUT_FORMAT" = "json" ]; then
            # JSON: array de resultados
            echo "[" > "$OUTPUT_FILE"
        elif [ "$OUTPUT_FORMAT" = "csv" ]; then
            # CSV: cabecera
            echo "IP,País,Código,Región,Ciudad,Código Postal,Latitud,Longitud,ISP,Zona Horaria" > "$OUTPUT_FILE"
        fi
    fi
    
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${CYAN}[+] Procesando $total_ips IPs...${NC}\n"
    fi
    
    # Procesar cada IP
    local counter=0
    local first=true
    
    while IFS= read -r ip; do
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            counter=$((counter + 1))
            
            # Mostrar barra de progreso (solo si no es silencioso)
            if [ "$SILENT_MODE" = false ] && [ -z "$OUTPUT_FILE" ]; then
                show_progress $counter $total_ips
            fi
            
            if [ "$SILENT_MODE" = true ]; then
                # Modo silencioso
                track_ip_silent "$ip"
            elif [ -n "$OUTPUT_FILE" ]; then
                # Exportando a archivo
                if [ "$OUTPUT_FORMAT" = "json" ]; then
                    if [ "$first" = false ]; then
                        echo "," >> "$OUTPUT_FILE"
                    fi
                    track_ip_json "$ip" >> "$OUTPUT_FILE"
                    first=false
                elif [ "$OUTPUT_FORMAT" = "csv" ]; then
                    track_ip_csv "$ip" >> "$OUTPUT_FILE"
                fi
            else
                # Modo normal pantalla con progreso
                if [ "$MAP_EACH_IP" = true ]; then
                    echo ""
                    track_ip_display "$ip"
                else
                    # Mostrar IP y resultado resumido
                    local result=$(curl -s "http://ip-api.com/json/${ip}" | jq -r '.country')
                    echo -e "${CYAN}[$counter/$total_ips]${NC} $ip -> $result"
                fi
            fi
        fi
    done < "$batch_file"
    
    # Cerrar JSON array
    if [ -n "$OUTPUT_FILE" ] && [ "$OUTPUT_FORMAT" = "json" ]; then
        echo "" >> "$OUTPUT_FILE"
        echo "]" >> "$OUTPUT_FILE"
    fi
    
    # Salto de línea después de la barra de progreso
    if [ "$SILENT_MODE" = false ] && [ -z "$OUTPUT_FILE" ]; then
        echo ""
    fi
    
    if [ -n "$OUTPUT_FILE" ] && [ "$SILENT_MODE" = false ]; then
        echo -e "${GREEN}[✓] Resultados exportados a: $OUTPUT_FILE${NC}"
    fi
}

# Parsear argumentos
parse_args() {
    while getopts "i:f:o:msh-:" opt; do
        case $opt in
            i)
                SINGLE_IP="$OPTARG"
                ;;
            f)
                BATCH_FILE="$OPTARG"
                ;;
            o)
                OUTPUT_FILE="$OPTARG"
                # Detectar formato por extensión
                if [[ "$OUTPUT_FILE" == *.json ]]; then
                    OUTPUT_FORMAT="json"
                elif [[ "$OUTPUT_FILE" == *.csv ]]; then
                    OUTPUT_FORMAT="csv"
                else
                    OUTPUT_FORMAT="csv"  # Por defecto CSV
                fi
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
            -)
                case "${OPTARG}" in
                    m-all)
                        MAP_EACH_IP=true
                        ;;
                    *)
                        echo -e "${RED}[!] Opción inválida: --${OPTARG}${NC}"
                        exit 1
                        ;;
                esac
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
