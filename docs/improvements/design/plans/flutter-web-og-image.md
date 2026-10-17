# Correção: o link da versão web aparece sem pré-visualização quando compartilhado

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/flutter-web-og-image
- **Nova dependência**: nenhuma

## Por quê

Compartilhado no WhatsApp, Slack ou X, o link da versão web do ScanFlow Voice aparece só como um endereço, porque `web/index.html` não tem as meta tags Open Graph. Com elas, o link vira um card com título, descrição e imagem.

## Antes de começar: dados que só o desenvolvedor tem

As meta tags exigem **URLs absolutas**, e o projeto ainda não tem um endereço web publicado. Antes de editar, peça ao desenvolvedor:

1. **URL pública do site** (ex.: `https://scanflow.exemplo.com`). Chamada abaixo de `<URL_DO_SITE>`.
2. **Uma imagem de 1200×630 px** para o card. Ela deve ser salva como `web/og-image.png`, e a URL dela será `<URL_DO_SITE>/og-image.png`.

Se o desenvolvedor não tiver esses dois itens, **pare** (veja "PARE se").

## Onde

```html
<!-- web/index.html:19 — atual -->
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="A new Flutter project.">
```

Nenhuma tag `og:` ou `twitter:` existe no arquivo.

## A correção

Adicionar ao `<head>` as tags Open Graph e as do X, logo depois de `<meta name="description" ...>`. Textos (em português, como as mensagens do app):

- Título: `ScanFlow Voice – Texto e fotos em voz`
- Descrição: `Digite um texto ou fotografe uma página e ouça em voz natural, com reconhecimento de texto no aparelho e vozes da ElevenLabs.`

```html
  <!-- Open Graph -->
  <meta property="og:title" content="ScanFlow Voice – Texto e fotos em voz">
  <meta property="og:description" content="Digite um texto ou fotografe uma página e ouça em voz natural, com reconhecimento de texto no aparelho e vozes da ElevenLabs.">
  <meta property="og:image" content="<URL_DO_SITE>/og-image.png">
  <meta property="og:url" content="<URL_DO_SITE>">
  <meta property="og:type" content="website">

  <!-- X / Twitter -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="ScanFlow Voice – Texto e fotos em voz">
  <meta name="twitter:description" content="Digite um texto ou fotografe uma página e ouça em voz natural, com reconhecimento de texto no aparelho e vozes da ElevenLabs.">
  <meta name="twitter:image" content="<URL_DO_SITE>/og-image.png">
```

Regras do artigo que não podem ser quebradas:

- `og:image` precisa ser URL **absoluta**; caminho relativo como `og-image.png` é ignorado.
- A imagem precisa ter **1200×630**; fora dessa proporção ela é cortada ou descartada.
- `twitter:image` precisa estar presente também; o X lê as próprias tags primeiro.

## Passos

1. Peça ao desenvolvedor a URL do site e a imagem 1200×630 (veja "Antes de começar").
2. Salve a imagem como `web/og-image.png`.
3. Em `web/index.html`, logo depois da linha `<meta name="description" content="A new Flutter project.">`, cole o bloco acima trocando as três ocorrências de `<URL_DO_SITE>` pela URL real (sem barra no final).

## Verificação

- `flutter build web` termina com sucesso.
- `grep -c 'property="og:' web/index.html` → 5
- `grep -c 'name="twitter:' web/index.html` → 4
- `grep -c "<URL_DO_SITE>" web/index.html` → 0
- `grep -c 'content="https://' web/index.html` → 3 (as duas imagens e o `og:url` são absolutos)

## Não mexer

- `<meta name="description">`, `<title>`, favicon e o `<body>` de `web/index.html`. Outro plano desta pasta cuida do `<body>`.
- `web/manifest.json` e `web/icons/`.
- Código Dart.
- Nada de novas dependências.

## PARE se

- O desenvolvedor não tiver uma URL pública ou a imagem 1200×630: não invente valores nem use caminhos relativos.
- `web/index.html` já tiver alguma tag `og:` ou `twitter:`.
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que o link da versão web agora gera um card com título, descrição e imagem quando é compartilhado. Para ver, publique o site e cole a URL no validador de cards do LinkedIn (Post Inspector) ou numa conversa do WhatsApp.
