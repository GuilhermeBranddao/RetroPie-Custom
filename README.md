
git clone https://github.com/seu-usuario/retropie-custom.git
cd retropie-custom
chmod +x build.sh
./build.sh


No seu celular (conectado na mesma rede Wi-Fi que o Raspberry Pi), abra o navegador e acesse: http://<IP_DO_RASPBERRY_PI>:5000



Com RetroPie, Recalbox ou Batocera, o Pi 3B+ consegue rodar tranquilo:

- Atari 2600, 5200, 7800, Jaguar (parcial)
- NES (Nintendo)
- SNES (Super Nintendo)
- Master System, Mega Drive, Game Gear
- Game Boy, Game Boy Color, Game Boy Advance
- - Nintendo 64
- Neo Geo (Roda boa parte dos jogos)
- Arcade (MAME, Final Burn Alpha – depende do jogo, alguns mais pesados engasgam)
- PlayStation 1 (roda muito bem, quase todos os jogos com desempenho legal)


Eu acho em, dá pra personalizar do jeito que vc quer, dá pra configurar os emuladores, ajustar shaders, filtros, overclock, etc.

Excelente iniciativa! Criar um manual claro e com soluções "mágicas" como scripts de automação é exatamente o que transforma um produto bom em um produto premium. Você vende uma experiência simplificada, e isso tem um valor imenso para o cliente final.

Vamos estruturar esse manual de forma profissional, começando pelos métodos mais simples e avançando para os mais sofisticados que você imaginou.

---

### **Guia Definitivo: Adicionando Jogos ao seu Kit Retrogamer**

Olá! Este guia foi criado para que você possa adicionar seus jogos favoritos ao seu console Retrogaming da forma mais fácil e rápida possível. Escolha o método que for mais conveniente para você!

A Regra de Ouro (Passo Final para Todos os Métodos):

Após transferir qualquer jogo novo, o sistema precisa ser atualizado para exibi-lo. É muito simples:

1. No menu principal do seu console, com o controle, aperte o botão **START**.
    
2. Navegue até o menu **QUIT** (Sair).
    
3. Selecione a opção **RESTART EMULATIONSTATION** (Reiniciar EmulationStation).
    
4. Pronto! Após reiniciar, seus novos jogos aparecerão na lista do console correspondente.
    

---

### **Método 1: A Forma Mais Fácil (Via Rede Wi-Fi, sem usar códigos)**

Se o seu Raspberry Pi estiver conectado à mesma rede Wi-Fi que o seu computador, este é o método mais simples. Ele transforma seu Pi em uma pasta compartilhada na rede.

1. **No Windows:**
    - Abra o **Explorador de Arquivos** (a pasta amarela na barra de tarefas).
    - Na barra de endereço, digite `\\retropie` e aperte Enter.
    - Você verá algumas pastas. A pasta que nos interessa é a **roms**.
2. **No macOS:**
    - Abra o **Finder**.
    - No menu superior, clique em **Ir** e depois em **Conectar ao Servidor...**.
    - No endereço do servidor, digite `smb://retropie` e clique em **Conectar**.
    - Abra a pasta **roms**.
        
3. **Transferindo os Jogos:**
    - Dentro da pasta `roms`, você verá várias subpastas, cada uma com o nome de um console (ex: `snes`, `gba`, `megadrive`).
    - Agora, basta **arrastar e soltar** os arquivos dos seus jogos do seu computador para a pasta do console correto. Por exemplo, um jogo de Super Nintendo (`.sfc` ou `.smc`) vai para a pasta `snes`.
    - Siga a "Regra de Ouro" para atualizar o sistema e ver seus jogos.

---

### **Método 2: A Forma Universal (Via Pendrive - Manual)**

Este método funciona mesmo que seu Pi não esteja conectado à internet.
1. **Prepare o Pendrive:**
    - Pegue um pendrive formatado em FAT32 ou exFAT.
    - Crie uma pasta chamada `retropie` na raiz do pendrive.

