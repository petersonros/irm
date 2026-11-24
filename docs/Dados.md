# Dados das aulas — conquista-cli

Os links das aulas ficam em arquivos JSON, um por turma, em `data/turmas/`. Os scripts leem esses arquivos; para preparar uma aula, você só edita o JSON.

## Arquivos

```
data/
├── schema/
│   └── turma.schema.json   # contrato (validação e autocompletar no VS Code)
└── turmas/
    ├── 1ano.json           # 1º ano (salas A, B, C)
    ├── 2ano.json
    ├── 3ano.json
    ├── 4ano.json           # histórico que estava no open.ps1
    ├── 5ano.json           # histórico que estava no open.ps1
    ├── inf4.json           # Infantil 4
    ├── inf5.json           # Infantil 5
    └── pesquisa.json       # Pesquisa de satisfação
```

## Formato (contrato v1)

```json
{
  "$schema": "../schema/turma.schema.json",
  "versao": 1,
  "turma": "1ano",
  "nome": "1º ano",
  "modo": "todos",
  "sugestoes": [
    { "label": "Alfabeto (Wordwall)", "url": "https://...", "sugerido": "2026-11-17", "professora": "Cintia" }
  ],
  "aulas": [
    {
      "data": "2026-11-19",
      "professora": "Cintia",
      "sala": "1º ano A",
      "obs": "opcional",
      "links": [
        { "label": "Gráfico (Wordwall)", "url": "https://wordwall.net/pt/resource/17600787/gr%C3%A1fico" },
        { "label": "Link guardado, mas desligado", "url": "https://...", "ativo": false }
      ]
    }
  ]
}
```

| Campo | Obrigatório | Descrição |
|---|---|---|
| `versao` | sim | Sempre `1`. Só muda se o formato mudar de forma incompatível |
| `turma` | sim | Identificador, igual ao nome do arquivo (`1ano`, `inf4`…) |
| `nome` | sim | Nome exibido no menu |
| `modo` | não | `"todos"` (padrão): abre todos os links de uma vez numa janela nova. `"menu"`: submenu para abrir um por um (usado na pesquisa) |
| `aulas[].data` | sim | `AAAA-MM-DD`, ou `null` para listas antigas sem data |
| `aulas[].professora` | não | |
| `aulas[].sala` | não | Diferencia aulas da mesma turma no mesmo dia (`1º ano A`, `1º ano B`) |
| `aulas[].obs` | não | Anotação livre |
| `aulas[].links[].url` | sim | Começa com `http://` ou `https://` |
| `aulas[].links[].label` | não | Texto do submenu; se faltar, mostra a URL |
| `aulas[].links[].ativo` | não | `false` guarda o link sem abrir. Padrão `true` |
| `sugestoes[]` | não | Links sugeridos e ainda não usados. Mesmo formato dos links de aula |
| `….sugerido` | não | Dia em que a professora sugeriu o link (`AAAA-MM-DD`). Não é a data da aula |
| `….professora` (no link) | não | Quem sugeriu o link |

## Como preparar uma aula

1. Abra `data/turmas/<turma>.json`.
2. Copie a aula do topo e cole logo abaixo de `"aulas": [` (as aulas ficam da mais recente para a mais antiga).
3. Troque `data`, `professora`, `sala` e os `links`.
4. Commit e push. O raw do GitHub pode levar até ~5 min para servir a versão nova.

Aulas antigas não precisam ser apagadas nem comentadas: elas são o histórico.

## Links sugeridos para uso futuro

Os links que a professora sugere, mas que ainda não foram usados, ficam numa lista só, `sugestoes`, no topo do arquivo. Cada link guarda o próprio `sugerido` (data da sugestão) e `professora`.

Para usar numa aula, **recorte** a linha do link de `sugestoes` e cole em `links` da aula. `sugerido` e `professora` podem ir junto: o script os ignora nas aulas.

## Como o script escolhe a aula

Fluxo no lab: você roda o `irm` e escolhe a turma no menu. Em seguida:

| Situação | O que acontece |
|---|---|
| Exatamente **uma** aula com a data de hoje | Mostra a aula e a professora: `[Enter]` abre, `[O]` vai para as outras aulas. Se a turma não tiver mais nada cadastrado, abre direto |
| **Duas ou mais** aulas hoje | Pergunta de **qual professora** abrir (e depois qual aula, se a professora tiver mais de uma) |
| **Nenhuma** aula hoje | Mostra as últimas 10 aulas da turma para escolher |

Na lista de aulas: `[M]` mostra mais 10 antigas, `[P]` filtra por professora e `[S]` abre as sugestões uma a uma. Aulas de qualquer data podem ser abertas de novo, então uma professora que repete os links não precisa de aula nova.

Links com `"ativo": false` nunca são abertos. Para forçar outra data (por exemplo, para testar uma aula preparada para amanhã), use `-Data AAAA-MM-DD` (ver [Modules.md](Modules.md#modulesopenps1)).

## Testar antes do push

Dá para testar o JSON editado numa máquina Windows sem fazer commit, apontando o script para a pasta local:

```powershell
$env:IRM_DADOS = "C:\caminho\para\irm\data\turmas"
& .\modules\open.ps1 -Turma 1ano
```

## Notas de implementação (PowerShell)

- Os scripts rodam via `irm | iex`, então não há pasta local: o JSON é baixado de
  `https://raw.githubusercontent.com/petersonros/irm/main/data/turmas/<turma>.json`
- O raw do GitHub serve `.json` como `text/plain`, então o `Invoke-RestMethod` devolve **texto**; o `open.ps1` converte com `ConvertFrom-Json`.
- Em caso de falha (sem internet, turma inexistente, JSON inválido), o script mostra o erro e volta ao menu.

## Integração futura com o sala-informatica

**Princípio:** o projeto roda só a partir do GitHub, sem banco de dados, servidor ou serviço extra. A integração mantém isso.

**Caminho escolhido (B): a página escreve no repositório.**

```
sala-informatica (página de agendamento)
        │  professora cola os links
        │  commit via API do GitHub (PUT /repos/petersonros/irm/contents/data/turmas/<turma>.json)
        ▼
GitHub: data/turmas/<turma>.json   ← fonte única
        │  irm (raw.githubusercontent.com)
        ▼
Máquinas do lab
```

- O lab continua lendo **só do GitHub**. O `irm` não muda nada quando a integração chegar.
- Cada alteração feita pela página vira um commit, então o histórico continua no git.
- O `sala-informatica` precisa guardar um **token do GitHub** (fine-grained, com permissão *Contents: read and write* **apenas** neste repositório), sempre no servidor e nunca no navegador.
- A página deve ler o JSON atual, inserir a aula no topo de `aulas` e gravar o arquivo inteiro de volta, respeitando o contrato v1. A API do GitHub exige o `sha` atual do arquivo, o que evita sobrescrever uma edição feita ao mesmo tempo.

**Descartado (A): links no banco do sala-informatica servidos por uma API.** Faria o lab depender de outro serviço estar no ar.
