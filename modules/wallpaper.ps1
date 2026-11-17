Write-Host ""
Write-Host "  Aplicando papel de parede..." -ForegroundColor Cyan

# URL do wallpaper (nome do arquivo com acento codificado: WP-Colégio-Conquista.png)
$wallpaperUrl = "https://raw.githubusercontent.com/petersonros/irm/main/WP-Col%C3%A9gio-Conquista.png"

# Pasta pública: persiste e é acessível por todos os usuários da máquina
$destDir  = Join-Path $env:PUBLIC "Pictures"
$destFile = Join-Path $destDir "wallpaper-conquista.png"

try {
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    # TLS 1.2 para máquinas com PowerShell 5.1 antigo
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $ProgressPreference = 'SilentlyContinue'   # download muito mais rápido no PS 5.1
    Invoke-WebRequest -Uri $wallpaperUrl -OutFile $destFile -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Host "  ERRO ao baixar o wallpaper: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# Estilo: Preencher (WallpaperStyle=10, TileWallpaper=0)
$desktopKey = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $desktopKey -Name WallpaperStyle -Value "10"
Set-ItemProperty -Path $desktopKey -Name TileWallpaper  -Value "0"
Set-ItemProperty -Path $desktopKey -Name Wallpaper      -Value $destFile

# Aplica imediatamente via API do Windows
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

Write-Host ""
if ($ok -ne 0) {
    Write-Host "  Papel de parede aplicado para o usuario '$env:USERNAME'." -ForegroundColor Green
    Write-Host "  Arquivo: $destFile" -ForegroundColor DarkGray
} else {
    Write-Host "  AVISO: o arquivo foi baixado, mas o Windows nao aplicou o wallpaper." -ForegroundColor Yellow
    Write-Host "  Tente fazer logoff/logon ou aplicar manualmente: $destFile" -ForegroundColor Yellow
}
Write-Host ""
