# Módulos — conquista-cli

Cada arquivo em `/modules` é um script PowerShell independente. Pode ser chamado pelo `cli.ps1` ou diretamente via `irm`.

---

## cli.ps1

**Papel:** Ponto de entrada principal. Oferece menu interativo e execução direta por parâmetro.

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `-Command` | string | `clean`, `wallpaper`, `open` (pergunta a turma) ou `open-<turma>`: `open-1ano`, `open-2ano`, `open-3ano`, `open-4ano`, `open-5ano`, `open-inf4`, `open-inf5`, `open-pesquisa`. Os nomes antigos `open-i1`…`open-i5` continuam aceitos |
| `-Help` | switch | Exibe uso, comandos disponíveis e exemplos |

**Exemplos:**
```powershell
# Menu interativo
irm https://raw.githubusercontent.com/petersonros/irm/main/cli.ps1 | iex

# Direto
irm https://raw.githubusercontent.com/petersonros/irm/main/cli.ps1 -Command clean | iex

# Ajuda
irm https://raw.githubusercontent.com/petersonros/irm/main/cli.ps1 -Help | iex
```

**Opções do menu:** as turmas chamam `open.ps1 -Turma <turma>`, que lê `data/turmas/<turma>.json`. A numeração sai da ordem da lista `$turmas` no topo do `cli.ps1`; para incluir uma turma, crie o JSON e acrescente uma linha nessa lista.

| Opção | Ação |
|---|---|
| 1 | Infantil 4 (`inf4`) |
| 2 | Infantil 5 (`inf5`) |
| 3 | 1º ano (`1ano`) |
| 4 | 2º ano (`2ano`) |
| 5 | 3º ano (`3ano`) |
| 6 | 4º ano (`4ano`) |
| 7 | 5º ano (`5ano`) |
| 8 | Pesquisa de satisfação (`pesquisa`) — sempre o número seguinte à última turma |
| 0 | Executa `clean.ps1` |
| W | Executa `wallpaper.ps1` |
| S | Sair |

**Fecha sozinho:** quando os links de uma turma abrem com sucesso, o `cli.ps1` mostra "Ambiente pronto!" e fecha o PowerShell 2 segundos depois. Se der erro, ou se você voltar com `[V]`, o menu continua. Na pesquisa, abrir um link por vez não fecha; só `[T]` (abrir todos) fecha.

---

## modules/clean.ps1

**Papel:** Fecha navegadores de forma limpa e remove todos os dados de navegação locais.

**O que remove:**

| Dado | Chrome | Edge |
|---|---|---|
| Histórico (`History`) | ✅ | ✅ |
| Cookies (`Cookies`) | ✅ | ✅ |
| Cache (`Cache\*`) | ✅ | ✅ |
| Senhas salvas (`Login Data`) | ✅ | ✅ |
| Journal de senhas (`Login Data-journal`) | ✅ | ✅ |
| Preenchimento automático (`Web Data`) | ✅ | ✅ |
| Sessão atual (`Current Session`, `Current Tabs`) | ✅ | ✅ |
| Última sessão (`Last Session`, `Last Tabs`) | ✅ | ✅ |
| Histórico de sessões (`Sessions\*`) | ✅ | ✅ |

**Comportamento:**
- Encerra `chrome` e `msedge` via `CloseMainWindow()` antes de remover arquivos — fechamento gracioso evita a mensagem "restaurar guias" ao reabrir o navegador; aguarda 2s e força encerramento se necessário
- Usa `Test-Path` antes de cada remoção — só registra no resumo o que de fato existia
- Exibe ao final a lista de itens removidos, ou informa que já estava limpo

**Exemplo de uso direto:**
```powershell
irm https://raw.githubusercontent.com/petersonros/irm/main/modules/clean.ps1 | iex
```

---

## modules/open.ps1

**Papel:** abre os links da aula de uma turma. Os links vêm de `data/turmas/<turma>.json` (formato em [Dados.md](Dados.md)).

**Parâmetros:**

| Parâmetro | Descrição |
|---|---|
| `-Turma` | Identificador da turma (`1ano`, `inf4`, `pesquisa`…). Se faltar, o script pergunta |
| `-Data` | Força a data usada na escolha da aula (`AAAA-MM-DD`). Padrão: hoje |

**Escolha da aula:**
- Uma aula com a data de hoje: mostra qual é; `[Enter]` abre e `[O]` vai para as outras aulas. Abre direto se `-Data` foi informado ou se não há mais nada na turma
- Duas ou mais aulas hoje: pergunta de qual professora abrir (e depois qual aula, se a professora tiver mais de uma)
- Nenhuma aula hoje (ou `[O]`): lista de 10 em 10, com `[M]` mais antigas, `[P]` filtrar por professora, `[S]` sugestões ainda não usadas e `[V]` voltar