2. **Primeira Conexão:**
    - Conecte o pendrive no seu Raspberry Pi ligado. Espere cerca de um minuto. Durante esse tempo, o RetroPie criará automaticamente toda a estrutura de pastas necessárias dentro da pasta `retropie` no seu pendrive.

3. **Transfira os Jogos:**
    - Desconecte o pendrive do Pi e conecte-o no seu computador.
    - Abra a pasta `retropie` e você verá a pasta `roms` com todas as subpastas dos consoles.
    - Copie seus arquivos de jogos para as pastas corretas (ex: jogos de Game Boy Advance para `retropie/roms/gba`).
        
4. **Segunda Conexão:**
    - Conecte o pendrive novamente no Pi. O sistema irá copiar automaticamente os jogos do pendrive para o armazenamento interno. A luz do pendrive piscará durante a cópia.
    - Quando a luz parar de piscar intensamente, a cópia terminou.
    - Siga a "Regra de Ouro" para atualizar e jogar!

---

#### **Solução 1: Cópia Automática via Pendrive (Script Inteligente)**

Este script fará com que o Pi identifique automaticamente os jogos em um pendrive e os copie para as pastas certas com base na extensão do arquivo.

Passo 1: Conecte a rede
- Vá em "System Options -> Wireless LAN"
	- Escolha o idioma da rede (BR Brasil)
	- Se conecte a rede
- Vá em "System Options -> Password"
	- Defina a senha de usuario
- Vá em "Interface Options -> SSH"
	- Habilite a ssh 

Passo 1: Criar o Script no Pi

Conecte-se via SSH e crie o arquivo do script:

```bash
ssh pi@192.168.X.XX
```

```bash
# Caso dê o erro: WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
ssh-keygen -R 192.168.X.XX
```

```bash
sudo mkdir -p /home/scripts

sudo nano /home/scripts/usb-rom-sorter.sh
```

Copie e cole o seguinte código:


```bash
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
```

Passo 2: Tornar o Script Executável
```bash
sudo chmod +x /home/scripts/usb-rom-sorter.sh
```

#### 1. Crie um serviço systemd

```bash
# Crie a pasta caso ela não exista
sudo mkdir -p /etc/systemd/system/

# Serviço de copia de pendrive
sudo nano /etc/systemd/system/usb-rom-sorter.service

```

```ini
[Unit]
Description=USB ROM Sorter
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/home/scripts/usb-rom-sorter.sh
User=pi

[Install]
WantedBy=multi-user.target
```

Passo 3: Configurar a Automação (Regra udev)
Esta regra mágica executa o script sempre que um pendrive for conectado.

```bash
sudo nano /etc/udev/rules.d/99-rom-copy.rules
sudo nano /etc/udev/rules.d/99-usb-mount.rules
```

Adicione a seguinte linha:
```bash
ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="vfat", TAG+="systemd", ENV{SYSTEMD_WANTS}="usb-rom-sorter.service"
```

Essa regra:
- Detecta dispositivos USB com sistema de arquivos FAT32
- Dispara o serviço systemd com tempo e ambiente adequados

##### ✅ Garantindo as permissões corretas

```bash
# 1. Crie a pasta (se necessário)
sudo mkdir -p /home/pi/logs

# 2. Dê a posse da pasta ao usuário `pi`
sudo chown pi:pi /home/pi/logs

# 3. Garanta permissão de escrita
sudo chmod 755 /home/pi/logs

# Se quiser ser mais permissivo para testes:
sudo chmod 777 /home/pi/logs

```

#### 3. Recarregue tudo

```bash
sudo udevadm control --reload-rules
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
```

```bash
sudo reboot
```

### 🧪 Teste final

- Conecte o pendrive
- Verifique se o serviço foi disparado:
    
```bash
journalctl -u usb-rom-sorter.service
```

---

Se quiser que o script crie o log em `/tmp` (que sempre tem permissão), posso adaptar. Mas manter em `/home/pi/logs` é mais organizado.

Quer que eu te ajude a adicionar uma verificação automática de permissões no início do script?


