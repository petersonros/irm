Write-Host "🧹 Limpando navegadores..." -ForegroundColor Yellow

# Fechar navegadores
Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue
Stop-Process -Name msedge -Force -ErrorAction SilentlyContinue

$removed = @()

function Remove-IfExists {
    param ($path, $label)
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        $script:removed += $label
    }
}

# Chrome
$chrome = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
Remove-IfExists "$chrome\History"            "Chrome: histórico"
Remove-IfExists "$chrome\Cookies"            "Chrome: cookies"
Remove-IfExists "$chrome\Cache\*"            "Chrome: cache"
Remove-IfExists "$chrome\Login Data"         "Chrome: senhas"
Remove-IfExists "$chrome\Login Data-journal" "Chrome: senhas (journal)"
Remove-IfExists "$chrome\Web Data"           "Chrome: autofill"

# Edge
$edge = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
Remove-IfExists "$edge\History"              "Edge: histórico"
Remove-IfExists "$edge\Cookies"              "Edge: cookies"
Remove-IfExists "$edge\Cache\*"              "Edge: cache"
Remove-IfExists "$edge\Login Data"           "Edge: senhas"
Remove-IfExists "$edge\Login Data-journal"   "Edge: senhas (journal)"
Remove-IfExists "$edge\Web Data"             "Edge: autofill"

# Resumo
Write-Host ""
if ($removed.Count -eq 0) {
    Write-Host "✅ Nada a remover — navegadores já estavam limpos." -ForegroundColor Green
} else {
    Write-Host "✅ Limpeza concluída. Removido ($($removed.Count) item(s)):" -ForegroundColor Green
    foreach ($item in $removed) {
        Write-Host "   • $item" -ForegroundColor Gray
    }
}