**Abertura (campo `modo` da turma):**
- `todos` (padrão): fecha o navegador e abre todos os links ativos numa janela nova, em ordem
- `menu`: submenu com `[1..N]` (abre um link), `[Enter]` (próximo não aberto, marcado com ✓), `[T]` (todos) e `[V]` (voltar)

**Comportamento:**
- Detecta Chrome → Edge → navegador padrão do sistema, nessa ordem
- Links com `"ativo": false` são ignorados
- Erro de rede, turma inexistente ou JSON inválido: mostra a mensagem e volta, sem travar
- Ao abrir os links com sucesso, marca `$global:IRM_AmbientePronto = $true` (o `cli.ps1` usa isso para fechar o PowerShell)
- `$env:IRM_DADOS` aponta para uma pasta local de JSON (para testar antes do push)

**Exemplos de uso direto:**
```powershell
# Com parâmetros (irm | iex não repassa parâmetros, por isso o scriptblock)
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/petersonros/irm/main/modules/open.ps1))) -Turma 1ano

# Sem parâmetros: pergunta a turma
irm https://raw.githubusercontent.com/petersonros/irm/main/modules/open.ps1 | iex
```

---

## modules/setup.ps1

> ⚠️ **DESATIVADO.** Removido do `cli.ps1` e travado no início do script (sai sem alterar nada). Causou perda total de acesso administrativo numa máquina. O conteúdo abaixo descreve o comportamento antigo e fica só como referência.

**Papel:** Configura uma máquina do laboratório do zero — cria os usuários `aluno` e `admin`, migra o auto-login e desativa a conta `Pichau`.

**Requisito:** deve ser executado com privilégios de administrador. O script verifica isso no início e aborta com mensagem clara se não estiver elevado.

**O que faz, em ordem:**

| Fase | Etapa | Ação |
|---|---|---|
| 1 — Criação | 1 | Cria usuário `aluno` sem senha |
| 1 — Criação | 2 | Cria usuário `admin` com a senha fornecida |
| 1 — Criação | 3 | Adiciona `admin` ao grupo `Administradores` |
| 1 — Criação | 4 | Verifica com `Get-LocalUser` que `admin` realmente existe — aborta se não encontrar |
| 1 — Criação | 5 | Ativa o `Administrador` embutido do Windows como fallback de emergência (sem senha) |
| 2 — Perfil | 6 | Baixa o papel de parede da escola para `C:\Users\aluno\AppData\Roaming\wallpaper.jpg` |
| 2 — Perfil | 7 | Carrega o hive `NTUSER.DAT` do `aluno` via `reg load` e aplica papel de parede (`WallpaperStyle=10`, Fill) e oculta ícones do sistema na área de trabalho |
| 2 — Perfil | 8 | Remove ícones de `C:\Users\Public\Desktop\*` |
| 2 — Perfil | 9 | Cria `chrome_default.xml` e aplica via DISM para definir Chrome como padrão para HTTP, HTTPS e PDF |
| 2 — Perfil | 10 | Migra o auto-login do `Pichau` para `aluno` via `HKLM:\…\Winlogon` |
| 3 — Pichau | 11 | Pede confirmação explícita (`S/N`) antes de desativar o `Pichau` |
| 3 — Pichau | 12 | Desativa o usuário `Pichau` (somente se confirmado) |
| — | 13 | Exibe resumo de tudo que foi feito |

**Comportamento:**
- **Ordem segura:** usuários `aluno` e `admin` são criados e verificados *antes* de qualquer etapa de perfil ou desativação do `Pichau` — se a criação falhar, o `Pichau` nunca é desativado
- Após a criação, ativa o `Administrador` embutido do Windows (tenta `"Administrador"` e `"Administrator"`) como saída de emergência independente
- Pede confirmação explícita (`S/N`) antes de desativar o `Pichau`; se recusar, o script finaliza sem desativar
- Usa `-ErrorAction Stop` em operações críticas; aborta com mensagem clara mencionando que o `Pichau` não foi desativado
- Etapas de perfil visual (papel de parede, ícones, Chrome) são não-fatais: exibem aviso amarelo se falharem
- Se o `aluno` nunca tiver feito login (sem `NTUSER.DAT`), copia o hive do perfil `Default` como base antes de carregar
- Informa ao final que é necessário reiniciar para aplicar o auto-login

