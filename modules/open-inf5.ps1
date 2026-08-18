Write-Host "🚀 Abrindo URLs da aula — Infantil 5..." -ForegroundColor Cyan

# URLs da aula — Infantil 5
$urls = @(
    "https://wordwall.net/pt/resource/13739343/o-alfabeto",
    "https://wordwall.net/pt/resource/7896115/complete-o-alfabeto",
    "https://wordwall.net/pt/resource/4008719/sequ%C3%AAncia-l%C3%B3gica-pintura",
    "https://wordwall.net/pt/resource/6516234/pintura",
    "https://wordwall.net/pt/resource/14753080/vamos-escrever-o-seu-nome",
    "https://wordwall.net/pt/resource/16067454/o-alfabeto",
    "https://wordwall.net/pt/resource/24159303/dessembaralhando-o-alfabeto",
    "https://wordwall.net/pt/resource/13456792/jogo-da-mem%C3%B3ria-o-som-das-consoantes",
    "https://wordwall.net/pt/resource/3958938/acerte-o-nome-das-figuras-vogais",
    "https://wordwall.net/pt/resource/13814773/lista-de-itens-para-o-anivers%C3%A1rio-do-senhor-alfabeto",
    "https://wordwall.net/pt/resource/21662290/matem%C3%A1tica/n%C3%BAmeros-e-quantidades-at%C3%A9-20",
    "https://wordwall.net/pt/resource/3555591/atividade-de-n%C3%BAmeros-e-quantidades",
    "https://wordwall.net/pt/resource/12268466/par-e-%C3%ADmpar",
    "https://wordwall.net/pt/resource/11937169/contagem",
    "https://www.wordwall.net/pt/resource/17969963/alfabetiza%C3%A7%C3%A3o",
    "https://wordwall.net/pt/resource/4980262/letras-e-n%C3%BAmeros",
    "https://wordwall.net/pt/resource/21805313/n%C3%BAmeros-letras-e-objetos",
    "https://wordwall.net/pt/resource/4144752/reconhecimento-de-n%C3%BAmeros-1-ao-30",
    "https://wordwall.net/pt/resource/6341502/s%C3%ADlabas"
)

# Detectar navegador
if (Get-Command chrome.exe -ErrorAction SilentlyContinue) {
    $browser = "chrome.exe"
    $processName = "chrome"
}
elseif (Get-Command msedge.exe -ErrorAction SilentlyContinue) {
    $browser = "msedge.exe"
    $processName = "msedge"
}
else {
    foreach ($url in $urls) {
        Start-Process $url
    }
    Write-Host "✅ Ambiente pronto!"
    exit
}

# Encerrar o navegador se já estiver aberto (garante --new-window limpo)
if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
    Write-Host "   Navegador aberto detectado — encerrando antes de abrir..." -ForegroundColor DarkYellow
    Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

# Abrir todas as URLs na mesma janela
Start-Process $browser ("--new-window " + ($urls -join " "))

Write-Host "✅ Ambiente pronto!"