```bash
for dir in /media/usb*; do
  if [ "$(ls -A "$dir" 2>/dev/null)" ]; then
    echo "📁 Conteúdo encontrado em: $dir"
    ls -lh "$dir"
  else
    echo "🚫 Pasta vazia ou inacessível: $dir"
  fi
done


####

for dir in /media/usb*; do
  if [ -d "$dir/roms" ]; then
    echo "🎮 Pasta ROMs encontrada em: $dir/roms"
    ls -lh "$dir/roms"
  fi
done


# Logs do sistema
cat logs/usb-sorter.log

# Mostra os **5 últimos registros** do arquivo. Se quiser acompanhar em tempo real os últimos eventos conforme o log é atualizado, use:
tail -f logs/usb-sorter.log

# Acessa script
sudo nano scripts/usb-rom-sorter.sh

# Verifica se o serviço foi disparado
journalctl -u usb-rom-sorter.service

# Executa o serviço manualmente
sudo systemctl start usb-rom-sorter.service

lsblk -o NAME,MOUNTPOINT

```


--- 

### Configurando o servidor Flask

```bash
# Instalar (ou atualizar) o Python

# 1. Instale dependências
sudo apt update
sudo apt install -y build-essential libssl-dev zlib1g-dev libffi-dev libbz2-dev libsqlite3-dev libreadline-dev

# 2. Baixe, Compile e instale o Python 3.13
cd /usr/src/Python-3.13.0
make clean
sudo ./configure --enable-optimizations
sudo make -j4
sudo make altinstall

# Verifica a versão do python
/usr/local/bin/python3.13 --version

# Instalando o pip 
sudo apt install python3.13 python3.13-pip -y

# Cria ambiente virtual
/usr/local/bin/python3.13 -m venv .venv
source .venv/bin/activate

```

```bash
pip install flask
```

#### Configurando servidor

Salve este conteúdo como `/home/pi/start-flask.sh`

```bash
sudo nano /home/pi/start-flask.sh
```

```bash
#!/bin/bash
cd /home/pi
source .venv/bin/activate
python app.py
```


```python

# app.py
from flask import Flask, Response
import time

app = Flask(__name__)

@app.route('/')
def index():
    return '''
    <html>
    <head><title>Log Viewer</title></head>
    <body>
        <h2>Log: usb-sorter.log</h2>
        <pre id="log"></pre>
        <script>
            const logElement = document.getElementById("log");
            function fetchLog() {
                fetch("/log")
                    .then(response => response.text())
                    .then(data => {
                        logElement.textContent = data;
                    });
            }
            setInterval(fetchLog, 2000); // Atualiza a cada 2 segundos
            fetchLog(); // Primeira chamada
        </script>
    </body>
    </html>
    '''

@app.route('/log')
def stream_log():
    try:
        with open("logs/usb-sorter.log", "r") as f:
            content = f.read()
        return Response(content, mimetype='text/plain')
    except FileNotFoundError:
        return Response("Arquivo de log não encontrado.", mimetype='text/plain')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

Torne o script excecutavel
```bash
sudo chmod +x /home/pi/start-flask.sh
```

1- Crie um serviço systemd
```bash
sudo nano /etc/systemd/system/flask-server.service
```

Conteúdo
```ini
[Unit]
Description=Servidor Flask do Retropie
After=network.target

[Service]
Type=simple
ExecStart=/home/pi/start-flask.sh
User=pi
WorkingDirectory=/home/pi
Restart=always

[Install]
WantedBy=multi-user.target
```

Ative o serviço
```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable flask-server.service
sudo systemctl start flask-server.service
```

Teste e monitoramento
```bash
# Verifique se está rodando:
systemctl status flask-server.service

