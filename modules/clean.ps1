Write-Host "🧹 Limpando navegadores..." -ForegroundColor Yellow

# Fechar navegadores
Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue
Stop-Process -Name msedge -Force -ErrorAction SilentlyContinue

# Chrome
$chrome = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"

Remove-Item "$chrome\History"    -Force -ErrorAction SilentlyContinue
Remove-Item "$chrome\Cookies"    -Force -ErrorAction SilentlyContinue
Remove-Item "$chrome\Cache\*"    -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$chrome\Login Data" -Force -ErrorAction SilentlyContinue
Remove-Item "$chrome\Web Data"   -Force -ErrorAction SilentlyContinue

# Edge
$edge = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"

Remove-Item "$edge\History"    -Force -ErrorAction SilentlyContinue
Remove-Item "$edge\Cookies"    -Force -ErrorAction SilentlyContinue
Remove-Item "$edge\Cache\*"    -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$edge\Login Data" -Force -ErrorAction SilentlyContinue
Remove-Item "$edge\Web Data"   -Force -ErrorAction SilentlyContinue

Write-Host "✅ Limpeza concluída!"