**Exemplo de uso direto:**
```powershell
irm https://raw.githubusercontent.com/petersonros/irm/main/modules/setup.ps1 | iex
```

---

---

## modules/fix.ps1

> ⚠️ **DESATIVADO.** Removido do `cli.ps1` e travado no início do script (sai sem alterar nada). Causou perda total de acesso administrativo numa máquina. O conteúdo abaixo descreve o comportamento antigo e fica só como referência.

**Papel:** Recupera máquinas que ficaram em estado inconsistente após uma falha do `setup.ps1` — situação típica: `aluno` existe e está no grupo Administradores, mas os demais usuários estão corrompidos ou em estado indefinido.

**Requisito:** deve ser executado com privilégios de administrador. O script verifica isso no início e aborta com mensagem clara se não estiver elevado.

**O que faz, em ordem:**

| Etapa | Ação |
|---|---|
| 1 | Solicita senha para o usuário `admin` via `Read-Host -AsSecureString` |
| 2 | Desativa o auto-login existente — seta `AutoAdminLogon=0` e apaga `DefaultUserName`/`DefaultPassword` em `Winlogon` |
| 3 | Remove a flag de perfil temporário do `aluno` — localiza o SID em `ProfileList` e apaga o valor `State` |
| 4 | Remove usuários problemáticos (`Pichau`, `admin`, `user`) com `-ErrorAction SilentlyContinue` — sem falhar se não existirem |
| 5 | Garante que `aluno` existe e está ativo — cria se não existir, ativa se estiver desativado |
| 6 | Cria o usuário `admin` limpo com a senha informada |
| 7 | Adiciona `admin` ao grupo Administradores |
| 8 | Remove `aluno` do grupo Administradores |
| 9 | Ativa o `Administrador` embutido do Windows como fallback de emergência (sem senha) |
| 10 | Exibe resumo de tudo que foi feito |

**Comportamento:**
- Limpeza do auto-login e do ProfileList são não-fatais: exibem aviso amarelo se falharem
- Se o `aluno` ainda não existir na etapa 3, o ProfileList é ignorado silenciosamente
- Se o valor `State` não existir em `ProfileList\<SID>`, a etapa é ignorada sem erro
- Remoção dos usuários problemáticos é silenciosa — não aborta se o usuário não existir
- Criação de `aluno` e `admin` usa `-ErrorAction Stop` — aborta com mensagem clara em caso de falha
- Remoção de `aluno` do grupo Administradores é não-fatal: exibe aviso amarelo se falhar (ex.: já não era membro)
- Ativação do `Administrador` embutido é não-fatal: tenta `"Administrador"` e `"Administrator"` (fallback para sistemas em inglês)

**Exemplo de uso direto:**
```powershell
irm https://raw.githubusercontent.com/petersonros/irm/main/modules/fix.ps1 | iex
```

---

## modules/wallpaper.ps1

Aplica um papel de parede da coleção em `/wallpapers` ao usuário logado.

**Coleção:** a lista fica no topo do módulo, no formato `"Rótulo | arquivo.png"` (mesmo padrão do `open.ps1`):

```powershell
$wallpapers = @(
    "Colégio Conquista (padrão) | conquista.png"
    "Dia das Crianças          | dia-das-criancas.png"
)
```

**Para adicionar um wallpaper:**
1. Coloque o PNG em `/wallpapers` com nome sem acentos e sem espaços (ex.: `dia-das-criancas.png`)
2. Acrescente (ou descomente) a linha correspondente em `$wallpapers`

**Fluxo:**

| Etapa | Ação |
|---|---|
| 1 | Com um único item cadastrado, aplica direto; com vários, mostra submenu numerado (`[0]` volta) |
| 2 | Baixa a imagem para `C:\Users\Public\Pictures\conquista-<arquivo>.png` |
| 3 | Grava `Wallpaper`, `WallpaperStyle=10` (Preencher) e `TileWallpaper=0` em `HKCU:\Control Panel\Desktop` |
| 4 | Aplica imediatamente via `SystemParametersInfo(SPI_SETDESKWALLPAPER)` |

**Comportamento:**
- Não exige Administrador
- Aplica somente ao usuário que está executando o PowerShell — rode logado como `aluno` para mudar o wallpaper do aluno

**Exemplo de uso direto:**
```powershell
irm https://raw.githubusercontent.com/petersonros/irm/main/modules/wallpaper.ps1 | iex
```

---

## modules.ps1

Arquivo reservado para uso futuro. Pode ser usado para carregar definições compartilhadas entre módulos (funções utilitárias, constantes, etc.).
