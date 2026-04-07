# Roadmap — conquista-cli

## Estado Atual

- [x] `cli.ps1` com menu interativo (opções 1, 2, 0), execução por `-Command` e flag `-Help`
- [x] `clean.ps1` remove histórico, cookies, cache, senhas, autofill e sessões do Chrome e Edge
- [x] `clean.ps1` fecha o navegador de forma limpa antes de remover os arquivos
- [x] `clean.ps1` exibe resumo do que foi removido ao final
- [x] `open.ps1` detecta Chrome → Edge → navegador padrão, nessa ordem
- [x] `open.ps1` encerra o navegador se já estiver aberto antes de usar `--new-window`

## Pendências

Sem pendências no momento.

---

## Visão Futura

### URLs Dinâmicas via sala-informatica

**Objetivo:** A professora cola a URL no agendamento da aula. Quando o script roda no laboratório, ele busca automaticamente a URL do dia — sem necessidade de editar código.

**Como funcionaria:**
1. No `sala-informatica`, ao criar ou aprovar um agendamento, o campo "URL da aula" é salvo no banco de dados
2. Uma rota pública da API (`/api/lab/urls-do-dia`) retorna as URLs dos agendamentos aprovados para o dia atual
3. O `open.ps1` faz `Invoke-RestMethod` nessa URL antes de abrir o Chrome

**Exemplo de implementação no open.ps1:**
```powershell
$apiUrl = "https://sala-informatica.vercel.app/api/lab/urls-do-dia"

try {
    $data = Invoke-RestMethod -Uri $apiUrl
    $urls = $data.urls
} catch {
    # Fallback para URLs fixas se a API estiver indisponível
    $urls = @(
        "https://app.portalsaseducacao.com.br/entrar/",
        "https://www.digipuzzle.net/pt/jogoseducativos/"
    )
}
```

**Dependências:**
- Implementar endpoint `GET /api/lab/urls-do-dia` no `sala-informatica`
- Adicionar campo `url_aula` no model `Agendamento` (Prisma)
- A rota deve ser pública (sem autenticação) pois as máquinas do lab não têm sessão

**Formato do JSON esperado:**
```json
{
  "data": "2026-04-07",
  "urls": [
    "https://app.portalsaseducacao.com.br/entrar/",
    "https://www.digipuzzle.net/pt/jogoseducativos/"
  ]
}
```

---

## Ideias para Versões Futuras

- **Perfis de aula:** Diferentes conjuntos de URLs para diferentes turmas ou disciplinas
- **Log de execução:** Registrar quando e em qual máquina o script foi executado (útil para auditoria)
- **Módulo de setup:** Configurar uma máquina nova do zero (instalar Chrome, definir página inicial, etc.)
- **Agendamento automático:** Tarefa agendada no Windows que roda o `clean.ps1` ao desligar

---

## Changelog

### 2026-04-07 — `d261edc`
**fix(clean): fechamento gracioso do navegador e remoção de sessões**
- `Close-Browser` agora usa `CloseMainWindow()` + aguarda 2s antes de forçar encerramento, eliminando a mensagem "restaurar guias" ao reabrir o navegador
- Adicionados à limpeza: `Current Session`, `Current Tabs`, `Last Session`, `Last Tabs` e `Sessions\*` para Chrome e Edge — apaga o histórico de guias recentes

### 2026-04-07 — `086b3c8`
**feat: lapidação inicial**
- `clean.ps1`: exibe resumo ao final listando cada item removido (ou informa que já estava limpo)
- `open.ps1`: detecta se o navegador está aberto e encerra antes de usar `--new-window`, garantindo janela nova e limpa
- `cli.ps1`: corrigido menu (removida opção 3 inexistente); adicionada flag `-Help` com uso, comandos e exemplos; sugestão de `-Help` em comando inválido
- Roadmap atualizado refletindo o estado real do projeto

### 2026-04-02 — `f9a11a9`
**feat(clean): adiciona remoção de senhas e autofill**
- `clean.ps1`: passa a remover `Login Data`, `Login Data-journal` e `Web Data` no Chrome e Edge

### 2026-04-02 — `c4d8133`
**docs: adiciona Readme principal**
- Criado `Readme.md` com instruções de uso e visão geral do projeto

### 2026-04-02 — `1e593c5`
**feat: estrutura inicial**
- `cli.ps1` com menu interativo e suporte a `-Command`
- `modules/clean.ps1` com remoção de histórico, cookies e cache do Chrome e Edge
- `modules/open.ps1` com abertura de URLs fixas no Chrome
- Documentação inicial: `Architecture.md`, `Modules.md`, `Roadmap.md`
