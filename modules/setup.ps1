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
Write-Host "   - Criar o usuario 'admin' com a senha informada e adicionar ao grupo Administradores"
Write-Host "   - Verificar que ambos foram criados antes de continuar"
Write-Host "   - Ativar o Administrador embutido do Windows como fallback de emergencia"
Write-Host "   - Configurar papel de parede, area de trabalho e Chrome padrao para 'aluno'"
Write-Host "   - Migrar o auto-login do Pichau para 'aluno'"
Write-Host "   - Desativar o usuario 'Pichau' (somente apos confirmacao)"
Write-Host ""

# =========================
# SOLICITAR SENHA DO ADMIN
# =========================
$adminPassword = Read-Host "  Senha para o novo usuario admin" -AsSecureString
Write-Host ""

$feito = @()

# ============================================================
# FASE 1 — CRIAÇÃO DE USUÁRIOS (crítica, tudo antes de desativar Pichau)
# ============================================================

# 1. CRIAR USUÁRIO aluno
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
    Write-Host "  Abortando. Usuario 'Pichau' NAO foi desativado." -ForegroundColor Yellow
    exit 1
}

# 2. CRIAR USUÁRIO admin
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
    Write-Host "  Abortando. Usuario 'Pichau' NAO foi desativado." -ForegroundColor Yellow
    exit 1
}

# 3. ADICIONAR admin AO GRUPO ADMINISTRADORES
try {
    $adminGroup = Get-LocalGroup | Where-Object { $_.SID -eq 'S-1-5-32-544' } | Select-Object -ExpandProperty Name
    if (-not $adminGroup) { throw "Grupo Administradores (SID S-1-5-32-544) nao encontrado." }
    Add-LocalGroupMember -Group $adminGroup -Member "admin" -ErrorAction Stop
    $feito += "Usuario 'admin' adicionado ao grupo $adminGroup"
} catch {
    if ($_.Exception -is [Microsoft.PowerShell.Commands.MemberExistsException] -or
        $_.Exception.Message -match "already a member|ja e membro|ja membro") {
        $feito += "Usuario 'admin' ja era membro de $adminGroup — ignorado"
    } else {
        Write-Host "  ERRO ao adicionar 'admin' ao grupo Administradores: $_" -ForegroundColor Red
        Write-Host "  Abortando. Usuario 'Pichau' NAO foi desativado." -ForegroundColor Yellow
        exit 1
    }
}

