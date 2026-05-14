# =========================
# VERIFICAÇÃO DE PRIVILÉGIOS
# =========================
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host ""
    Write-Host "  ERRO: Este script precisa ser executado como Administrador." -ForegroundColor Red
    Write-Host "  Clique com o botao direito no PowerShell e selecione 'Executar como administrador'." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# =========================
# APRESENTAÇÃO
# =========================
Write-Host ""
Write-Host "  ==== CONFIGURACAO DA MAQUINA ====" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Este script ira:" -ForegroundColor Yellow
Write-Host "   - Criar o usuario 'aluno' (sem senha)"
Write-Host "   - Configurar papel de parede, area de trabalho e Chrome padrao para 'aluno'"
Write-Host "   - Migrar o auto-login do Pichau para 'aluno'"
Write-Host "   - Criar o usuario 'admin' com a senha informada"
Write-Host "   - Adicionar 'admin' ao grupo Administradores"
Write-Host "   - Desativar o usuario 'Pichau'"
Write-Host ""

# =========================
# SOLICITAR SENHA DO ADMIN
# =========================
$adminPassword = Read-Host "  Senha para o novo usuario admin" -AsSecureString
Write-Host ""

$feito = @()

# =========================
# 1. CRIAR USUÁRIO aluno
# =========================
try {
    $alunoExists = Get-LocalUser -Name "aluno" -ErrorAction SilentlyContinue
    if (-not $alunoExists) {
        New-LocalUser -Name "aluno" `
            -NoPassword `
            -FullName "Aluno" `
            -Description "Conta padrao para uso em aula" `
            -ErrorAction Stop | Out-Null
        $feito += "Usuario 'aluno' criado (sem senha)"
    } else {
        $feito += "Usuario 'aluno' ja existia — ignorado"
    }
} catch {
    Write-Host "  ERRO ao criar usuario 'aluno': $_" -ForegroundColor Red
    exit 1
}

# =========================
# HELPER: hive do perfil do aluno
# =========================
$alunoProfile = "C:\Users\aluno"
$alunoNtuser  = "$alunoProfile\NTUSER.DAT"
$hiveKey      = "HKU\aluno_hive"
$hivePsPath   = "Registry::HKEY_USERS\aluno_hive"

function Load-AlunoHive {
    # Se o perfil ainda nao foi criado (aluno nunca fez login),
    # copia o NTUSER.DAT do perfil Default como base.
    if (-not (Test-Path $alunoNtuser)) {
        $default = "C:\Users\Default\NTUSER.DAT"
        if (-not (Test-Path $default)) { throw "NTUSER.DAT do perfil Default nao encontrado." }
        New-Item -ItemType Directory -Path $alunoProfile -Force -ErrorAction Stop | Out-Null
        Copy-Item $default $alunoNtuser -ErrorAction Stop
    }
    $out = reg load $hiveKey $alunoNtuser 2>&1
    if ($LASTEXITCODE -ne 0) { throw "reg load falhou (codigo $LASTEXITCODE): $out" }
}

function Unload-AlunoHive {
    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()
    reg unload $hiveKey 2>&1 | Out-Null
}

# =========================
# 2. PAPEL DE PAREDE
# =========================
$wallpaperUrl  = "https://colegioconquista.com.br/wp-content/uploads/2021/01/capa-face-site.jpg"
$wallpaperDir  = "$alunoProfile\AppData\Roaming"
$wallpaperPath = "$wallpaperDir\wallpaper.jpg"

try {
    New-Item -ItemType Directory -Path $wallpaperDir -Force -ErrorAction Stop | Out-Null
    Invoke-WebRequest -Uri $wallpaperUrl -OutFile $wallpaperPath -UseBasicParsing -ErrorAction Stop
    $feito += "Papel de parede baixado para '$wallpaperPath'"
} catch {
    Write-Host "  AVISO: nao foi possivel baixar o papel de parede: $_" -ForegroundColor Yellow
    $feito += "Download do papel de parede — falhou (ver aviso acima)"
    $wallpaperPath = ""
}

# =========================
# 3. CONFIGURAR PERFIL VIA HIVE
#    (papel de parede + icones do sistema)
# =========================
$hiveLoaded = $false
try {
    Load-AlunoHive
    $hiveLoaded = $true
} catch {
    Write-Host "  AVISO: nao foi possivel carregar o hive do perfil 'aluno': $_" -ForegroundColor Yellow
}

if ($hiveLoaded) {
    # 3a. Aplicar papel de parede
    try {
        $desktopKey = "$hivePsPath\Control Panel\Desktop"
        if (-not (Test-Path $desktopKey)) {
            New-Item -Path $desktopKey -Force -ErrorAction Stop | Out-Null
        }
        if ($wallpaperPath) {
            Set-ItemProperty -Path $desktopKey -Name "Wallpaper"      -Value $wallpaperPath -ErrorAction Stop
        }
        Set-ItemProperty -Path $desktopKey -Name "WallpaperStyle" -Value "10" -ErrorAction Stop  # Fill
        Set-ItemProperty -Path $desktopKey -Name "TileWallpaper"  -Value "0"  -ErrorAction Stop
        $feito += "Papel de parede aplicado no registro do perfil 'aluno' (estilo: Fill)"
    } catch {
        Write-Host "  AVISO: erro ao aplicar papel de parede no registro: $_" -ForegroundColor Yellow
        $feito += "Aplicacao do papel de parede no registro — falhou (ver aviso acima)"
    }

    # 3b. Ocultar icones do sistema na area de trabalho
    try {
        $hideKey = "$hivePsPath\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
        if (-not (Test-Path $hideKey)) {
            New-Item -Path $hideKey -Force -ErrorAction Stop | Out-Null
        }
        # Este Computador
        Set-ItemProperty -Path $hideKey -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 1 -Type DWord -ErrorAction Stop
        # Lixeira
        Set-ItemProperty -Path $hideKey -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 1 -Type DWord -ErrorAction Stop
        # Arquivos do Usuario
        Set-ItemProperty -Path $hideKey -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Value 1 -Type DWord -ErrorAction Stop
        # Rede
        Set-ItemProperty -Path $hideKey -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Value 1 -Type DWord -ErrorAction Stop
        $feito += "Icones do sistema ocultados na area de trabalho do 'aluno'"
    } catch {
        Write-Host "  AVISO: erro ao ocultar icones do sistema: $_" -ForegroundColor Yellow
        $feito += "Ocultacao de icones do sistema — falhou (ver aviso acima)"
    }

    Unload-AlunoHive
}

