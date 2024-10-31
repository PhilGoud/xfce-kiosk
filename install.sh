#!/bin/bash

# Variables
KIOSK_URL="https://yourwebpage.com"
USER_HOME="/home/$(whoami)"
KIOSK_SCRIPT_PATH="/usr/local/bin/kiosk.sh"
WATCHDOG_SCRIPT_PATH="$USER_HOME/chromium_cron_watchdog.sh"
SERVICE_PATH="/etc/systemd/system/kiosk.service"
XFCE_KEYBOARD_XML="$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"

# Fonction pour installer xdotool et chromium si nécessaire
install_dependencies() {
    echo "Installation des dépendances..."
    sudo apt update
    sudo apt install -y chromium xdotool
}

# Créer le script pour lancer Chromium en mode kiosque
create_kiosk_script() {
    echo "Création du script de démarrage pour Chromium en mode kiosque..."
    sudo bash -c "cat > $KIOSK_SCRIPT_PATH" << EOL
#!/bin/bash
# Lance Chromium en mode kiosque sur l'affichage :0
/usr/bin/chromium --noerrdialogs --disable-infobars --kiosk "$KIOSK_URL"
EOL
    sudo chmod +x $KIOSK_SCRIPT_PATH
}

# Créer le fichier de service systemd
create_systemd_service() {
    echo "Création du service systemd pour le mode kiosque..."
    sudo bash -c "cat > $SERVICE_PATH" << EOL
[Unit]
Description=Kiosk Mode for Chromium
After=systemd-user-sessions.service getty@tty1.service

[Service]
Environment="DISPLAY=:0"
Environment="XAUTHORITY=$USER_HOME/.Xauthority"
ExecStart=$KIOSK_SCRIPT_PATH
Restart=always
User=$(whoami)
Group=$(whoami)

[Install]
WantedBy=multi-user.target
EOL
    sudo systemctl enable kiosk.service
}

# Créer le script de surveillance pour le cron
create_watchdog_script() {
    echo "Création du script de surveillance pour Chromium..."
    cat > $WATCHDOG_SCRIPT_PATH << EOL
#!/bin/bash

# Vérifie si le service kiosk est actif
if ! systemctl is-active --quiet kiosk.service; then
    echo "\$(date): Le service Chromium en mode kiosque n'est pas actif. Relancement..." >> $USER_HOME/chromium_watchdog.log
    # Relance le service kiosk
    sudo systemctl start kiosk.service
else
    echo "\$(date): Le service Chromium en mode kiosque fonctionne correctement." >> $USER_HOME/chromium_watchdog.log
    # Rafraîchit la page si le service est actif
    xdotool search --onlyvisible --class "chromium" key F5
fi
EOL
    chmod +x $WATCHDOG_SCRIPT_PATH
}

# Ajouter la tâche cron
add_cron_job() {
    echo "Ajout de la tâche cron pour surveiller Chromium..."
    (crontab -l 2>/dev/null; echo "*/30 * * * * $WATCHDOG_SCRIPT_PATH") | crontab -
}

# Configurer le raccourci clavier pour quitter le mode kiosque
configure_xfce_shortcut() {
    echo "Configuration du raccourci clavier pour quitter le mode kiosque..."
    # Crée le fichier XML des raccourcis s'il n'existe pas encore
    if [ ! -f "$XFCE_KEYBOARD_XML" ]; then
        mkdir -p "$(dirname "$XFCE_KEYBOARD_XML")"
        cat > "$XFCE_KEYBOARD_XML" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-keyboard-shortcuts" version="1.0">
</channel>
EOL
    fi

    # Ajoute le raccourci Ctrl+Alt+Suppr pour stopper le service kiosque
    xmlstarlet ed -L -s "/channel" -t elem -n "property" -v "" \
        -i "/channel/property[not(@name='custom')]" -t attr -n "name" -v "custom" \
        -i "/channel/property[@name='custom']" -t attr -n "type" -v "empty" \
        -s "/channel/property[@name='custom']" -t elem -n "property" -v "" \
        -i "/channel/property[@name='custom']/property[not(@name='Ctrl+Alt+Delete')]" -t attr -n "name" -v "Ctrl+Alt+Delete" \
        -i "/channel/property[@name='custom']/property[@name='Ctrl+Alt+Delete']" -t attr -n "type" -v "string" \
        -s "/channel/property[@name='custom']/property[@name='Ctrl+Alt+Delete']" -t elem -n "property" -v "sudo systemctl stop kiosk.service" \
        "$XFCE_KEYBOARD_XML"
}

# Exécution des étapes
install_dependencies
create_kiosk_script
create_systemd_service
create_watchdog_script
add_cron_job
configure_xfce_shortcut

echo "Configuration terminée ! Redémarrez votre ordinateur pour appliquer les modifications."