# 4. VERIFICAR QUE admin REALMENTE EXISTE
$adminVerify = Get-LocalUser -Name "admin" -ErrorAction SilentlyContinue
if (-not $adminVerify) {
    Write-Host ""
    Write-Host "  ERRO: usuario 'admin' nao foi encontrado apos a criacao." -ForegroundColor Red
    Write-Host "  Abortando. Usuario 'Pichau' NAO foi desativado." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# 5. ATIVAR ADMINISTRADOR EMBUTIDO (fallback de emergencia)
try {
    Enable-LocalUser -Name "Administrador" -ErrorAction Stop
    $feito += "Administrador embutido do Windows ativado (fallback de emergencia, sem senha)"
} catch {
    # Tenta pelo nome ingles caso o sistema esteja em outro idioma
    try {
        Enable-LocalUser -Name "Administrator" -ErrorAction Stop
        $feito += "Administrator (built-in) ativado como fallback de emergencia"
    } catch {
        Write-Host "  AVISO: nao foi possivel ativar o Administrador embutido: $_" -ForegroundColor Yellow
        $feito += "Ativacao do Administrador embutido — falhou (ver aviso acima)"
    }
}

# ============================================================
# FASE 2 — CONFIGURAÇÃO DO PERFIL (nao-fatal)
# ============================================================

$alunoProfile = "C:\Users\aluno"
$alunoNtuser  = "$alunoProfile\NTUSER.DAT"
$hiveKey      = "HKU\aluno_hive"
$hivePsPath   = "Registry::HKEY_USERS\aluno_hive"

function Load-AlunoHive {
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

# 6. PAPEL DE PAREDE
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

# 7. CONFIGURAR PERFIL VIA HIVE (papel de parede + icones)
$hiveLoaded = $false
try {
    Load-AlunoHive
    $hiveLoaded = $true
} catch {
    Write-Host "  AVISO: nao foi possivel carregar o hive do perfil 'aluno': $_" -ForegroundColor Yellow
}

if ($hiveLoaded) {
    try {
        $desktopKey = "$hivePsPath\Control Panel\Desktop"
        if (-not (Test-Path $desktopKey)) {
            New-Item -Path $desktopKey -Force -ErrorAction Stop | Out-Null
        }
        if ($wallpaperPath) {
            Set-ItemProperty -Path $desktopKey -Name "Wallpaper"      -Value $wallpaperPath -ErrorAction Stop
        }
        Set-ItemProperty -Path $desktopKey -Name "WallpaperStyle" -Value "10" -ErrorAction Stop
        Set-ItemProperty -Path $desktopKey -Name "TileWallpaper"  -Value "0"  -ErrorAction Stop
        $feito += "Papel de parede aplicado no registro do perfil 'aluno' (estilo: Fill)"
    } catch {
        Write-Host "  AVISO: erro ao aplicar papel de parede no registro: $_" -ForegroundColor Yellow
        $feito += "Aplicacao do papel de parede no registro — falhou (ver aviso acima)"
    }

    try {
        $hideKey = "$hivePsPath\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
        if (-not (Test-Path $hideKey)) {
            New-Item -Path $hideKey -Force -ErrorAction Stop | Out-Null
        }
        Set-ItemProperty -Path $hideKey -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 1 -Type DWord -ErrorAction Stop
        Set-ItemProperty -Path $hideKey -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 1 -Type DWord -ErrorAction Stop
        Set-ItemProperty -Path $hideKey -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Value 1 -Type DWord -ErrorAction Stop
        Set-ItemProperty -Path $hideKey -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Value 1 -Type DWord -ErrorAction Stop
        $feito += "Icones do sistema ocultados na area de trabalho do 'aluno'"
    } catch {
        Write-Host "  AVISO: erro ao ocultar icones do sistema: $_" -ForegroundColor Yellow
        $feito += "Ocultacao de icones do sistema — falhou (ver aviso acima)"
    }

    Unload-AlunoHive
}

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

# 8. CHROME COMO NAVEGADOR PADRÃO
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

    $dism = dism /Online "/Import-DefaultAppAssociations:$xmlPath" 2>&1
    if ($LASTEXITCODE -ne 0) { throw "DISM saiu com codigo $LASTEXITCODE: $dism" }

    Remove-Item $xmlPath -ErrorAction SilentlyContinue
    $feito += "Chrome definido como navegador padrao para HTTP, HTTPS e PDF (via DISM)"
} catch {
    Write-Host "  AVISO: nao foi possivel definir Chrome como padrao: $_" -ForegroundColor Yellow
    $feito += "Chrome como padrao — falhou (ver aviso acima)"
}

# 9. MIGRAR AUTO-LOGIN para aluno
try {
    $winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"     -ErrorAction Stop
    Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "aluno" -ErrorAction Stop
    Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value ""      -ErrorAction Stop
    Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "."     -ErrorAction Stop
    $feito += "Auto-login migrado do Pichau para 'aluno'"
} catch {
    Write-Host "  ERRO ao configurar auto-login no registro: $_" -ForegroundColor Red
    Write-Host "  Abortando. Usuario 'Pichau' NAO foi desativado." -ForegroundColor Yellow
    exit 1
}

# ============================================================
# FASE 3 — DESATIVAR PICHAU (somente após confirmação)
# ============================================================

Write-Host ""
Write-Host "  -----------------------------------------------" -ForegroundColor Cyan
Write-Host "  Usuarios 'aluno' e 'admin' criados com sucesso." -ForegroundColor Green
Write-Host "  Administrador embutido ativado como fallback." -ForegroundColor Green
Write-Host "  -----------------------------------------------" -ForegroundColor Cyan
Write-Host ""
$confirmacao = Read-Host "  Desativar o usuario 'Pichau' agora? (S/N)"

if ($confirmacao -match "^[Ss]$") {
    try {
        Disable-LocalUser -Name "Pichau" -ErrorAction Stop
        $feito += "Usuario 'Pichau' desativado"
    } catch {
        Write-Host "  ERRO ao desativar usuario 'Pichau': $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "  Desativacao do 'Pichau' cancelada pelo usuario." -ForegroundColor Yellow
    $feito += "Usuario 'Pichau' — desativacao cancelada pelo usuario"
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
