#!/bin/bash

FLAG_FILE="/root/.foxsvhost_done"
if [ -f "$FLAG_FILE" ]; then
    exit 0
fi

# ASCII art grande y claro "FoxServers"
echo -e "\033[1;34m"
echo " ______      _____  __     __  ______  _____  ______  ______  ______  "
echo "|  ___ \    /  ___| \ \   / / |  ___ \|  ___||___  / |  ___||  __  | "
echo "| |   | |  _\ `--.   \ \_/ /  | |   | | |__     / /  | |__  | |  | | "
echo "| |   | | | |`--. \   \   /   | |   | |  __|   / /   |  __| | |  | | "
echo "| |___| | | /\__/ /    | |    | |___| | |___  / /__  | |___ | |__| | "
echo "|______/  \_|____/     |_|    |______/|_____||_____| |_____||______| "
echo -e "\033[0m"

# Función para animación de barra con colores gradientes
progress_bar() {
    local duration=$1
    local width=40
    local colors=(31 33 32 36 34 35)
    echo -ne "["
    for ((i=0; i<width; i++)); do
        color=${colors[$((i % ${#colors[@]}))]}
        echo -ne "\033[1;${color}m#\033[0m"
        sleep $(echo "$duration/$width" | bc -l)
    done
    echo -e "]"
}

# Función para mostrar panel tipo dashboard
show_dashboard() {
    ROOT_USER="root"
    PASSWORD="${OS_PASSWORD:-changeme}"
    HOSTNAME="${OS_HOSTNAME:-vps}"
    OS_NAME=$(uname -o 2>/dev/null || lsb_release -d -s 2>/dev/null || echo "Unknown OS")
    MEMORY=$(free -h | awk '/Mem:/ {print $2}')
    CPU_CORES=$(nproc)
    DISK=$(df -h / | awk 'NR==2 {print $2}')
    IP=$(hostname -I | awk '{print $1}')

    echo -e "\033[1;34m===================================================="
    echo "             FoxSvHost VPS Welcome Panel            "
    echo "====================================================\033[0m"

    echo -e "\033[1;34m+----------------------------------------------+"
    echo -e "|           Información del VPS                |"
    echo -e "+----------------------------------------------+\033[0m"

    echo -e "\033[1;33m[ROOT USER]   \033[0m$ROOT_USER"
    echo -e "\033[1;33m[PASSWORD]    \033[0m$PASSWORD"
    echo -e "\033[1;33m[HOSTNAME]    \033[0m$HOSTNAME"
    echo -e "\033[1;33m[OS]          \033[0m$OS_NAME"
    echo -e "\033[1;33m[MEMORY]      \033[0m$MEMORY"
    echo -e "\033[1;33m[CPU CORES]   \033[0m$CPU_CORES"
    echo -e "\033[1;33m[DISK SIZE]   \033[0m$DISK"
    echo -e "\033[1;33m[IP]          \033[0m$IP"

    echo -e "\033[1;31m+----------------------------------------------+"
    echo -e "IMPORTANTE: Guarda estos datos en un lugar seguro."
    echo -e "Solo se muestran una vez.\033[0m"

    touch "$FLAG_FILE"
}

# Función para dashboard dinámico (simula actualización)
dynamic_dashboard() {
    for i in {1..3}; do
        clear
        echo -e "\033[1;36mActualizando panel... (${i}/3)\033[0m"
        progress_bar 1
        show_dashboard
        sleep 1
    done
}

# Ejecutar panel interactivo
dynamic_dashboard
