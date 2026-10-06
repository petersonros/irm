Write-Host "🚀 Abrindo URLs da aula — Infantil 5..." -ForegroundColor Cyan

# URLs da aula — Infantil 5
$urls = @(
    #    "https://wordwall.net/pt/resource/13739343/o-alfabeto",
    #    "https://wordwall.net/pt/resource/7896115/complete-o-alfabeto",
    #    "https://wordwall.net/pt/resource/4008719/sequ%C3%AAncia-l%C3%B3gica-pintura",
    #    "https://wordwall.net/pt/resource/6516234/pintura",
    #    "https://wordwall.net/pt/resource/14753080/vamos-escrever-o-seu-nome",
    #    "https://wordwall.net/pt/resource/16067454/o-alfabeto",
    #    "https://wordwall.net/pt/resource/24159303/dessembaralhando-o-alfabeto"
    #    "https://wordwall.net/pt/resource/12268466/par-e-%C3%ADmpar",
    #    "https://wordwall.net/pt/resource/13456792/jogo-da-mem%C3%B3ria-o-som-das-consoantes",
    #    "https://wordwall.net/pt/resource/21662290/matem%C3%A1tica/n%C3%BAmeros-e-quantidades-at%C3%A9-20"

    # 08-09-2026
    # "https://wordwall.net/pt/resource/3958938/acerte-o-nome-das-figuras-vogais",
    # "https://wordwall.net/pt/resource/13814773/lista-de-itens-para-o-anivers%C3%A1rio-do-senhor-alfabeto",
    # "https://wordwall.net/pt/resource/11937169/contagem",
    # "https://wordwall.net/pt/resource/4980262/letras-e-n%C3%BAmeros",

    # 15-09-2026
    # "https://wordwall.net/pt/resource/4980262/letras-e-n%C3%BAmeros",
    # "https://wordwall.net/pt/resource/21805313/n%C3%BAmeros-letras-e-objetos",
    # "https://wordwall.net/pt/resource/4144752/reconhecimento-de-n%C3%BAmeros-1-ao-30",
    # "https://wordwall.net/pt/resource/6341502/s%C3%ADlabas"

    # 22-09-2026 (Tanea Infantil 5B)
    # "https://wordwall.net/pt/resource/4980262/letras-e-n%C3%BAmeros",
    # "https://www.wordwall.net/pt/resource/17969963/alfabetiza%C3%A7%C3%A3o",
    # "https://wordwall.net/pt/resource/3555591/atividade-de-n%C3%BAmeros-e-quantidades",
    # "https://wordwall.net/pt/resource/13814773/lista-de-itens-para-o-anivers%C3%A1rio-do-senhor-alfabeto",
    # "https://wordwall.net/pt/resource/3958938/acerte-o-nome-das-figuras-vogais"

    # 23-09-2026 (Patricia Infantil 5A)
    #"https://wordwall.net/pt/resource/3958938/acerte-o-nome-das-figuras-vogais",
    #"https://wordwall.net/pt/resource/13814773/lista-de-itens-para-o-anivers%C3%A1rio-do-senhor-alfabeto",
    #"https://wordwall.net/pt/resource/3555591/atividade-de-n%C3%BAmeros-e-quantidades"
 
    # lista nova da Tanea Infantil 5B 29-09-2026
    #https://wordwall.net/pt/resource/17438307/atividades-1%C2%BA-ano-alfabetiza%C3%A7%C3%A3o
    #https://wordwall.net/pt-br/community/percep%C3%A7%C3%A3o-visual
    #https://wordwall.net/pt/resource/38551133/animais-em-ingl%C3%AAs/animais-1ano
    #https://wordwall.net/pt/resource/27200428/l%C3%ADngua-portuguesa/desembaralhe-as-letras-animais
    #https://wordwall.net/pt/resource/3381604/caca-palavras-animais
    #https://wordwall.net/pt/resource/5375507/n%C3%BAmeros-de-1-a-10/jogo-da-mem%C3%B3ria-de-0-a-10
    #https://wordwall.net/pt/resource/19290429/l%C3%ADngua-portuguesa/sequ%C3%AAncia-do-b-esteira
    #https://wordwall.net/pt/resource/24213757/alfabetiza%C3%A7%C3%A3o/1%C2%BA-ano-vamos-somar
    #https://wordwall.net/pt/resource/18203503/portugu%C3%AAs-do-1%C2%BA-ao-5%C2%BA-ano/atividade-1-ano
    #https://wordwall.net/pt/resource/57777162/l%C3%ADngua-portuguesa/alfabetiza%C3%A7%C3%A3o
    #https://wordwall.net/pt/resource/4977748/alfabetiza%C3%A7%C3%A3o
    #https://wordwall.net/pt/resource/4553388/alfabetiza%C3%A7%C3%A3o

    # 06-10-2026 (Tanea Infantil 5B)
    "https://wordwall.net/pt/resource/27200428/l%C3%ADngua-portuguesa/desembaralhe-as-letras-animais",
    "https://wordwall.net/pt/resource/38551133/animais-em-ingl%C3%AAs/animais-1ano",
    "https://wordwall.net/pt/resource/17438307/atividades-1%C2%BA-ano-alfabetiza%C3%A7%C3%A3o",
    "https://wordwall.net/pt/resource/12313686/percep%C3%A7%C3%A3o-visual"

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
        Start-Sleep -Milliseconds 800
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

# Abrir as URLs na mesma janela, uma por vez, para manter a ordem da lista
Start-Process $browser ("--new-window `"" + $urls[0] + "`"")
Start-Sleep -Seconds 2
foreach ($url in ($urls | Select-Object -Skip 1)) {
    Start-Process $browser ("`"" + $url + "`"")
    Start-Sleep -Milliseconds 800
}

Write-Host "✅ Ambiente pronto!"
