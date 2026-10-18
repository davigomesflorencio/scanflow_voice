# Correção: a tela principal rola sem barra de rolagem no celular

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/scrollbars
- **Nova dependência**: nenhuma

## Por quê

Uma barra de rolagem mostra ao usuário onde ele está na tela e quanto falta. No desktop e na web o Flutter adiciona a barra sozinho, mas no celular isso é responsabilidade do app. Adicionar uma barra manual sem cuidado entra em conflito com a automática do desktop, e as duas param de funcionar direito.

## Onde

O app tem um único conteúdo rolável vertical:

```dart
// lib/screens/home_page.dart:63 — atual
          child: SingleChildScrollView(
            child: Column(
```

O `GetMaterialApp` (`lib/main.dart:26`) não define `scrollBehavior`.

## A correção

Como só há um lugar rolável, a abordagem manual do artigo é a indicada: um `MagicalScrollbar`, que adiciona `Scrollbar` só no Android e no iOS e deixa o desktop/web com a barra automática.

Arquivo novo `lib/components/magical_scrollbar.dart`, conteúdo exato:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MagicalScrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;

  const MagicalScrollbar({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = [TargetPlatform.android, TargetPlatform.iOS]
        .contains(defaultTargetPlatform);

    if (isMobile) {
      return Scrollbar(
        controller: controller,
        child: child,
      );
    } else {
      return child;
    }
  }
}
```

Alvo em `home_page.dart` (o `SingleChildScrollView` não tem `controller`, então nenhum é passado):

```dart
// alvo
          child: MagicalScrollbar(
            child: SingleChildScrollView(
              child: Column(
              ...
              ),
            ),
          ),
```

## Passos

1. Crie `lib/components/magical_scrollbar.dart` com o conteúdo exato acima.
2. Em `lib/screens/home_page.dart`, adicione `import 'package:gnix_tts/components/magical_scrollbar.dart';` junto aos imports `package:gnix_tts/...`.
3. Em `lib/screens/home_page.dart`, envolva o `SingleChildScrollView(...)` principal inteiro em `MagicalScrollbar(child: ...)`: troque `SingleChildScrollView(` por `MagicalScrollbar(child: SingleChildScrollView(` e feche com um `)` a mais logo depois do `)` que fecha o `SingleChildScrollView`. Mantenha todos os parâmetros que o `SingleChildScrollView` tiver (outros planos desta pasta podem ter adicionado `padding:` ou `keyboardDismissBehavior:`).
4. Rode `dart format lib/screens/home_page.dart` para reindentar.

## Verificação

- `dart analyze` termina sem **erros**.
- `grep -c "MagicalScrollbar(" lib/screens/home_page.dart` → 1
- `grep -c "defaultTargetPlatform" lib/components/magical_scrollbar.dart` → 1

## Não mexer

- `lib/main.dart`: não adicione `scrollBehavior` global; a abordagem escolhida é a manual.
- Os parâmetros e o conteúdo do `SingleChildScrollView`.
- Nada de novas dependências.
- Nada de refatorar, renomear ou limpar código além desta correção.

## PARE se

- Não houver exatamente um `SingleChildScrollView(` em `lib/screens/home_page.dart`, ou ele já estiver dentro de um `Scrollbar`.
- `GetMaterialApp` em `lib/main.dart` já tiver um `scrollBehavior`.
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que a tela principal agora mostra uma barra de rolagem fina no Android e no iOS enquanto o usuário rola, e que no desktop e na web continua a barra automática do Flutter, sem duplicar. Para ver, cole um texto longo no campo e role a tela no celular.
