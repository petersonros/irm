Write-Host "🧹 Limpando navegadores..." -ForegroundColor Yellow

# Fechar navegadores de forma limpa (evita mensagem de "fechado inesperadamente")
function Close-Browser {
    param ($name)
    $procs = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($procs) {
        $procs | ForEach-Object { $_.CloseMainWindow() | Out-Null }
        Start-Sleep -Seconds 2
        Stop-Process -Name $name -Force -ErrorAction SilentlyContinue
    }
}

Close-Browser "chrome"
Close-Browser "msedge"

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
Remove-IfExists "$chrome\Current Session"    "Chrome: sessão atual"
Remove-IfExists "$chrome\Current Tabs"       "Chrome: guias atuais"
Remove-IfExists "$chrome\Last Session"       "Chrome: última sessão"
Remove-IfExists "$chrome\Last Tabs"          "Chrome: últimas guias"
Remove-IfExists "$chrome\Sessions\*"         "Chrome: histórico de sessões"

# Edge
$edge = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
Remove-IfExists "$edge\History"              "Edge: histórico"
Remove-IfExists "$edge\Cookies"              "Edge: cookies"
Remove-IfExists "$edge\Cache\*"              "Edge: cache"
Remove-IfExists "$edge\Login Data"           "Edge: senhas"
Remove-IfExists "$edge\Login Data-journal"   "Edge: senhas (journal)"
Remove-IfExists "$edge\Web Data"             "Edge: autofill"
Remove-IfExists "$edge\Current Session"      "Edge: sessão atual"
Remove-IfExists "$edge\Current Tabs"         "Edge: guias atuais"
Remove-IfExists "$edge\Last Session"         "Edge: última sessão"
Remove-IfExists "$edge\Last Tabs"            "Edge: últimas guias"
Remove-IfExists "$edge\Sessions\*"           "Edge: histórico de sessões"

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
