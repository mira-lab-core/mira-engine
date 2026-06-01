#!/system/bin/sh
# ==========================================
# MIRA ENGINE | MASTER SCRIPT (SaaS Edition)
# ==========================================

# 1. INSTALACIÓN INVISIBLE DEL COMANDO "iwin"
# Si el script se ejecuta desde internet, crea el comando y se oculta.
if [ "$1" != "--run" ]; then
    MIRA_PATH="$HOME/.mira_core.sh"
    
    # Guarda el código en un archivo oculto del sistema
    cat "$0" > "$MIRA_PATH"
    chmod +x "$MIRA_PATH"
    
    # Crea el comando ejecutable 'iwin'
    echo "#!/system/bin/sh" > "$PREFIX/bin/iwin"
    echo "sh $MIRA_PATH --run" >> "$PREFIX/bin/iwin"
    chmod +x "$PREFIX/bin/iwin"
    
    clear
    echo "=========================================="
    echo " ✅ MIRA ENGINE INSTALADO CORRECTAMENTE"
    echo "=========================================="
    echo " Escribe el comando: iwin"
    echo " para abrir el menú principal."
    echo "=========================================="
    exit 0
fi

# ==========================================
# 2. PANEL DE CONTROL (Se abre al teclear 'iwin')
# ==========================================
TRIAL_FILE="$HOME/.mira_trial_state"
PHONE_NUM="525500000000" # <--- PON TU NÚMERO DE WHATSAPP AQUÍ

show_menu() {
    clear
    echo "=========================================="
    echo "      MIRA LAB CORE | PANEL DE CONTROL"
    echo "=========================================="
    echo " 1. Start  (Iniciar Optimización)"
    echo " 2. Stop   (Detener Motor)"
    echo " 3. Status (Ver Estado de Licencia)"
    echo " 4. Salir"
    echo "=========================================="
    read -p "Selecciona una opción: " opc

    case $opc in
        1) start_mira ;;
        2) stop_mira ;;
        3) status_mira ;;
        4) exit 0 ;;
        *) echo "Opción inválida."; sleep 1; show_menu ;;
    esac
}

start_mira() {
    echo ""
    read -p "🔑 Ingresa tu KEY de acceso: " user_key

    # --- LÓGICA LITE (SIN ROOT + WHATSAPP INTENT) ---
    if [ "$user_key" == "LITE-FREE-KEY" ]; then
        if [ ! -f "$TRIAL_FILE" ]; then
            echo "0" > "$TRIAL_FILE"
        fi
        TRIAL_DAY=$(cat "$TRIAL_FILE")

        if [ "$TRIAL_DAY" -ge 3 ]; then
            echo "=========================================="
            echo " 🚨 PRUEBA AGOTADA (0/3 días restantes) 🚨"
            echo " Papi, paga la mensualidad (50 MXN)."
            echo "=========================================="
            # Expulsión forzada a WhatsApp
            am start -a android.intent.action.VIEW -d "https://wa.me/$PHONE_NUM?text=Papi%20quiero%20pagar%20MIRA%20LITE" > /dev/null 2>&1
            exit 1
        fi

        NEXT_DAY=$((TRIAL_DAY + 1))
        echo "$NEXT_DAY" > "$TRIAL_FILE"
        DIAS_RESTANTES=$((3 - NEXT_DAY))

        echo "=========================================="
        echo " 🛡️ MIRA LITE ACTIVADO (NO ROOT)"
        echo " Día de prueba: $NEXT_DAY de 3."
        echo " Te quedan $DIAS_RESTANTES/3 días."
        echo " ⚠️ Interrupción forzada en 24h."
        echo "=========================================="

        # Inyección Lite
        settings put system touch_slop 2
        (while true; do sync; sleep 600; done) &
        echo $! > "$HOME/.mira_pid"

        # Reloj oculto de 24 horas (86340 segundos)
        (
            sleep 86340 
            if [ -f "$HOME/.mira_pid" ]; then
                kill $(cat "$HOME/.mira_pid") > /dev/null 2>&1
                rm "$HOME/.mira_pid"
            fi
            # Castigo de 24h: Abre WhatsApp y te saca del juego
            am start -a android.intent.action.VIEW -d "https://wa.me/$PHONE_NUM?text=Papi%20quiero%20pagar%20mi%20mes%20de%20MIRA" > /dev/null 2>&1
        ) &
        
        echo "[OK] Tu app principal NO se cerrará por falta de RAM."
        sleep 4
        show_menu

    # --- LÓGICA PRO (ROOT REQUIERED) ---
    elif [ "$user_key" == "VIP-PRO-30" ]; then
        echo "=========================================="
        echo " 🔥 MIRA PRO ACTIVADO"
        echo " Tu CPU atiende primero a tu disparo que a quien le estás dando."
        echo "=========================================="
        su -c "echo 1 > /proc/sys/kernel/sched_child_runs_first"
        su -c "sysctl -w net.ipv4.tcp_rmem='4096 87380 6291456'"
        su -c "sysctl -w net.ipv4.tcp_wmem='4096 16384 4194304'"
        su -c "while true; do sync; echo 3 > /proc/sys/vm/drop_caches; sleep 300; done & echo \$! > /data/local/tmp/.mira_pro_pid"
        echo "[OK] Motor PRO inyectado."
        sleep 4
        show_menu

    else
        echo "❌ KEY INVÁLIDA."
        sleep 2
        show_menu
    fi
}

stop_mira() {
    # Detener LITE
    if [ -f "$HOME/.mira_pid" ]; then
        kill $(cat "$HOME/.mira_pid") > /dev/null 2>&1
        rm "$HOME/.mira_pid"
        echo "✅ MIRA LITE Detenido."
    fi
    # Detener PRO
    su -c "if [ -f /data/local/tmp/.mira_pro_pid ]; then kill \$(cat /data/local/tmp/.mira_pro_pid); rm /data/local/tmp/.mira_pro_pid; fi" > /dev/null 2>&1
    echo "✅ Procesos limpiados."
    sleep 2
    show_menu
}

status_mira() {
    clear
    echo "=========================================="
    if [ -f "$HOME/.mira_pid" ] || su -c "[ -f /data/local/tmp/.mira_pro_pid ]" > /dev/null 2>&1; then
        TRIAL_DAY=$(cat "$TRIAL_FILE" 2>/dev/null || echo "0")
        DIAS_RESTANTES=$((3 - TRIAL_DAY))
        echo " 🟢 ESTADO: MOTOR EN EJECUCIÓN"
        echo " ⏳ Días restantes de prueba LITE: $DIAS_RESTANTES/3"
    else
        echo " 🔴 ESTADO: APAGADO"
    fi
    echo "=========================================="
    read -p "Presiona ENTER para volver al menú..."
    show_menu
}

# Inicia la interfaz
show_menu
