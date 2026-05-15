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
Write-Host "  ==== CORRECAO DE USUARIOS ====" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Este script ira:" -ForegroundColor Yellow
Write-Host "   - Desativar o auto-login existente no registro"
Write-Host "   - Remover a flag de perfil temporario do 'aluno' no ProfileList"
Write-Host "   - Remover usuarios problematicos (Pichau, admin, user) se existirem"
Write-Host "   - Garantir que o usuario 'aluno' existe e esta ativo"
Write-Host "   - Criar o usuario 'admin' limpo com a senha informada"
Write-Host "   - Adicionar 'admin' ao grupo Administradores"
Write-Host "   - Remover 'aluno' do grupo Administradores"
Write-Host "   - Ativar o Administrador embutido do Windows como fallback de emergencia"
Write-Host ""

# =========================
# SOLICITAR SENHA DO ADMIN
# =========================
$adminPassword = Read-Host "  Senha para o usuario admin" -AsSecureString
Write-Host ""

$feito = @()

# =========================
# REMOVER AUTO-LOGIN EXISTENTE
# =========================
try {
    $winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon" -Value "0" -ErrorAction Stop
    Remove-ItemProperty -Path $winlogon -Name "DefaultUserName" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $winlogon -Name "DefaultPassword" -ErrorAction SilentlyContinue
    $feito += "Auto-login desativado (AutoAdminLogon=0, DefaultUserName e DefaultPassword removidos)"
} catch {
    Write-Host "  AVISO: nao foi possivel limpar o auto-login no registro: $_" -ForegroundColor Yellow
    $feito += "Remocao do auto-login — falhou (ver aviso acima)"
}

# =========================
# REMOVER FLAG DE PERFIL TEMPORÁRIO DO aluno
# =========================
try {
    $alunoSid = (Get-LocalUser -Name "aluno" -ErrorAction SilentlyContinue).SID.Value
    if ($alunoSid) {
        $profileKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$alunoSid"
        if (Test-Path $profileKey) {
            $state = Get-ItemProperty -Path $profileKey -Name "State" -ErrorAction SilentlyContinue
            if ($state) {
                Remove-ItemProperty -Path $profileKey -Name "State" -ErrorAction Stop
                $feito += "Flag de perfil temporario do 'aluno' removida (State apagado, SID: $alunoSid)"
            } else {
                $feito += "Perfil do 'aluno' no ProfileList ja nao tinha State — ignorado"
            }
        } else {
            $feito += "ProfileList do 'aluno' nao encontrado no registro — ignorado"
        }
    } else {
        $feito += "Usuario 'aluno' nao encontrado para limpeza do ProfileList — ignorado"
    }
} catch {
    Write-Host "  AVISO: nao foi possivel limpar o ProfileList do 'aluno': $_" -ForegroundColor Yellow
    $feito += "Remocao da flag de perfil temporario — falhou (ver aviso acima)"
}

# =========================
# REMOVER USUÁRIOS PROBLEMÁTICOS
# =========================
foreach ($nome in @("Pichau", "admin", "user")) {
    $u = Get-LocalUser -Name $nome -ErrorAction SilentlyContinue
    if ($u) {
        Remove-LocalUser -Name $nome -ErrorAction SilentlyContinue
        $feito += "Usuario '$nome' removido"
    }
}

# =========================
# GARANTIR QUE aluno EXISTE E ESTÁ ATIVO
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
        Enable-LocalUser -Name "aluno" -ErrorAction Stop
        $feito += "Usuario 'aluno' ja existia — ativado"
    }
} catch {
    Write-Host "  ERRO ao garantir usuario 'aluno': $_" -ForegroundColor Red
    Write-Host "  Abortando." -ForegroundColor Yellow
    exit 1
}

# =========================
# CRIAR admin LIMPO
# =========================
try {
    New-LocalUser -Name "admin" `
        -Password $adminPassword `
        -FullName "Administrador" `
        -Description "Conta de administracao do laboratorio" `
        -PasswordNeverExpires `
        -ErrorAction Stop | Out-Null
    $feito += "Usuario 'admin' criado (senha definida)"
} catch {
    Write-Host "  ERRO ao criar usuario 'admin': $_" -ForegroundColor Red
    Write-Host "  Abortando." -ForegroundColor Yellow
    exit 1
}

# =========================
# ADICIONAR admin AO GRUPO ADMINISTRADORES
# =========================
try {
    $adminGroup = Get-LocalGroup | Where-Object { $_.SID -eq 'S-1-5-32-544' } | Select-Object -ExpandProperty Name
    if (-not $adminGroup) { throw "Grupo Administradores (SID S-1-5-32-544) nao encontrado." }
    Add-LocalGroupMember -Group $adminGroup -Member "admin" -ErrorAction Stop
    $feito += "Usuario 'admin' adicionado ao grupo $adminGroup"
} catch {
    if ($_.Exception -is [Microsoft.PowerShell.Commands.MemberExistsException] -or
        $_.Exception.Message -match "already a member|ja e membro|ja membro") {
        $feito += "Usuario 'admin' ja era membro de Administradores — ignorado"
    } else {
        Write-Host "  ERRO ao adicionar 'admin' ao grupo Administradores: $_" -ForegroundColor Red
        Write-Host "  Abortando." -ForegroundColor Yellow
        exit 1
    }
}

# =========================
# REMOVER aluno DO GRUPO ADMINISTRADORES
# =========================
try {
    $adminGroup = Get-LocalGroup | Where-Object { $_.SID -eq 'S-1-5-32-544' } | Select-Object -ExpandProperty Name
    Remove-LocalGroupMember -Group $adminGroup -Member "aluno" -ErrorAction Stop
    $feito += "Usuario 'aluno' removido do grupo $adminGroup"
} catch {
    if ($_.Exception.Message -match "not a member|nao e membro|nao membro") {
        $feito += "Usuario 'aluno' ja nao era membro de Administradores — ignorado"
    } else {
        Write-Host "  AVISO: nao foi possivel remover 'aluno' do grupo Administradores: $_" -ForegroundColor Yellow
        $feito += "Remocao de 'aluno' de Administradores — falhou (ver aviso acima)"
    }
}

# =========================
# ATIVAR ADMINISTRADOR EMBUTIDO (fallback de emergência)
# =========================
try {
    Enable-LocalUser -Name "Administrador" -ErrorAction Stop
    $feito += "Administrador embutido do Windows ativado (fallback de emergencia, sem senha)"
} catch {
    try {
        Enable-LocalUser -Name "Administrator" -ErrorAction Stop
        $feito += "Administrator (built-in) ativado como fallback de emergencia"
    } catch {
        Write-Host "  AVISO: nao foi possivel ativar o Administrador embutido: $_" -ForegroundColor Yellow
        $feito += "Ativacao do Administrador embutido — falhou (ver aviso acima)"
    }
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
Write-Host "  Correcao concluida." -ForegroundColor Cyan
Write-Host "  Reinicie a maquina — a tela de selecao de usuarios deve aparecer." -ForegroundColor Cyan
Write-Host ""
