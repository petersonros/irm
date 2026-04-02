# Roadmap — conquista-cli

## Estado Atual

- [x] `cli.ps1` com menu interativo e execução por `-Command`
- [x] `clean.ps1` remove histórico, cookies e cache do Chrome e Edge
- [x] `open.ps1` abre Chrome com URLs fixas em abas separadas

## Melhorias Imediatas (próxima iteração)

### clean.ps1
- [ ] Adicionar remoção de senhas salvas (`Login Data`) no Chrome e Edge
- [ ] Adicionar remoção de autofill (`Web Data`) no Chrome e Edge
- [ ] Exibir resumo do que foi removido ao final

### open.ps1
- [ ] Garantir que todas as URLs abram na mesma janela (flag `--new-window url1 url2`)
- [ ] Validar comportamento quando o Chrome já está aberto

### cli.ps1
- [ ] Corrigir opção 3 do menu (hoje não está mapeada para nenhum módulo)
- [ ] Adicionar mensagem de ajuda (`-Help`) listando comandos disponíveis

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
  "data": "2026-04-02",
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