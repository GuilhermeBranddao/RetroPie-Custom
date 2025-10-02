#!/bin/bash

# ==============================================================================
#  SCRIPT DE CONFIGURAÇÃO AUTOMÁTICA PARA RETROPIE CUSTOM
# ==============================================================================
# Este script automatiza a instalação de:
#   - Script de organização de ROMs via USB.
#   - Regra udev para automação do USB.
#   - Servidor web Flask para gerenciamento.
# ==============================================================================

# -- Interrompe o script se qualquer comando falhar
set -e

# -- Definição de Cores para o output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# -- Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}Por favor, execute este script como root ou com sudo.${NC}"
  echo "Uso: sudo ./build.sh"
  exit 1
fi

# -- Obtém o diretório onde o script está localizado
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo -e "${GREEN}>>> [1/7] Iniciando a configuração do Retropie Custom...${NC}"

# --- ETAPA 2: Criação de diretórios e permissões ---
echo -e "${GREEN}>>> [2/7] Criando diretórios necessários...${NC}"
mkdir -p /home/scripts
mkdir -p /home/pi/logs
chown pi:pi /home/pi/logs
chmod 755 /home/pi/logs
echo "Diretórios criados e permissões ajustadas."

# --- ETAPA 3: Configuração do Organizador de ROMs USB ---
echo -e "${GREEN}>>> [3/7] Configurando o script de organização de ROMs...${NC}"
cp "${SCRIPT_DIR}/scripts/usb-rom-sorter.sh" /home/scripts/usb-rom-sorter.sh
chmod +x /home/scripts/usb-rom-sorter.sh
echo "Script 'usb-rom-sorter.sh' copiado e tornado executável."

cp "${SCRIPT_DIR}/service/usb-rom-sorter.service" /etc/systemd/system/
echo "Serviço 'usb-rom-sorter.service' instalado."

cp "${SCRIPT_DIR}/rules/99-rom-copy.rules" /etc/udev/rules.d/
echo "Regra udev '99-rom-copy.rules' instalada."

# --- ETAPA 4: Instalação de dependências do Servidor Web ---
echo -e "${GREEN}>>> [4/7] Instalando dependências do servidor web (Python)...${NC}"
apt-get update
apt-get install -y python3-pip python3-venv
echo "Dependências do Python instaladas."

# --- ETAPA 5: Configuração do Servidor Web Flask ---
echo -e "${GREEN}>>> [5/7] Configurando o servidor web Flask...${NC}"
# Copia a aplicação
cp -r "${SCRIPT_DIR}/scripts/flask-server" /home/scripts/flask-server
chown -R pi:pi /home/scripts/flask-server
echo "Aplicação Flask copiada para /home/scripts/flask-server."

# Cria ambiente virtual e instala o Flask
echo "Criando ambiente virtual e instalando Flask..."
python3 -m venv /home/scripts/flask-server/.venv
/home/scripts/flask-server/.venv/bin/pip install --upgrade pip
/home/scripts/flask-server/.venv/bin/pip install flask
echo "Ambiente virtual criado e Flask instalado."

# Instala o serviço do Flask
cp "${SCRIPT_DIR}/service/flask-server.service" /etc/systemd/system/
echo "Serviço 'flask-server.service' instalado."

# --- ETAPA 6: Recarregando Daemons e Ativando Serviços ---
echo -e "${GREEN}>>> [6/7] Recarregando daemons do systemd e udev...${NC}"
udevadm control --reload-rules
systemctl daemon-reload
echo "Daemons recarregados."

echo "Ativando e iniciando o serviço do servidor web..."
systemctl enable flask-server.service
systemctl start flask-server.service
echo "Serviço 'flask-server' ativado e iniciado."

# --- ETAPA 7: Conclusão ---
echo -e "\n${GREEN}>>> [7/7] Instalação concluída com sucesso!${NC}"
echo -e "O sistema está configurado."
echo -e " - O servidor web deve estar acessível na porta 5000."
echo -e " - A automação para cópia de ROMs via USB está ativa."