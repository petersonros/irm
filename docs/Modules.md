# Módulos — conquista-cli

Cada arquivo em `/modules` é um script PowerShell independente. Pode ser chamado pelo `cli.ps1` ou diretamente via `irm`.

---

## cli.ps1

**Papel:** Ponto de entrada principal. Oferece menu interativo e execução direta por parâmetro.

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `-Command` | string | Nome do módulo a executar (`clean`, `open`) |

**Exemplos:**
```powershell
# Menu interativo
irm https://raw.githubusercontent.com/petersonros/irm/main/cli.ps1 | iex

# Direto
irm https://raw.githubusercontent.com/petersonros/irm/main/cli.ps1 -Command clean | iex
```

**Opções do menu:**
| Opção | Ação |
|---|---|
| 1 | Executa `clean.ps1` |
| 2 | Executa `open.ps1` |
| 0 | Sair |

---

## modules/clean.ps1

**Papel:** Fecha navegadores abertos e remove dados de navegação locais.

**O que remove:**

| Dado | Chrome | Edge |
|---|---|---|
| Histórico (`History`) | ✅ | ✅ |
| Cookies (`Cookies`) | ✅ | ✅ |
| Cache (`Cache\*`) | ✅ | ✅ |
| Senhas salvas (`Login Data`) | ✅ | ✅ |
| Journal de senhas (`Login Data-journal`) | ✅ | ✅ |
| Preenchimento automático (`Web Data`) | ✅ | ✅ |

**Comportamento:**
- Encerra processos `chrome` e `msedge` antes de remover arquivos (necessário pois os arquivos ficam bloqueados com o navegador aberto)
- Usa `-ErrorAction SilentlyContinue` em todas as remoções — se um arquivo não existir, o script continua sem erro

**Exemplo de uso direto:**
```powershell
irm https://raw.githubusercontent.com/petersonros/irm/main/modules/clean.ps1 | iex
```

---

## modules/open.ps1

**Papel:** Abre o Chrome com um conjunto de URLs em abas separadas na mesma janela.

**Comportamento atual:**
- URLs fixas no código-fonte (ver seção de roadmap para a versão dinâmica)
- Detecta Chrome → Edge → navegador padrão do sistema, nessa ordem
- Abre todas as URLs em uma única janela com `--new-window url1 url2 ...`

**URLs configuradas atualmente:**
```
https://www.digipuzzle.net/pt/jogoseducativos/
https://app.portalsaseducacao.com.br/entrar/
```

**Exemplo de uso direto:**
```powershell
irm https://raw.githubusercontent.com/petersonros/irm/main/modules/open.ps1 | iex
```

**Pendência:** O Chrome abre cada URL como argumento separado na mesma chamada, o que cria abas na mesma janela. Validar comportamento quando o Chrome já está aberto (pode abrir em janela existente em vez de nova janela).

---

## modules.ps1

Arquivo reservado para uso futuro. Pode ser usado para carregar definições compartilhadas entre módulos (funções utilitárias, constantes, etc.).