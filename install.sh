#!/usr/bin/env bash
# omega — Script di installazione per Mac/Linux
# Uso: curl -fsSL https://raw.githubusercontent.com/mromano1398/omega-claude-plugin/main/install.sh | bash

set -e

REPO="https://github.com/mromano1398/omega-claude-plugin.git"
PLUGIN_DIR="$HOME/.claude/plugins/omega"

echo "🔧 Installazione omega plugin per Claude Code..."

# Verifica git
if ! command -v git &> /dev/null; then
  echo "❌ git non trovato. Installa git prima di procedere."
  exit 1
fi

# Verifica Claude Code
if ! command -v claude &> /dev/null; then
  echo "⚠️  Claude Code CLI non trovato nel PATH."
  echo "   Assicurati che Claude Code sia installato: https://docs.anthropic.com/en/docs/claude-code"
fi

# Crea directory plugins se non esiste
mkdir -p "$HOME/.claude/plugins"

# Clone o aggiorna
if [ -d "$PLUGIN_DIR" ]; then
  echo "📦 Aggiornamento omega esistente..."
  cd "$PLUGIN_DIR"
  git pull --ff-only
  echo "✅ omega aggiornato alla versione $(cat .claude-plugin/plugin.json | grep '"version"' | head -1 | grep -oP '[\d.]+')"
else
  echo "📦 Download omega..."
  git clone --depth 1 "$REPO" "$PLUGIN_DIR"
  echo "✅ omega installato in $PLUGIN_DIR"
fi

# Aggiungi a settings.json se non già presente
SETTINGS_FILE="$HOME/.claude/settings.json"
PLUGIN_PATH="$PLUGIN_DIR"

if [ -f "$SETTINGS_FILE" ]; then
  if grep -q "omega" "$SETTINGS_FILE" 2>/dev/null; then
    echo "ℹ️  omega è già configurato in settings.json"
  else
    echo ""
    echo "📝 Aggiungi manualmente questo percorso al tuo \$HOME/.claude/settings.json:"
    echo "   \"pluginDirs\": [\"$PLUGIN_PATH\"]"
  fi
else
  echo ""
  echo "📝 Crea \$HOME/.claude/settings.json con questo contenuto:"
  echo '   { "pluginDirs": ["'"$PLUGIN_PATH"'"] }'
fi

echo ""
echo "🚀 Pronto! Avvia Claude Code e scrivi: /omega:omega"