# 3c. Remover icones publicos da area de trabalho
try {
    $publicIcons = Get-ChildItem "C:\Users\Public\Desktop\*" -ErrorAction SilentlyContinue
    if ($publicIcons) {
        $publicIcons | Remove-Item -Force -ErrorAction SilentlyContinue
        $feito += "Icones publicos da area de trabalho removidos ($($publicIcons.Count) item(s))"
    } else {
        $feito += "Area de trabalho publica ja estava limpa"
    }
} catch {
    Write-Host "  AVISO: erro ao limpar area de trabalho publica: $_" -ForegroundColor Yellow
}

# =========================
# 4. CHROME COMO NAVEGADOR PADRÃO
# =========================
try {
    $xmlPath = "$env:TEMP\chrome_default.xml"
    @"
<?xml version="1.0" encoding="UTF-8"?>
<DefaultAssociations>
  <Association Identifier=".htm"  ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".html" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier=".pdf"  ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier="http"  ProgId="ChromeHTML" ApplicationName="Google Chrome" />
  <Association Identifier="https" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
</DefaultAssociations>
"@ | Set-Content -Path $xmlPath -Encoding UTF8 -ErrorAction Stop

    $dism = dism /Online /Import-DefaultAppAssociations:$xmlPath 2>&1
    if ($LASTEXITCODE -ne 0) { throw "DISM saiu com codigo $LASTEXITCODE: $dism" }

    Remove-Item $xmlPath -ErrorAction SilentlyContinue
    $feito += "Chrome definido como navegador padrao para HTTP, HTTPS e PDF (via DISM)"
} catch {
    Write-Host "  AVISO: nao foi possivel definir Chrome como padrao: $_" -ForegroundColor Yellow
    $feito += "Chrome como padrao — falhou (ver aviso acima)"
}

# =========================
# 5. MIGRAR AUTO-LOGIN para aluno
# =========================
try {
    $winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"     -ErrorAction Stop
    Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "aluno" -ErrorAction Stop
    Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value ""      -ErrorAction Stop
    Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "."     -ErrorAction Stop
    $feito += "Auto-login migrado do Pichau para 'aluno'"
} catch {
    Write-Host "  ERRO ao configurar auto-login no registro: $_" -ForegroundColor Red
    exit 1
}

# =========================
# 6. CRIAR USUÁRIO admin
# =========================
try {
    $adminExists = Get-LocalUser -Name "admin" -ErrorAction SilentlyContinue
    if (-not $adminExists) {
        New-LocalUser -Name "admin" `
            -Password $adminPassword `
            -FullName "Administrador" `
            -Description "Conta de administracao do laboratorio" `
            -PasswordNeverExpires `
            -ErrorAction Stop | Out-Null
        $feito += "Usuario 'admin' criado"
    } else {
        Set-LocalUser -Name "admin" -Password $adminPassword -ErrorAction Stop
        $feito += "Usuario 'admin' ja existia — senha atualizada"
    }
} catch {
    Write-Host "  ERRO ao criar usuario 'admin': $_" -ForegroundColor Red
    exit 1
}

# =========================
# 7. ADICIONAR admin AO GRUPO ADMINISTRADORES
# =========================
try {
    Add-LocalGroupMember -Group "Administradores" -Member "admin" -ErrorAction Stop
    $feito += "Usuario 'admin' adicionado ao grupo Administradores"
} catch {
    if ($_.Exception -is [Microsoft.PowerShell.Commands.MemberExistsException] -or
        $_.Exception.Message -match "already a member|ja e membro|ja membro") {
        $feito += "Usuario 'admin' ja era membro de Administradores — ignorado"
    } else {
        Write-Host "  ERRO ao adicionar 'admin' ao grupo Administradores: $_" -ForegroundColor Red
        exit 1
    }
}

# =========================
# 8. DESATIVAR USUÁRIO Pichau
# =========================
try {
    Disable-LocalUser -Name "Pichau" -ErrorAction Stop
    $feito += "Usuario 'Pichau' desativado"
} catch {
    Write-Host "  ERRO ao desativar usuario 'Pichau': $_" -ForegroundColor Red
    exit 1
}

# =========================
# RESUMO
# =========================
Write-Host ""
Write-Host "  ==== RESUMO ====" -ForegroundColor Green
Write-Host ""
foreach ($item in $feito) {
    Write-Host "   [OK] $item" -ForegroundColor Green
}
Write-Host ""
Write-Host "  Configuracao concluida." -ForegroundColor Cyan
Write-Host "  Reinicie a maquina para aplicar o auto-login com o usuario 'aluno'." -ForegroundColor Cyan
Write-Host ""
