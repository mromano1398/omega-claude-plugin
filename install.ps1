# omega — Script di installazione per Windows
# Uso: irm https://raw.githubusercontent.com/mromano1398/omega-claude-plugin/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$REPO = "https://github.com/mromano1398/omega-claude-plugin.git"
$PLUGIN_DIR = "$env:USERPROFILE\.claude\plugins\omega"

Write-Host "Installazione omega plugin per Claude Code..." -ForegroundColor Cyan

# Verifica git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "git non trovato. Installa git da https://git-scm.com" -ForegroundColor Red
    exit 1
}

# Crea directory plugins
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\plugins" | Out-Null

# Clone o aggiorna
if (Test-Path $PLUGIN_DIR) {
    Write-Host "Aggiornamento omega esistente..." -ForegroundColor Yellow
    Set-Location $PLUGIN_DIR
    git pull --ff-only
    $version = (Get-Content ".claude-plugin\plugin.json" | Select-String '"version"').ToString() -replace '.*"version":\s*"([^"]+)".*', '$1'
    Write-Host "omega aggiornato alla versione $version" -ForegroundColor Green
} else {
    Write-Host "Download omega..." -ForegroundColor Yellow
    git clone --depth 1 $REPO $PLUGIN_DIR
    Write-Host "omega installato in $PLUGIN_DIR" -ForegroundColor Green
}

$SETTINGS_FILE = "$env:USERPROFILE\.claude\settings.json"
Write-Host ""
Write-Host "Aggiungi questo al tuo settings.json ($SETTINGS_FILE):" -ForegroundColor Cyan
Write-Host "  { `"pluginDirs`": [`"$PLUGIN_DIR`"] }" -ForegroundColor White
Write-Host ""
Write-Host "Pronto! Avvia Claude Code e scrivi: /omega:omega" -ForegroundColor Green
