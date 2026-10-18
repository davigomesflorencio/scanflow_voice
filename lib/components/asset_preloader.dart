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
