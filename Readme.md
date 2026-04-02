# conquista-cli

Scripts PowerShell distribuídos via `irm | iex` para gerenciamento de laboratório de informática escolar.

## Visão Geral

O projeto permite que qualquer máquina do laboratório execute ações de manutenção ou prepare o ambiente de aula com um único comando no PowerShell, sem instalação prévia.

## Uso Rápido

```powershell
# Modo interativo (menu)
irm https://raw.githubusercontent.com/petersonros/irm/main/cli.ps1 | iex

# Execução direta
irm https://raw.githubusercontent.com/petersonros/irm/main/cli.ps1 -Command clean | iex
irm https://raw.githubusercontent.com/petersonros/irm/main/cli.ps1 -Command open  | iex
```

## Estrutura do Repositório

```
/
├── cli.ps1              # Ponto de entrada — menu interativo + execução direta
└── modules/
    ├── clean.ps1        # Limpa dados dos navegadores (histórico, cookies, senhas)
    └── open.ps1         # Abre Chrome com URLs pré-definidas em abas separadas
```

## Documentação

| Documento | Descrição |
|---|---|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Como os scripts se relacionam e o fluxo de execução |
| [MODULES.md](docs/MODULES.md) | Referência detalhada de cada módulo |
| [ROADMAP.md](docs/ROADMAP.md) | Funcionalidades planejadas e visão futura |

## Contexto

Desenvolvido para o laboratório de informática da escola Conquista. Complementa o sistema `sala-informatica` (Next.js) de agendamento de aulas.