# Roadmap — conquista-cli

## Estado Atual

- [x] `cli.ps1` com menu interativo (opções 1, 2, 0), execução por `-Command` e flag `-Help`
- [x] `clean.ps1` remove histórico, cookies, cache, senhas, autofill e sessões do Chrome e Edge
- [x] `clean.ps1` fecha o navegador de forma limpa antes de remover os arquivos
- [x] `clean.ps1` exibe resumo do que foi removido ao final
- [x] `open.ps1` detecta Chrome → Edge → navegador padrão, nessa ordem
- [x] `open.ps1` encerra o navegador se já estiver aberto antes de usar `--new-window`
- [x] `setup.ps1` cria usuários `aluno` (sem senha, perfil temporário) e `admin`, migra auto-login do Pichau e desativa a conta — **desativado** (ver `Modules.md`)
- [x] `fix.ps1` recupera máquinas em estado inconsistente: remove usuários corrompidos, recria `admin`, remove `aluno` do grupo Administradores e reaplica auto-login — **desativado** (ver `Modules.md`)

## Pendências

### Links das aulas em JSON
- [x] Etapa 1 — contrato v1 definido (`data/schema/turma.schema.json`) e documentado (`docs/Dados.md`)
- [x] Etapa 2 — 177 links migrados dos `.ps1` para `data/turmas/*.json`, com histórico
- [x] Etapa 3 — `open.ps1` único que recebe a turma, baixa o JSON e escolhe a aula pela data de hoje (campo opcional `modo` adicionado ao contrato)
- [x] Etapa 4 — `cli.ps1` chamando o módulo único por turma (novas opções [7] 4º ano e [8] 5º ano)
- [ ] Etapa 5 — remover `open-inf*.ps1` e atualizar a documentação

> Desde a etapa 4, links novos vão só nos `data/turmas/*.json`. Os `open-inf*.ps1` ficam no repositório até a etapa 5 apenas como reserva para voltar atrás.

---

## Visão Futura

### Links das aulas pelo sala-informatica

**Objetivo:** a professora cola os links no agendamento da aula, e o lab passa a abri-los sem ninguém editar arquivo à mão, mantendo o projeto 100% no GitHub.

**Como funcionaria:**
1. A página de agendamento tem um campo de links
2. Ao salvar, o `sala-informatica` faz commit no `data/turmas/<turma>.json` via API do GitHub (contrato v1, ver [Dados.md](Dados.md))
3. As máquinas do lab continuam lendo o JSON pelo raw do GitHub, sem nenhuma mudança no `irm`

**Dependências:**
- Etapas 3–5 da pendência "Links das aulas em JSON" concluídas
- Token fine-grained do GitHub (*Contents: read and write* só neste repositório), guardado no servidor do `sala-informatica`

---

## Ideias para Versões Futuras

- **Perfis de aula:** Diferentes conjuntos de URLs para diferentes turmas ou disciplinas
- **Log de execução:** Registrar quando e em qual máquina o script foi executado (útil para auditoria)
- **Agendamento automático:** Tarefa agendada no Windows que roda o `clean.ps1` ao desligar

---

## Changelog

### 2026-05-15
**fix(users): módulo de correção para máquinas em estado inconsistente**

**Incidente:** após falha parcial do `setup.ps1` em algumas máquinas, o usuário `aluno` ficou ativo e temporariamente no grupo Administradores enquanto usuários como `Pichau`, `admin` e `user` permaneceram em estado indefinido. Apenas o `aluno` conseguia fazer login com sucesso, mas com privilégios indevidos.

**Solução implementada:**
- `fix.ps1`: remove silenciosamente usuários problemáticos (`Pichau`, `admin`, `user`)
- `fix.ps1`: garante que `aluno` existe e está ativo
- `fix.ps1`: cria `admin` limpo com senha fornecida pelo operador
- `fix.ps1`: adiciona `admin` ao grupo Administradores e remove `aluno` desse grupo
- `fix.ps1`: reaplica auto-login para `aluno` via registro Winlogon
- `fix.ps1`: ativa o Administrador embutido do Windows como fallback de emergência
- `cli.ps1`: adicionada opção `[8] Corrigir usuários` no menu e comando `fix` no modo direto

### 2026-05-13
**feat(setup): módulo de configuração inicial de máquina**
- `setup.ps1`: cria usuário `aluno` (sem senha, perfil temporário via ProfileList)
- `setup.ps1`: migra auto-login do Pichau para `aluno` via registro Winlogon
- `setup.ps1`: cria usuário `admin` com senha segura e adiciona ao grupo Administradores
- `setup.ps1`: desativa o usuário Pichau ao final
- `cli.ps1`: adicionada opção `[7] Configurar máquina` no menu e comando `setup` no modo direto

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
