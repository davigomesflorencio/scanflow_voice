# Correção: o fim da tela rolável fica colado ou cortado na barra de navegação do sistema

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/safe-area-replacement
- **Nova dependência**: nenhuma

## Por quê

A tela principal envolve o conteúdo rolável em `SafeArea` e em um `Padding` fixo de 16. O `SafeArea` encolhe a área de rolagem: o conteúdo é cortado numa linha acima da barra do sistema em vez de passar por baixo dela. E 16 fixo não acompanha a altura real da barra, que muda de aparelho para aparelho. O certo é deixar o conteúdo rolar até a borda e adicionar no fim um espaço da altura da barra do sistema.

## Onde

```dart
// lib/screens/home_page.dart:60 — atual
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
```

E o fechamento correspondente, no fim do `build`:

```dart
// lib/screens/home_page.dart:226 — atual
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
```

(As linhas 228–231 fecham, nesta ordem: `Column`, `SingleChildScrollView`, `Padding`, `SafeArea`.)

## A correção

Um widget `BottomPadding` que calcula o espaço da barra inferior do sistema, com um mínimo, e usá-lo como padding inferior do próprio `SingleChildScrollView`. O `SafeArea` e o `Padding` externo saem; o padding de 16 passa para dentro do scroll.

Arquivo novo `lib/components/bottom_padding.dart`, conteúdo exato:

```dart
import 'package:flutter/widgets.dart';

class BottomPadding extends StatelessWidget {
  const BottomPadding({super.key});

  static double of(
    BuildContext context, {
    double minimum = 16,
  }) {
    // Altura da barra inferior do sistema
    final double viewPadding = MediaQuery.viewPaddingOf(context).bottom;

    // Usa a altura da barra se for maior que o mínimo,
    // senão usa o mínimo.
    final double height = viewPadding > minimum ? viewPadding : minimum;

    return height;
  }

  @override
  Widget build(BuildContext context) {
    final double height = of(context);

    return SizedBox(height: height);
  }
}
```

Alvo em `home_page.dart`:

```dart
// alvo
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0).copyWith(
          bottom: BottomPadding.of(context, minimum: 16),
        ),
        child: Column(
```

com o fechamento:

```dart
// alvo
                ),
              ],
            ),
          ),
    );
  }
```

(Agora só `Column` e `SingleChildScrollView` fecham antes do `);` do `Scaffold`.)

## Passos

1. Crie `lib/components/bottom_padding.dart` com o conteúdo exato acima.
2. Em `lib/screens/home_page.dart`, adicione `import 'package:gnix_tts/components/bottom_padding.dart';` junto aos imports `package:gnix_tts/...`.
3. Em `lib/screens/home_page.dart`, substitua as quatro linhas
   ```dart
         body: SafeArea(
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: SingleChildScrollView(
   ```
   por
   ```dart
         body: SingleChildScrollView(
           padding: const EdgeInsets.all(16.0).copyWith(
             bottom: BottomPadding.of(context, minimum: 16),
           ),
   ```
   Se o `SingleChildScrollView` já tiver outros parâmetros adicionados por outros planos (ex.: `keyboardDismissBehavior`), mantenha-os.
4. No fim do `build`, remova os dois `),` que fechavam o `Padding` e o `SafeArea` (são os dois parênteses logo antes do `);` que fecha o `Scaffold`). Se o `SingleChildScrollView` estiver envolvido em `MagicalScrollbar` por outro plano, mantenha o fechamento desse widget.
5. Rode `dart format lib/screens/home_page.dart` para reindentar.

## Verificação

- `dart analyze` termina sem **erros**.
- `grep -c "SafeArea" lib/screens/home_page.dart` → 0
- `grep -c "BottomPadding.of(context" lib/screens/home_page.dart` → 1
- `grep -c "MediaQuery.viewPaddingOf" lib/components/bottom_padding.dart` → 1

## Não mexer

- O `Padding(padding: const EdgeInsets.only(top: 50, bottom: 50), ...)` da imagem do microfone: é espaçamento do conteúdo, não da tela.
- O `floatingActionButton` e o `ExpandableFab`: estão fora do scroll.
- `lib/controllers/home_controller.dart`.
- Nada de novas dependências.
- Nada de refatorar, renomear ou limpar código além desta correção.

## PARE se

- O trecho citado em "Onde" (`body: SafeArea(` seguido de `Padding` com `EdgeInsets.all(16.0)` e `SingleChildScrollView`) não existir mais. Outros planos desta pasta podem ter adicionado parâmetros ao `SingleChildScrollView` ou envolvido ele em `MagicalScrollbar`; isso é normal.
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que a tela principal agora rola até a borda inferior e termina com um respiro da altura da barra de navegação do sistema, sem cortar o conteúdo. Para ver, abra o app em um aparelho com navegação por gestos ou botões, gere um áudio e role até o fim.
