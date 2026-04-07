# Módulos — conquista-cli

Cada arquivo em `/modules` é um script PowerShell independente. Pode ser chamado pelo `cli.ps1` ou diretamente via `irm`.

---

## cli.ps1

**Papel:** Ponto de entrada principal. Oferece menu interativo e execução direta por parâmetro.

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `-Command` | string | Nome do módulo a executar (`clean`, `open`) |
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
| 1 | Executa `clean.ps1` |
| 2 | Executa `open.ps1` |
| 0 | Sair |

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

## modules.ps1

Arquivo reservado para uso futuro. Pode ser usado para carregar definições compartilhadas entre módulos (funções utilitárias, constantes, etc.).
