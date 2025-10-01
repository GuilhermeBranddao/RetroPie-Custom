#!/bin/bash

echo "🔧 Iniciando configuração personalizada do RetroPie..."

# Copia configs
cp configs/emulators.cfg /opt/retropie/configs/all/
cp configs/autostart.sh /opt/retropie/configs/all/

# Instala serviço Flask
sudo cp scripts/flask-server.service /etc/systemd/system/
sudo systemctl enable flask-server.service
sudo systemctl start flask-server.service

# Montagem automática de USB
sudo cp scripts/monta-usb.sh /home/pi/scripts/
sudo chmod +x /home/pi/scripts/monta-usb.sh
sudo cp scripts/99-usb-mount.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "✅ Configuração concluída!"