#!/bin/bash
# --- usb-rom-sorter.sh ---
# Detecta automaticamente pendrives com pasta 'roms' e copia os arquivos para os diretórios corretos do RetroPie com base na extensão, ignorando duplicatas.

DEST_BASE_DIR="/home/pi/RetroPie/roms"
LOG_FILE="/home/pi/logs/usb-sorter.log"

mkdir -p "$(dirname "$LOG_FILE")"

echo "----------------------------------------" >> "$LOG_FILE"

echo "$(date): Script de Sorter de USB iniciado." >> "$LOG_FILE"

# Monta o pendrive se necessário

if ! mountpoint -q /media/usb; then
  sudo mkdir -p /media/usb
  sudo mount /dev/sda1 /media/usb
fi

# Detecta pasta 'roms' no pendrive

SOURCE_ROM_DIR=""
for mount in /media/usb*; do

  if [ -d "$mount/roms" ] && [ "$(ls -A "$mount/roms")" ]; then
    SOURCE_ROM_DIR="$mount/roms"
    echo "$(date): ROMs encontradas em: $SOURCE_ROM_DIR" >> "$LOG_FILE"
    ls -lh "$SOURCE_ROM_DIR" >> "$LOG_FILE"
    break
  fi
done

if [ -z "$SOURCE_ROM_DIR" ]; then
  echo "$(date): Nenhum diretório 'roms' com arquivos encontrado. Encerrando." >> "$LOG_FILE"
  exit 0
fi

# Função para mapear extensão para pasta destino
# Copia os arquivos mantendo a estrutura de subpastas
find "$SOURCE_ROM_DIR" -type f | while read rom_file; do
  # Extrai subpasta relativa (ex: snes, gba, etc.)
  relative_path="${rom_file#$SOURCE_ROM_DIR/}"
  subfolder=$(dirname "$relative_path")
  filename=$(basename "$rom_file")
  dest_dir="${DEST_BASE_DIR}/${subfolder}"
  mkdir -p "$dest_dir"
  # Só copia se o arquivo ainda não existe
  if [ ! -f "${dest_dir}/${filename}" ]; then
    cp "$rom_file" "${dest_dir}/"
    echo "✅ Copiado: $filename para $dest_dir" >> "$LOG_FILE"
  else
    echo "⏩ Ignorado: $filename já existe em $dest_dir" >> "$LOG_FILE"
  fi
done

echo "$(date): Copia finalizada. Reinicie o EmulationStation para concluir o processo." >> "$LOG_FILE"

# umount "$(dirname "$SOURCE_ROM_DIR")"

exit 0