# Veja os logs:
journalctl -u flask-server.service -f
```



Acessar pelo celular
- Obs: 
	- O dispositivo deve está conectado ao mesmo Wi-Fi do raspberry pi
	- Você pode descobrir o IP ao ir no menu do Retropie e clicar em "SHOW IP"  
```link
http://<IP_DO_RASPBERRY_PI>:5000
```


---


- Para melhor desempenho, ative o **frame skip** ou ajuste o **overclock** (com cuidado).

|Pasta RetroPie|Sistema Emulado|Tipos de Arquivos Aceitos|
|---|---|---|
|`amstradcpc`|Amstrad CPC|`.dsk`, `.cdt`, `.zip`|
|`arcade`|Arcade (multi-emulador)|`.zip`|
|`atari2600`|Atari 2600|`.bin`, `.a26`, `.zip`|
|`atari5200`|Atari 5200|`.a52`, `.bin`, `.zip`|
|`atari7800`|Atari 7800|`.a78`, `.bin`, `.zip`|
|`atari800`|Atari 8-bit|`.atr`, `.xex`, `.rom`, `.bin`, `.zip`|
|`atarilynx`|Atari Lynx|`.lnx`, `.zip`|
|`channelf`|Channel F|`.bin`, `.zip`|
|`coleco`|ColecoVision|`.col`, `.rom`, `.bin`, `.zip`|
|`fba`|Final Burn Alpha (Arcade)|`.zip`|
|`fds`|Famicom Disk System|`.fds`, `.zip`|
|`gb`|Game Boy|`.gb`, `.zip`|
|`gbc`|Game Boy Color|`.gbc`, `.zip`|
|`gba`|Game Boy Advance|`.gba`, `.zip`|
|`gamegear`|Sega Game Gear|`.gg`, `.zip`|
|`genesis` / `megadrive`|Sega Genesis / Mega Drive|`.bin`, `.smd`, `.gen`, `.md`, `.zip`|
|`mastersystem`|Sega Master System|`.sms`, `.zip`|
|`mame-libretro`|MAME (libretro)|`.zip`|
|`msx`|MSX|`.rom`, `.mx1`, `.mx2`, `.zip`|
|`n64`|Nintendo 64|`.z64`, `.n64`, `.v64`, `.zip`|
|`neogeo`|Neo Geo|`.zip` (com múltiplos `.bin` internos)|
|`nes`|Nintendo Entertainment System|`.nes`, `.zip`|
|`ngp`|Neo Geo Pocket|`.ngp`, `.zip`|
|`ngpc`|Neo Geo Pocket Color|`.ngc`, `.zip`|
|`pcengine`|PC Engine / TurboGrafx-16|`.pce`, `.cue` + `.bin`, `.zip`|
|`psx`|PlayStation 1|`.cue` + `.bin`, `.img`, `.pbp`, `.chd`, `.zip`|
|`segacd`|Sega CD|`.cue` + `.bin`, `.iso`, `.zip`|
|`sega32x`|Sega 32X|`.32x`, `.bin`, `.zip`|
|`sg-1000`|Sega SG-1000|`.sg`, `.zip`|
|`snes`|Super Nintendo|`.smc`, `.sfc`, `.zip`|
|`vectrex`|Vectrex|`.vec`, `.bin`, `.zip`|
|`zxspectrum`|ZX Spectrum|`.tzx`, `.tap`, `.dsk`, `.zip`|

##### Observações
- Alguns jogos não estavam funcionando então eu baixei algumas bios e colei na bios do raspberry pi 
	- [archtaurus/RetroPieBIOS: Full BIOS collection for RetroPie](https://github.com/archtaurus/RetroPieBIOS/tree/master)


Logs de erros de execução do jogo
```bash
cat /dev/shm/runcommand.log
```

L+->

/home/pi/RetroPie/roms/atari5200/Centipede (1982) (Atari).a52

a52dec "/home/pi/RetroPie/roms/atari5200/Centipede (1982) (Atari).a52" > "/home/pi/RetroPie/roms/atari5200/Centipede (1982) (Atari).bin"

a52dec pasta/arquivo.a52 > pasta/arquivo.bin

mv "/home/pi/RetroPie/roms/n64/Spider-Man (USA).z64" "/home/pi/RetroPie/roms/n64/Spider-Man.z64"