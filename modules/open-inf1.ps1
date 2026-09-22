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
    "https://wordwall.net/pt/resource/8243546/quiz-alfabetiza%C3%A7%C3%A3o-1-ano",
    "https://wordwall.net/pt/resource/23237180/jogo-de-rimar",
    "https://wordwall.net/pt/resource/14239519/interpreta%C3%A7%C3%A3o-de-tabelas-e-gr%C3%A1ficos",
    "https://wordwall.net/pt/resource/1052057/completa-as-frases"
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
