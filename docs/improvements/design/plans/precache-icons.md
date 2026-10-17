# Correção: as imagens da tela principal aparecem alguns quadros depois do resto

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/precache-icons
- **Nova dependência**: nenhuma (o app não usa SVG, então `flutter_svg` não é necessário; só `precacheImage`, que já vem no Flutter)

## Por quê

O Flutter só carrega e decodifica uma imagem quando um widget pede por ela, então as imagens da tela principal aparecem um ou dois quadros depois do resto da tela. Pré-carregá-las antes do primeiro quadro faz tudo aparecer junto.

## Onde

As imagens de asset que aparecem assim que o app abre:

```dart
// lib/screens/home_page.dart:69 — atual
                  child: Image(
                    image: AssetImage('assets/ai-microphone.png'),
                    width: 150,
                    height: 150,
                  ),
```

```dart
// lib/screens/home_page.dart:144 — atual
                                    : Image.asset(
                                        'assets/speech.png',
                                        width: 40,
                                        height: 40,
                                      ),
```

```dart
// lib/screens/home_page.dart:185 — atual (mesma imagem, segundo estado do card)
                                          : Image.asset(
                                              'assets/speech.png',
                                              width: 40,
                                              height: 40,
                                            ),
```

O app não tem tela de splash em Flutter. A abertura acontece aqui:

```dart
// lib/main.dart:12 — atual
Future main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  runApp(const MyApp());
}
```

e a tela inicial é definida em `lib/main.dart:46`:

```dart
      home: HomePage(),
```

## A correção

O artigo pré-carrega na tela de splash. Como o app não tem uma, o equivalente é segurar o primeiro quadro (a splash nativa continua visível) até as imagens estarem decodificadas:

1. Um helper `precacheAssets` igual ao do artigo, sem a parte de SVG.
2. Um widget `AssetPreloader` que envolve a tela inicial, pré-carrega as imagens em `didChangeDependencies` (onde já existe `context`) e libera o primeiro quadro quando termina.
3. Em `main`, `WidgetsBinding.instance.deferFirstFrame()` antes de `runApp`.

Arquivo novo `lib/components/asset_preloader.dart`, conteúdo exato:

```dart
import 'package:flutter/widgets.dart';

Future<void> precacheAssets({
  required BuildContext context,
  required List<String> paths,
}) async {
  for (final String path in paths) {
    await precacheImage(AssetImage(path), context);
  }
}

/// Segura o primeiro quadro (a splash nativa continua na tela) até as
/// imagens que aparecem na abertura estarem decodificadas.
class AssetPreloader extends StatefulWidget {
  const AssetPreloader({super.key, required this.child});

  final Widget child;

  @override
  State<AssetPreloader> createState() => _AssetPreloaderState();
}

class _AssetPreloaderState extends State<AssetPreloader> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _preload();
  }

  Future<void> _preload() async {
    try {
      // O usuário vê estas imagens assim que o app abre
      await precacheAssets(
        context: context,
        paths: [
          'assets/ai-microphone.png',
          'assets/speech.png',
        ],
      );
    } finally {
      WidgetsBinding.instance.allowFirstFrame();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
```

Alvo em `lib/main.dart`:

```dart
// alvo
Future main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  WidgetsBinding.instance.deferFirstFrame();
  runApp(const MyApp());
}
```

```dart
// alvo
      home: AssetPreloader(child: HomePage()),
```

## Passos

1. Crie `lib/components/asset_preloader.dart` com o conteúdo exato acima.
2. Em `lib/main.dart`, adicione `import 'package:gnix_tts/components/asset_preloader.dart';` junto aos imports `package:gnix_tts/...`.
3. Em `lib/main.dart`, dentro de `main()`, adicione a linha `WidgetsBinding.instance.deferFirstFrame();` imediatamente antes de `runApp(const MyApp());`. Se outro plano tiver adicionado linhas antes de `runApp` (ex.: `ErrorWidget.builder = ...`), coloque o `deferFirstFrame()` como a última linha antes de `runApp`.
4. Em `lib/main.dart`, troque `home: HomePage(),` por `home: AssetPreloader(child: HomePage()),`.

## Verificação

- `dart analyze` termina sem **erros**.
- `grep -c "deferFirstFrame" lib/main.dart` → 1
- `grep -c "AssetPreloader(child: HomePage())" lib/main.dart` → 1
- `grep -c "allowFirstFrame" lib/components/asset_preloader.dart` → 1
- `grep -c "precacheImage" lib/components/asset_preloader.dart` → 1

## Não mexer

- `lib/screens/home_page.dart`: os widgets de imagem continuam iguais; o cache é que já estará pronto.
- `assets/` e a seção `assets:` do `pubspec.yaml`.
- Nada de novas dependências (não adicione `flutter_svg`).
- Nada de refatorar, renomear ou limpar código além desta correção.

## PARE se

- Os trechos citados em "Onde" não existirem mais (`home: HomePage(),` e `runApp(const MyApp());` em `lib/main.dart`). Outros planos desta pasta podem ter mudado outras linhas de `main.dart`; isso é normal.
- O app ficar preso na splash nativa ao rodar (sinal de que `allowFirstFrame` não está sendo chamado).
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que o ícone do microfone e o botão de falar agora aparecem junto com o resto da tela, em vez de surgirem um instante depois. Para ver, feche o app por completo e abra de novo: a primeira tela já vem com as imagens.
