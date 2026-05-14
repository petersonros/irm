# Módulos — conquista-cli

Cada arquivo em `/modules` é um script PowerShell independente. Pode ser chamado pelo `cli.ps1` ou diretamente via `irm`.

---

## cli.ps1

**Papel:** Ponto de entrada principal. Oferece menu interativo e execução direta por parâmetro.

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `-Command` | string | Nome do módulo a executar (`clean`, `open`, `open-i1`…`open-i5`, `setup`) |
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

**Opções do menu:**
| Opção | Ação |
|---|---|
| 1 | Executa `open-inf1.ps1` |
| 2 | Executa `open-inf2.ps1` |
| 3 | Executa `open-inf3.ps1` |
| 4 | Executa `open-inf4.ps1` |
| 5 | Executa `open-inf5.ps1` |
| 6 | Executa `open.ps1` |
| 0 | Executa `clean.ps1` |
| 7 | Executa `setup.ps1` |
| 9 | Sair |

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

**Papel:** Abre o Chrome com um conjunto de URLs em abas separadas na mesma janela.

**Comportamento:**
- Detecta Chrome → Edge → navegador padrão do sistema, nessa ordem
- Se o navegador já estiver aberto, encerra o processo antes de abrir (garante `--new-window` limpo)
- Abre todas as URLs em uma única janela com `--new-window url1 url2 ...`
- URLs fixas no código-fonte (ver roadmap para a versão dinâmica via API)

**URLs configuradas atualmente:**
```
https://app.portalsaseducacao.com.br/entrar/
https://www.digipuzzle.net/pt/jogoseducativos/
```

**Exemplo de uso direto:**
```powershell
irm https://raw.githubusercontent.com/petersonros/irm/main/modules/open.ps1 | iex
```

---

## modules/setup.ps1

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

## modules.ps1

Arquivo reservado para uso futuro. Pode ser usado para carregar definições compartilhadas entre módulos (funções utilitárias, constantes, etc.).
