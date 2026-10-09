Write-Host "🚀 Abrindo URLs da aula — Infantil 1..." -ForegroundColor Cyan

# URLs da aula — Infantil 1
$urls = @(
    # 03-09-2026
    #   "https://www.digipuzzle.net/digipuzzle/kids/puzzles/hiddenobjects.htm?language=portuguese&linkback=../../../pt/jogoseducativos/palavras/index.htm",
    #    "https://www.digipuzzle.net/minigames/codegrid/codegrid_images_shapes.htm?language=portuguese&linkback=../../pt/jogoseducativos/ciencias/index.htm"
    #   "https://wordwall.net/pt/resource/4191449/m-ou-n-eccavp",
    #   "https://www.digipuzzle.net/minigames/flashmath/finderrors_texts_pt_mn.htm?language=portuguese&linkback=../../pt/jogoseducativos/palavras/index.htm",
    #   "https://www.digipuzzle.net/kids/animalcartoons/puzzles/photosearch.htm?language=portuguese&linkback=../../../pt/jogoseducativos/jogos/index.htm"
    
    # 10-09-2026 (Soraia primeiro ano B quer parecido) (Cintia primeiro ano C)
    #   "https://wordwall.net/pt/resource/116240486/leitura-de-frases",
    #   "https://wordwall.net/pt/resource/4081465/leitura",
    #   "https://wordwall.net/pt/resource/16831120/leitura-de-frases-1ano",
    #  "https://wordwall.net/pt/resource/77901051/leitura/interpreta%C3%A7%C3%A3o-de-frases"
    
    # 11-09-2026 (Andreia primeiro ano C)
    #   "https://www.digipuzzle.net/minigames/findtheletter/findtheletter_pt.htm?language=portuguese&linkback=../../pt/jogoseducativos/alfabeto/index.htm",
    #   "https://www.digipuzzle.net/digipuzzle/animals/puzzles/clutter_animal_skins.htm?language=portuguese&linkback=../../../pt/jogoseducativos/jogos/index.htm",
    #   "https://www.digipuzzle.net/digipuzzle/animals/puzzles/clutter.htm?language=portuguese&linkback=../../../pt/jogoseducativos/jogos/index.htm"

    # 15-09-2026 (Soraria primero ano B)
    #"https://wordwall.net/pt/resource/14357894/avi%C3%A3o-acertando-a-soma",
    #"https://wordwall.net/pt/resource/77901051/leitura/interpreta%C3%A7%C3%A3o-de-frases",
    #"https://wordwall.net/pt/resource/51829825/organizar-frases-fonema-s",
    #"https://wordwall.net/pt/resource/3648364/soma",
    #"https://wordwall.net/pt/resource/36730359/fonemas/organizar-as-frases-fonema-sz"

    # 17-09-2026 (Cintia primeiro ano A)
    #"https://wordwall.net/pt/resource/4081465/leitura",
    #"https://wordwall.net/pt/resource/75023720/portuguesa/complete-as-frases",
    #"https://wordwall.net/pt/resource/3398369/pareamento-de-frases-imagens",
    #"https://wordwall.net/pt/resource/19448684/completar-frases"

    # 18-09-2026 (Andreia primeiro ano C)
    #"https://www.digipuzzle.net/minigames/flashmath/finderrors_texts_pt_mn.htm?language=portuguese&linkback=../../pt/jogoseducativos/palavras/index.htm",
    #"https://www.digipuzzle.net/kids/animalcartoons/puzzles/photosearch.htm?language=portuguese&linkback=../../../pt/jogoseducativos/jogos/index.htm"

    # 22-09-2026 (Soraia primeiro ano B)
    # "https://wordwall.net/pt/resource/8243546/quiz-alfabetiza%C3%A7%C3%A3o-1-ano",
    # "https://wordwall.net/pt/resource/23237180/jogo-de-rimar",
    # "https://wordwall.net/pt/resource/14239519/interpreta%C3%A7%C3%A3o-de-tabelas-e-gr%C3%A1ficos",
    # "https://wordwall.net/pt/resource/1052057/completa-as-frases"

    # 24-09-2026 (Cintia primeiro ano A)
    # "https://wordwall.net/pt/resource/21978075/d%C3%BAzia-e-meia-d%C3%BAzia",
    # "https://wordwall.net/pt/resource/26444444/lh-nh-ch-2%C2%BA-ano"

    # 01-10-2026 (Cintia primeiro ano A)
    # "https://wordwall.net/pt/resource/4474837/aee-leitura-e-compreens%C3%A3o-frases",
    # "https://wordwall.net/es/resource/8500928/portugu%C3%AAs-completar-frases",
    # "https://wordwall.net/pt/resource/16831120/leitura-de-frases-1ano",
    # "https://wordwall.net/pt/resource/15603114/frases-simples"

    # 06-10-2026 (Soraia primeiro ano B)
    # "https://www.digipuzzle.net/digipuzzle/kids/puzzles/connectpieces_wordinword_pt.htm?language=portuguese&linkback=../../../pt/jogoseducativos/palavras/index.htm#google_vignette",
    # "https://www.digipuzzle.net/minigames/mathmemory/memory_wildanimals_pt.htm?language=portuguese&linkback=../../pt/jogoseducativos/palavras/index.htm",
    # "https://wordwall.net/pt/resource/74359025/ci%C3%AAncias/jogo-da-mem%C3%B3ria-animais-da-selva",
    # "https://wordwall.net/pt/resource/32011829/portuguese-language/palavras-simples-1ano"

    # 08-10-2026 (Cintia primeiro ano A)
    # "https://wordwall.net/pt/resource/13653718/n%C3%BAmeros-por-extenso",
    # "https://wordwall.net/pt/resource/36375146/matem%C3%A1tica/n%C3%BAmeros-por-extenso",
    # "https://wordwall.net/pt/resource/3866318/n%C3%BAmeros-por-extenso"

    # 06-10-2026 (Andreia primeiro ano C)
    "https://www.digipuzzle.net/digipuzzle/kids/puzzles/connectpieces_wordinword_pt.htm?language=portuguese&linkback=../../../pt/jogoseducativos/palavras/index.htm#google_vignette",
    "https://www.digipuzzle.net/minigames/mathmemory/memory_wildanimals_pt.htm?language=portuguese&linkback=../../pt/jogoseducativos/palavras/index.htm",
    "https://wordwall.net/pt/resource/74359025/ci%C3%AAncias/jogo-da-mem%C3%B3ria-animais-da-selva",
    "https://wordwall.net/pt/resource/32011829/portuguese-language/palavras-simples-1ano"

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
