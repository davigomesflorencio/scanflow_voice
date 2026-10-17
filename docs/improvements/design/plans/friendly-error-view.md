# Correção: quando um widget falha, o usuário vê uma caixa cinza vazia

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/friendly-error-view
- **Nova dependência**: nenhuma

## Por quê

Quando um widget falha ao ser montado, o Flutter mostra a tela vermelha em debug e uma caixa cinza vazia na versão de produção. O usuário fica sem saber o que aconteceu. Uma tela amigável nas cores do app ("Algo deu errado") resolve. Em debug ela mostra também o erro, e um toque longo copia os detalhes, o que ajuda a investigar problemas na versão de produção.

## Onde

O app não define `ErrorWidget.builder`:

```dart
// lib/main.dart:12 — atual
Future main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  runApp(const MyApp());
}
```

## A correção

O `FriendlyErrorView` do artigo, com os textos em português (como as mensagens do app), registrado com uma linha antes de `runApp`. Ele:

- na versão de produção mostra só "Algo deu errado" nas cores do tema, sem detalhes técnicos;
- em debug mostra também a exceção e o stack trace;
- com um toque longo em qualquer ponto copia os detalhes para a área de transferência (sem botão visível);
- se adapta ao espaço: layout completo quando há espaço, só um selo com ícone em espaços pequenos.

Arquivo novo `lib/components/friendly_error_view.dart`, conteúdo exato:

```dart
import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Substitui a tela vermelha de erro do Flutter, registrada via
/// [ErrorWidget.builder]. Em produção não mostra detalhes técnicos; em debug
/// mostra a exceção e o stack trace. Um toque longo em qualquer ponto copia
/// os detalhes para a área de transferência.
///
/// Se adapta ao espaço do widget que falhou: layout completo quando há
/// espaço, só um selo com ícone em espaços pequenos.
class FriendlyErrorView extends StatefulWidget {
  const FriendlyErrorView({
    super.key,
    required this.details,
  });

  final FlutterErrorDetails details;

  @override
  State<FriendlyErrorView> createState() => _FriendlyErrorViewState();
}

class _FriendlyErrorViewState extends State<FriendlyErrorView> {
  Timer? _timer;
  bool _copied = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    HapticFeedback.mediumImpact();

    await Clipboard.setData(
      ClipboardData(
        text:
            '${widget.details.exceptionAsString()}\n\n${widget.details.stack}',
      ),
    );

    if (!mounted) return;

    setState(() => _copied = true);

    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    // A view pode aparecer em qualquer ponto da árvore, inclusive onde não
    // há Material nem Directionality acima, então ela fornece os seus. O
    // Material transparente também evita os sublinhados amarelos de
    // "missing Material".
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        type: MaterialType.transparency,
        child: Semantics(
          container: true,
          label: 'Algo deu errado. Reiniciar o app deve resolver.',
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: _copy,
              child: LayoutBuilder(
                builder: (context, c) {
                  final bool full =
                      c.maxHeight.isFinite &&
                      c.maxHeight >= 320 &&
                      c.maxWidth.isFinite &&
                      c.maxWidth >= 300;

                  // Só preenche eixos limitados; sem limites (listas,
                  // FittedBox) a view assume o tamanho do conteúdo.
                  return Container(
                    width: c.hasBoundedWidth ? c.maxWidth : null,
                    height: c.hasBoundedHeight ? c.maxHeight : null,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(full ? 0 : 28),
                    ),
                    child: full
                        ? _FullView(
                            details: widget.details,
                            copied: _copied,
                          )
                        : _CompactView(
                            details: widget.details,
                            copied: _copied,
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullView extends StatelessWidget {
  const _FullView({
    required this.details,
    required this.copied,
  });

  final FlutterErrorDetails details;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final Widget header = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Badge(
          size: 104,
          copied: copied,
        ),
        const SizedBox(height: 24),
        Text(
          'Algo deu errado',
          textAlign: TextAlign.center,
          style: tt.titleLarge?.copyWith(
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Reiniciar o app deve resolver.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(
            color: cs.onPrimaryContainer.withValues(alpha: 0.75),
          ),
        ),
      ],
    );

    // Centralizado enquanto o conteúdo cabe, rolável quando não cabe: o
    // sliver força o filho a ter pelo menos a altura da tela, e a coluna
    // centralizada cresce além disso quando o stack trace de debug é longo.
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            // Evita a barra de status e o indicador de início; a view não tem
            // Scaffold nem SafeArea acima (e talvez nem MediaQuery).
            padding: EdgeInsets.fromLTRB(
              32,
              (MediaQuery.maybePaddingOf(context)?.top ?? 0) + 32,
              32,
              (MediaQuery.maybePaddingOf(context)?.bottom ?? 0) + 32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                header,
                if (kDebugMode) ...[
                  const SizedBox(height: 32),
                  _DebugText(
                    '${details.exceptionAsString()}\n\n${details.stack}',
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactView extends StatelessWidget {
  const _CompactView({
    required this.details,
    required this.copied,
  });

  final FlutterErrorDetails details;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Badge(
                size: 48,
                copied: copied,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: 240,
                  child: _DebugText(
                    details.exceptionAsString(),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// O selo troca o "!" por um check por um instante depois do toque longo
/// que copia o erro, então usuários comuns nunca veem nenhuma dica.
class _Badge extends StatelessWidget {
  const _Badge({
    required this.size,
    required this.copied,
  });

  final double size;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: cs.primary,
        // Uma flor suave feita com o StarBorder do SDK, para este arquivo
        // não precisar de pacote de formas.
        shape: const StarBorder(
          points: 12,
          innerRadiusRatio: 0.8,
          pointRounding: 0.7,
          valleyRounding: 0.3,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          copied ? Icons.check_rounded : Icons.priority_high_rounded,
          key: ValueKey<bool>(copied),
          color: cs.onPrimary,
          size: size * 0.4,
        ),
      ),
    );
  }
}

/// Texto da exceção, mostrado só em builds de debug.
class _DebugText extends StatelessWidget {
  const _DebugText(this.text, {this.maxLines, this.textAlign});

  final String text;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: maxLines == null ? TextOverflow.fade : TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'monospace',
        fontFamilyFallback: const ['Menlo', 'Courier'],
        fontSize: 12,
        color: cs.onPrimaryContainer.withValues(alpha: 0.6),
      ),
    );
  }
}
```

