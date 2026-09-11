Write-Host "🚀 Abrindo URLs da aula — Infantil 1..." -ForegroundColor Cyan

# URLs da aula — Infantil 1
$urls = @(
    # 03-09-2026
    #   "https://www.digipuzzle.net/digipuzzle/kids/puzzles/hiddenobjects.htm?language=portuguese&linkback=../../../pt/jogoseducativos/palavras/index.htm",
    #    "https://www.digipuzzle.net/minigames/codegrid/codegrid_images_shapes.htm?language=portuguese&linkback=../../pt/jogoseducativos/ciencias/index.htm"
    #   "https://wordwall.net/pt/resource/4191449/m-ou-n-eccavp",
    #   "https://www.digipuzzle.net/minigames/flashmath/finderrors_texts_pt_mn.htm?language=portuguese&linkback=../../pt/jogoseducativos/palavras/index.htm",
    #   "https://www.digipuzzle.net/kids/animalcartoons/puzzles/photosearch.htm?language=portuguese&linkback=../../../pt/jogoseducativos/jogos/index.htm"
    # 10-09-2026
#    "https://wordwall.net/pt/resource/116240486/leitura-de-frases",
 #   "https://wordwall.net/pt/resource/4081465/leitura",
  #  "https://wordwall.net/pt/resource/16831120/leitura-de-frases-1ano",
   # "https://wordwall.net/pt/resource/77901051/leitura/interpreta%C3%A7%C3%A3o-de-frases"
    "https://www.digipuzzle.net/minigames/findtheletter/findtheletter_pt.htm?language=portuguese&linkback=../../pt/jogoseducativos/alfabeto/index.htm",
    "https://www.digipuzzle.net/digipuzzle/animals/puzzles/clutter_animal_skins.htm?language=portuguese&linkback=../../../pt/jogoseducativos/jogos/index.htm",
    "https://www.digipuzzle.net/digipuzzle/animals/puzzles/clutter.htm?language=portuguese&linkback=../../../pt/jogoseducativos/jogos/index.htm"
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
