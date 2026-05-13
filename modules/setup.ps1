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
Write-Host "   - Criar o usuario 'aluno' (sem senha, perfil temporario)"
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
# 2. MIGRAR AUTO-LOGIN para aluno
# =========================
try {
    $winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"  -Value "1"    -ErrorAction Stop
    Set-ItemProperty -Path $winlogon -Name "DefaultUserName" -Value "aluno" -ErrorAction Stop
    Set-ItemProperty -Path $winlogon -Name "DefaultPassword" -Value ""      -ErrorAction Stop
    Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "."  -ErrorAction Stop
    $feito += "Auto-login migrado do Pichau para 'aluno'"
} catch {
    Write-Host "  ERRO ao configurar auto-login no registro: $_" -ForegroundColor Red
    exit 1
}

# =========================
# 3. PERFIL TEMPORÁRIO para aluno
# =========================
try {
    $alunoSid = (Get-LocalUser -Name "aluno" -ErrorAction Stop).SID.Value
    $profileListPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$alunoSid"

    if (-not (Test-Path $profileListPath)) {
        New-Item -Path $profileListPath -Force -ErrorAction Stop | Out-Null
    }

    # State 0x08 — perfil temporario: dados descartados ao encerrar sessao
    Set-ItemProperty -Path $profileListPath -Name "State" -Value 8 -Type DWord -ErrorAction Stop
    $feito += "Perfil temporario configurado para 'aluno' (ProfileList State=0x08)"
} catch {
    Write-Host "  AVISO: nao foi possivel configurar perfil temporario para 'aluno': $_" -ForegroundColor Yellow
    $feito += "Perfil temporario para 'aluno' — falhou (ver aviso acima)"
}

# =========================
# 4. CRIAR USUÁRIO admin
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
# 5. ADICIONAR admin AO GRUPO ADMINISTRADORES
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
# 6. DESATIVAR USUÁRIO Pichau
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
