# Correção: a versão web mostra uma página branca enquanto carrega

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/flutter-web-loading-progress
- **Nova dependência**: nenhuma

## Por quê

O Flutter web precisa baixar `main.dart.js`, o runtime, as fontes e os assets antes de desenhar qualquer coisa, e até lá o usuário vê uma página branca e acha que o site quebrou. Uma barra de progresso no HTML aparece na hora e some sozinha quando o Flutter assume a página.

## Onde

```html
<!-- web/index.html:29 — atual -->
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <title>gnix_tts</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
```

Hoje não existem `web/style.css` nem `web/flutter_bootstrap.js` (o Flutter gera o bootstrap automaticamente quando ele não existe).

## A correção

1. Markup da barra dentro do `<body>`, antes do script.
2. `web/style.css` com o estilo da barra, linkado no `<head>`. A cor da barra é o turquesa do app (`#33CCCC`, que é `Color.fromARGB(255, 51, 204, 204)`).
3. Um `web/flutter_bootstrap.js` próprio, que o Flutter passa a usar no lugar do gerado, avançando a barra em cada etapa real do carregamento.

Alvo de `web/index.html` (só as partes que mudam):

```html
  <title>gnix_tts</title>
  <link rel="manifest" href="manifest.json">
  <link rel="stylesheet" href="style.css" />
</head>
<body>
  <div class="progress-container">
    <div class="progress-bar"></div>
  </div>

  <script src="flutter_bootstrap.js" async></script>
</body>
```

Arquivo novo `web/style.css`, conteúdo exato:

```css
body {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  margin: 0;
  background-color: #ffffff;
}

.progress-container {
  width: 120px;
  height: 8px;
  background-color: #FAFAFA;
  border-radius: 10px;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  width: 0;
  background-color: #33CCCC;
  transition: width 0.4s ease;
}
```

Arquivo novo `web/flutter_bootstrap.js`, conteúdo exato (`{{flutter_js}}` e `{{flutter_build_config}}` são marcadores que o `flutter build web` substitui; mantenha-os literalmente):

```js
{{flutter_js}}
{{flutter_build_config}}

const bar = document.querySelector('.progress-bar');
const setProgress = (pct) => { bar.style.width = pct + '%'; };

setProgress(20); // bootstrap rodando

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    setProgress(50); // main.dart.js baixado
    const appRunner = await engineInitializer.initializeEngine();
    setProgress(80); // engine pronta
    await appRunner.runApp();
    // O Flutter assumiu a página, nada mais a fazer
  },
});
```

## Passos

1. Crie `web/style.css` com o conteúdo exato acima.
2. Crie `web/flutter_bootstrap.js` com o conteúdo exato acima.
3. Em `web/index.html`, adicione `<link rel="stylesheet" href="style.css" />` logo depois de `<link rel="manifest" href="manifest.json">`, ainda dentro do `<head>`.
4. Em `web/index.html`, dentro do `<body>` e antes de `<script src="flutter_bootstrap.js" async></script>`, adicione:
   ```html
     <div class="progress-container">
       <div class="progress-bar"></div>
     </div>
   ```

## Verificação

- `flutter build web` termina com sucesso.
- `grep -c 'class="progress-bar"' web/index.html` → 1
- `grep -c 'href="style.css"' web/index.html` → 1
- `grep -c "onEntrypointLoaded" web/flutter_bootstrap.js` → 1
- `grep -c "#33CCCC" web/style.css` → 1

## Não mexer

- O resto do `<head>` de `web/index.html` (base href, meta tags, favicon, título). Outro plano desta pasta cuida das meta tags de compartilhamento.
- `web/manifest.json` e `web/icons/`.
- Código Dart: esta correção é só HTML/CSS/JS.
- Nada de imagens pesadas ou animações no HTML: tudo aqui é baixado junto com a página.
- Nada de novas dependências.

## PARE se

- O `<body>` de `web/index.html` tiver algo além do `<script src="flutter_bootstrap.js" async></script>` (alguém já mexeu nele).
- Já existir um `web/flutter_bootstrap.js` ou `web/style.css`.
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que a versão web agora mostra uma barra de progresso turquesa no centro da tela enquanto carrega, avançando a cada etapa, em vez de uma página branca. Para ver, rode `flutter run -d chrome` e recarregue com o cache desativado.
