# Coleção de papéis de parede (arquivos na pasta /wallpapers do repositório)
# Formato: "Rótulo | arquivo.png"  — use nomes de arquivo sem acentos e sem espaços
# Para adicionar um novo: suba o PNG em /wallpapers e acrescente uma linha aqui
$wallpapers = @(
    "Colégio Conquista (padrão) | conquista.png"
    # "Volta às aulas            | volta-as-aulas.png"
    # "Páscoa                    | pascoa.png"
    # "Dia das Mães              | dia-das-maes.png"
    # "Festa Junina              | festa-junina.png"
    # "Dia dos Pais              | dia-dos-pais.png"
    # "Dia das Crianças          | dia-das-criancas.png"
    "Natal                     | natal.png"
)

$baseUrl = "https://raw.githubusercontent.com/petersonros/irm/main/wallpapers"

# Pasta pública: persiste e é acessível por todos os usuários da máquina
$destDir = Join-Path $env:PUBLIC "Pictures"

function Set-ConquistaWallpaper {
    param ($label, $file)

    Write-Host ""
    Write-Host "  Aplicando '$label'..." -ForegroundColor Cyan

    $url      = "$baseUrl/$file"
    $destFile = Join-Path $destDir "conquista-$file"

    try {
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        # TLS 1.2 para máquinas com PowerShell 5.1 antigo
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $ProgressPreference = 'SilentlyContinue'   # download muito mais rápido no PS 5.1
        Invoke-WebRequest -Uri $url -OutFile $destFile -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Host "  ERRO ao baixar $url" -ForegroundColor Red
        Write-Host "  $($_.Exception.Message)" -ForegroundColor Yellow
        return
    }

    # Estilo: Preencher (WallpaperStyle=10, TileWallpaper=0)
    $desktopKey = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $desktopKey -Name WallpaperStyle -Value "10"
    Set-ItemProperty -Path $desktopKey -Name TileWallpaper  -Value "0"
    Set-ItemProperty -Path $desktopKey -Name Wallpaper      -Value $destFile

    if (-not ("ConquistaWallpaper" -as [type])) {
        Add-Type @"
using System.Runtime.InteropServices;
public class ConquistaWallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    }

    # SPI_SETDESKWALLPAPER = 20 ; SPIF_UPDATEINIFILE | SPIF_SENDCHANGE = 3
    $ok = [ConquistaWallpaper]::SystemParametersInfo(20, 0, $destFile, 3)

    if ($ok -ne 0) {
        Write-Host "  Papel de parede aplicado para o usuario '$env:USERNAME'." -ForegroundColor Green
        Write-Host "  Arquivo: $destFile" -ForegroundColor DarkGray
    } else {
        Write-Host "  AVISO: o arquivo foi baixado, mas o Windows nao aplicou o wallpaper." -ForegroundColor Yellow
        Write-Host "  Tente fazer logoff/logon ou aplicar manualmente: $destFile" -ForegroundColor Yellow
    }
}

# Converte "Rótulo | arquivo" em objetos
$items = foreach ($w in $wallpapers) {
    $parts = $w -split '\|', 2
    [pscustomobject]@{ Label = $parts[0].Trim(); File = $parts[1].Trim() }
}

# Só um wallpaper cadastrado: aplica direto, sem submenu
if (@($items).Count -eq 1) {
    Set-ConquistaWallpaper $items[0].Label $items[0].File
    return
}

# Submenu
Write-Host ""
Write-Host "  ==== PAPEL DE PAREDE ====" -ForegroundColor Cyan
Write-Host ""
for ($i = 0; $i -lt $items.Count; $i++) {
    Write-Host ("  [{0}]" -f ($i + 1)) -ForegroundColor Cyan -NoNewline
    Write-Host " $($items[$i].Label)"
}
Write-Host ""
Write-Host "  [0]" -ForegroundColor DarkGray -NoNewline; Write-Host " Voltar"
Write-Host ""

$op = Read-Host "  Escolha"
$n  = 0
if ([int]::TryParse($op, [ref]$n) -and $n -ge 1 -and $n -le $items.Count) {
    Set-ConquistaWallpaper $items[$n - 1].Label $items[$n - 1].File
} elseif ($op -ne "0") {
    Write-Host "  Opcao invalida." -ForegroundColor Yellow
}
Write-Host ""
