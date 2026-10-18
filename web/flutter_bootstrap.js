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
