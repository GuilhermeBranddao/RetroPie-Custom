import os
from pathlib import Path
from flask import Flask, render_template, jsonify, request

app = Flask(__name__)

# --- Configurações ---
# ATENÇÃO: Altere este caminho para o diretório de ROMs do seu RetroPie
ROMS_BASE_PATH = Path(
    os.getenv("RETROPIE_ROMS_PATH", "/home/pi/RetroPie/roms")
)

LOGS_DIR = Path(
    os.getenv("SORTER_LOGS_DIR", "/home/pi/logs")
)

# Garante que o diretório de log exista antes de tentar escrever nele.
# Isso torna o script mais robusto e evita erros de 'Arquivo não encontrado'.
LOGS_DIR.mkdir(parents=True, exist_ok=True)

# O caminho completo do arquivo de log é construído de forma segura.
LOG_FILE_PATH = LOGS_DIR / "usb-sorter.log"

# --- Configurações da Aplicação ---

# Lê o número de linhas de log a serem exibidas no servidor web.
# A variável é convertida para inteiro para segurança.
LOG_LINES_TO_SHOW = int(os.getenv("SORTER_LOG_LINES", 100))

def get_last_log_lines(n_lines):
    """Lê as N últimas linhas de um arquivo de log de forma eficiente."""
    if not LOG_FILE_PATH.exists():
        return ["Arquivo de log não encontrado."]
    
    try:
        with open(LOG_FILE_PATH, "r", encoding="utf-8") as f:
            # Lê todas as linhas e pega as últimas 'n_lines'
            lines = f.readlines()
            last_lines = lines[-n_lines:]
            # Inverte a lista para mostrar o mais recente primeiro
            return last_lines[::-1]
    except Exception as e:
        return [f"Erro ao ler o arquivo de log: {e}"]

def get_games_list():
    """Varre o diretório de ROMs e retorna uma lista de jogos."""
    games = []
    if not ROMS_BASE_PATH.is_dir():
        return games

    # Itera recursivamente sobre todos os arquivos no diretório base de ROMs
    for file_path in ROMS_BASE_PATH.rglob("*"):
        if file_path.is_file():
            # O 'sistema' é o nome da pasta pai (ex: snes, nes, megadrive)
            system = file_path.parent.name
            games.append({
                "system": system,
                "filename": file_path.name,
                "path": str(file_path.resolve()) # Caminho absoluto para o arquivo
            })
    return sorted(games, key=lambda x: (x['system'], x['filename']))

# --- Rotas para Servir as Páginas HTML ---

@app.route('/')
def games_page():
    """Renderiza a página de gerenciamento de jogos."""
    return render_template('games.html', title="Gerenciar Jogos")

@app.route('/logs')
def logs_page():
    """Renderiza a página de visualização de logs."""
    return render_template('logs.html', title="Logs de Instalação")

# --- Rotas de API para fornecer dados ao Frontend ---

@app.route('/api/logs')
def api_logs():
    """Fornece as últimas linhas do log em formato JSON."""
    log_content = get_last_log_lines(LOG_LINES_TO_SHOW)
    return jsonify(log_content)

@app.route('/api/games')
def api_games():
    """Fornece a lista de jogos em formato JSON."""
    return jsonify(get_games_list())

@app.route('/api/delete-games', methods=['POST'])
def api_delete_games():
    """Recebe uma lista de arquivos para apagar."""
    data = request.get_json()
    files_to_delete = data.get('files', [])
    
    deleted_count = 0
    errors = []

    # Verificação de segurança crucial
    roms_abs_path = str(ROMS_BASE_PATH.resolve())

    for file_path_str in files_to_delete:
        file_path = Path(file_path_str).resolve()
        
        # Impede a exclusão de arquivos fora do diretório de ROMs
        if not str(file_path).startswith(roms_abs_path):
            errors.append(f"Acesso negado para o arquivo: {file_path.name}")
            continue

        try:
            if file_path.exists() and file_path.is_file():
                os.remove(file_path)
                deleted_count += 1
            else:
                errors.append(f"Arquivo não encontrado: {file_path.name}")
        except OSError as e:
            errors.append(f"Erro ao apagar {file_path.name}: {e}")
            
    return jsonify({
        "message": f"{deleted_count} jogo(s) apagado(s) com sucesso.",
        "errors": errors
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)