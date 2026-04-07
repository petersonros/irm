# Roadmap — conquista-cli

## Estado Atual

- [x] `cli.ps1` com menu interativo (opções 1, 2, 0) e execução por `-Command`
- [x] `clean.ps1` remove histórico, cookies, cache, senhas e autofill do Chrome e Edge
- [x] `open.ps1` abre Chrome com URLs fixas em abas na mesma janela (`--new-window`)
- [x] `open.ps1` detecta Chrome → Edge → navegador padrão, nessa ordem

## Pendências (próxima iteração)

### clean.ps1
- [x] Exibir resumo do que foi removido ao final (quais arquivos existiam e foram deletados)

### open.ps1
- [x] Validar comportamento quando o Chrome já está aberto — encerra o processo antes de abrir para garantir `--new-window` limpo

### cli.ps1
- [x] Adicionar flag `-Help` listando comandos disponíveis

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
