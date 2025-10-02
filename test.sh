#!/bin/bash

# ==============================================================================
#  SCRIPT DE DIAGNÓSTICO PARA RETROPIE CUSTOM
# ==============================================================================
# Este script verifica se todos os componentes configurados pelo build.sh
# estão no lugar e funcionando corretamente.
# ==============================================================================

# -- Definição de Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -- Função para imprimir um status formatado
print_status() {
    # $1: Mensagem
    # $2: Status (e.g., "OK", "FALHA")
    # $3: Cor do Status
    printf "%-50s [ %b%s%b ]\n" "$1" "$3" "$2" "${NC}"
}

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}  Executando Diagnóstico do Ambiente RetroPie Custom ${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo

# --- 1. Verificação dos Serviços (systemd) ---
echo -e "${YELLOW}--- Verificando Serviços do SystemD ---${NC}"

# Checa o serviço do Flask
if systemctl is-active --quiet flask-server.service; then
    print_status "Serviço 'flask-server.service' está ATIVO" "OK" "${GREEN}"
else
    print_status "Serviço 'flask-server.service' está INATIVO" "FALHA" "${RED}"
fi

# Checa se o serviço do Flask está habilitado na inicialização
if systemctl is-enabled --quiet flask-server.service; then
    print_status "Serviço 'flask-server.service' está HABILITADO" "OK" "${GREEN}"
else
    print_status "Serviço 'flask-server.service' está DESABILITADO" "AVISO" "${YELLOW}"
fi

# Checa o serviço do USB Sorter
if systemctl is-active --quiet usb-rom-sorter.service; then
    print_status "Serviço 'usb-rom-sorter.service' está ATIVO" "OK" "${GREEN}"
else
    print_status "Serviço 'usb-rom-sorter.service' está INATIVO" "FALHA" "${RED}"
fi

# Checa o serviço do USB Sorter
if systemctl is-enabled --quiet usb-rom-sorter.service; then
    print_status "Serviço 'usb-rom-sorter.service' está HABILITADO" "OK" "${GREEN}"
else
    print_status "Serviço 'usb-rom-sorter.service' está DESABILITADO" "FALHA" "${RED}"
fi
echo

# --- 2. Verificação de Arquivos e Diretórios ---
echo -e "${YELLOW}--- Verificando Estrutura de Arquivos e Diretórios ---${NC}"

# Checa diretório de scripts
if [ -d "/home/scripts" ]; then
    print_status "Diretório '/home/scripts' existe" "OK" "${GREEN}"
else
    print_status "Diretório '/home/scripts' não encontrado" "FALHA" "${RED}"
fi

# Checa diretório de logs
if [ -d "/home/pi/logs" ]; then
    print_status "Diretório '/home/pi/logs' existe" "OK" "${GREEN}"
else
    print_status "Diretório '/home/pi/logs' não encontrado" "FALHA" "${RED}"
fi

# Checa script do organizador de ROMs e se é executável
if [ -x "/home/scripts/usb-rom-sorter.sh" ]; then
    print_status "Script '/home/scripts/usb-rom-sorter.sh' é executável" "OK" "${GREEN}"
else
    print_status "Script '/home/scripts/usb-rom-sorter.sh' não é executável" "FALHA" "${RED}"
fi

# Checa regra udev
if [ -f "/etc/udev/rules.d/99-rom-copy.rules" ]; then
    print_status "Arquivo de regra '/etc/udev/rules.d/99-rom-copy.rules' existe" "OK" "${GREEN}"
else
    print_status "Arquivo de regra '99-rom-copy.rules' não encontrado" "FALHA" "${RED}"
fi
echo

# --- 3. Teste Funcional do Servidor Web ---
echo -e "${YELLOW}--- Teste de Conectividade com o Servidor Flask ---${NC}"
# Usamos curl para testar se a porta 5000 está respondendo localmente
if curl --fail --silent http://localhost:5000/ > /dev/null; then
    print_status "Servidor Flask está respondendo em http://localhost:5000" "OK" "${GREEN}"
else
    print_status "Não foi possível conectar ao servidor Flask na porta 5000" "FALHA" "${RED}"
    echo "Isso pode indicar um problema na aplicação ou no serviço."
fi
echo

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}                  Diagnóstico Concluído              ${NC}"
echo -e "${BLUE}=====================================================${NC}"