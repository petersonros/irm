# Arquitetura — conquista-cli

## Conceito

Todos os scripts vivem em um repositório público no GitHub. Qualquer máquina executa um único comando no PowerShell para baixar e rodar o script desejado, sem instalação ou configuração local.

```
Máquina do laboratório
        │
        │  irm <url> | iex
        ▼
   cli.ps1  (ponto de entrada)
        │
        ├── modules/clean.ps1   (limpeza de navegadores)
        └── modules/open.ps1    (abertura de URLs no Chrome)
```

## Fluxo de Execução

### Modo interativo
1. Usuário roda `irm .../cli.ps1 | iex`
2. `cli.ps1` exibe menu numerado
3. Usuário escolhe uma opção
4. `cli.ps1` chama `irm <url-do-módulo> | iex` para o módulo correspondente
5. O módulo executa e retorna ao menu

### Modo direto
1. Usuário roda com parâmetro: `... -Command clean`
2. `cli.ps1` resolve o nome para a URL do módulo
3. Executa o módulo e encerra

## Convenções

- **Módulos são independentes** — cada `.ps1` em `/modules` pode ser invocado diretamente via `irm` sem passar pelo `cli.ps1`
- **Sem estado local** — nenhum arquivo de configuração é criado nas máquinas
- **URLs RAW do GitHub** — todos os scripts são servidos pelo raw.githubusercontent.com

## Limitações Atuais

- URLs abertas pelo `open.ps1` são fixas no código-fonte
- Não há autenticação ou controle de quem executa os scripts
- Requer que o Chrome esteja instalado como `chrome.exe` no PATH ou em localização padrão

## Integração Futura com sala-informatica

O sistema de agendamento (`sala-informatica`) poderá expor um endpoint público retornando as URLs do dia em JSON. O `open.ps1` consultaria esse endpoint antes de abrir o navegador, eliminando a necessidade de editar o script manualmente.

Formato esperado do JSON:

```json
{
  "urls": [
    "https://app.portalsaseducacao.com.br/entrar/",
    "https://www.digipuzzle.net/pt/jogoseducativos/"
  ]
}
```

Endpoint sugerido (a implementar no sala-informatica):
```
GET /api/lab/urls-do-dia
```