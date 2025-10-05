#!/bin/bash

FLAG_FILE="$HOME/.foxsvhost_done"
INFO_FILE="/tmp/FOXSVHOST_INFO.txt"
REFRESH_SECONDS=8

# Barra de progreso con colores
progress_bar() {
    local duration=${1:-2}
    local width=36
    local colors=(36 34 32 33 35 31)
    echo -ne "["
    for ((i=0;i<width;i++)); do
        color=${colors[$((i % ${#colors[@]}))]}
        printf "\033[1;%sm#\033[0m" "$color"
        sleep "$(awk -v d="$duration" -v w="$width" 'BEGIN{printf "%.3f", d/w}')"
    done
    echo -e "]"
}

# Generar información de VPS (sin contraseña) en INFO_FILE
generate_info_file() {
    HOSTNAME="${OS_HOSTNAME:-$(hostname -f 2>/dev/null || hostname 2>/dev/null || 'unknown')}"
    OS_LINE="$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d '\"' -f2 || uname -sr 2>/dev/null || echo 'Unknown OS')"

    if command -v free >/dev/null 2>&1; then
        MEMORY=$(free -h 2>/dev/null | awk '/Mem:/ {print $2" total, used:"$3", free:"$4}')
    elif [ -r /proc/meminfo ]; then
        MEMKB=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)
        MEMORY="$(awk -v kb=$MEMKB 'BEGIN{printf \"%.0fMB total\", kb/1024}')"
    else
        MEMORY="Unknown"
    fi

    if command -v df >/dev/null 2>&1; then
        DISK=$(df -h / 2>/dev/null | awk 'NR==2 {print $1" total, used:"$3", avail:"$4" on "$6}')
    else
        DISK="Unknown"
    fi

    if command -v nproc >/dev/null 2>&1; then
        CPU_CORES=$(nproc 2>/dev/null || echo "Unknown")
    else
        CPU_CORES=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "Unknown")
    fi

    IP_PRIVATE="$(hostname -I 2>/dev/null | awk '{print $1}' || echo "Unknown")"
    [ -z "$IP_PRIVATE" ] && IP_PRIVATE="Unknown"
    if command -v curl >/dev/null 2>&1; then
        IP_PUBLIC="$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")"
    else
        IP_PUBLIC="Unknown"
    fi

    cat > "$INFO_FILE" <<-EOF
    FoxSvHost VPS Information
    ------------------------
    Usuario:        root
    Contraseña:     (oculta por seguridad)
    Hostname:       $HOSTNAME
    Sistema:        $OS_LINE
    Memoria:        $MEMORY
    CPU Núcleos:    $CPU_CORES
    Disco:          $DISK
    IP Privada:     $IP_PRIVATE
    IP Pública:     $IP_PUBLIC

    IMPORTANTE: Guarda estos datos en un lugar seguro. Esta información se muestra constantemente en pantalla.
    EOF

    chmod 644 "$INFO_FILE" 2>/dev/null || true
}

# Mostrar logo y línea del SO brevemente
show_intro_once() {
    echo -e "\033[1;34m"
    echo " ______      _____  __     __  ______  _____  ______  ______  ______  "
    echo "|  ___ \    /  ___| \ \   / / |  ___ \|  ___||___  / |  ___||  __  | "
    echo "| |   | |  _\ `--.   \ \_/ /  | |   | | |__     / /  | |__  | |  | | "
    echo "| |   | | | |`--. \   \   /   | |   | |  __|   / /   |  __| | |  | | "
    echo "| |___| | | /\__/ /    | |    | |___| | |___  / /__  | |___ | |__| | "
    echo "|______/  \_|____/     |_|    |______/|_____||_____| |_____||______| "
    echo -e "\033[0m"

    OS_LINE="$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d '\"' -f2 || uname -sr 2>/dev/null || echo 'Unknown OS')"
    echo -e "\n\033[1;36m$OS_LINE\033[0m"
    sleep 2
    clear
}

# Mostrar panel desde INFO_FILE
print_panel() {
    if [ -r "$INFO_FILE" ]; then
        echo -e "\033[1;34m====================================================\033[0m"
        echo -e "\033[1;34m             FoxSvHost VPS Information Panel         \033[0m"
        echo -e "\033[1;34m====================================================\033[0m"
        echo
        sed 's/^/  /' "$INFO_FILE"
        echo
        echo -e "\033[1;36m(La información se refresca cada $REFRESH_SECONDS s. Presiona Ctrl+C para salir.)\033[0m"
    else
        echo -e "\033[1;31mERROR: No se encontró la información ($INFO_FILE).\033[0m"
    fi
}

# Primera ejecución
if [ ! -f "$FLAG_FILE" ]; then
    show_intro_once
    generate_info_file
    mkdir -p "$(dirname "$FLAG_FILE")" 2>/dev/null || true
    touch "$FLAG_FILE" 2>/dev/null || true
else
    [ ! -f "$INFO_FILE" ] && generate_info_file
fi

# Bucle constante para mostrar panel
while true; do
    clear
    print_panel
    generate_info_file
    sleep "$REFRESH_SECONDS"
done
