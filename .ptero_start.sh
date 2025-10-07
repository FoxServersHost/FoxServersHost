#!/bin/bash

# Limpia consola y muestra banner
clear
echo -e "\e[36m[FoxServers Host System]\e[0m"
echo "Cargando entorno VPS..."
sleep 2
clear

# Loop infinito de información
while true; do
    clear
    echo -e "\e[34m======================================"
    echo -e "        🦊 FoxServers Host System"
    echo -e "======================================\e[0m"
    echo ""
    echo -e "\e[36mSistema operativo:\e[0m $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
    echo -e "\e[36mIP pública:\e[0m $(curl -s ifconfig.me)"
    echo -e "\e[36mMemoria RAM:\e[0m $(free -h | awk '/Mem:/ {print $2}')"
    echo -e "\e[36mNúcleos CPU:\e[0m $(nproc)"
    echo -e "\e[36mEspacio en disco:\e[0m $(df -h / | awk 'NR==2 {print $2}')"
    echo -e "\e[36mHostname:\e[0m $(hostname)"
    echo -e "\e[36mFecha y hora:\e[0m $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo -e "\e[34m======================================"
    echo -e "        Actualizando cada 8s..."
    echo -e "======================================\e[0m"
    sleep 8
done