Alvo em `lib/main.dart`:

```dart
// alvo
Future main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  ErrorWidget.builder = (details) => FriendlyErrorView(details: details);
  runApp(const MyApp());
}
```

## Passos

1. Crie `lib/components/friendly_error_view.dart` com o conteúdo exato acima.
2. Em `lib/main.dart`, adicione `import 'package:gnix_tts/components/friendly_error_view.dart';` junto aos imports `package:gnix_tts/...`.
3. Em `lib/main.dart`, dentro de `main()`, adicione `ErrorWidget.builder = (details) => FriendlyErrorView(details: details);` antes de `runApp(const MyApp());`. Se outro plano tiver adicionado `WidgetsBinding.instance.deferFirstFrame();` antes de `runApp`, coloque esta linha antes dele.

## Verificação

- `dart analyze` termina sem **erros**.
- `grep -c "ErrorWidget.builder = (details) => FriendlyErrorView(details: details);" lib/main.dart` → 1
- `grep -c "Algo deu errado" lib/components/friendly_error_view.dart` → 2

## Não mexer

- O resto de `main()` (`dotenv.load`, `availableCameras`).
- `lib/screens/home_page.dart` e `lib/controllers/home_controller.dart`.
- Nada de novas dependências.
- Nada de refatorar, renomear ou limpar código além desta correção.

## PARE se

- `main()` em `lib/main.dart` não tiver mais `runApp(const MyApp());`, ou já existir um `ErrorWidget.builder` no projeto.
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que, quando uma parte da tela falha, o app agora mostra "Algo deu errado" nas cores do app em vez de uma caixa cinza, e que um toque longo nessa área copia o erro técnico. Para ver, provoque temporariamente um erro num `build` (ex.: `throw Exception('teste')`) e rode em modo release; depois desfaça o teste.
