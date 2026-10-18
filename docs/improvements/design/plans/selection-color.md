# Correção: a seleção de texto e o cursor usam cores padrão, fora da identidade do app

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/selection-color
- **Nova dependência**: nenhuma

## Por quê

O campo de texto da tela principal usa as cores de seleção e de cursor que o `MaterialApp` escolhe sozinho. O app tem uma cor de marca (o turquesa `Color.fromARGB(255, 51, 204, 204)`, usado na onda e no slider), e a seleção deve usar essa cor.

## Onde

O tema do app, sem `textSelectionTheme`:

```dart
// lib/main.dart:29 — atual
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 51, 204, 204),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        fontFamily: 'Rubik',
      ),
```

O campo afetado:

```dart
// lib/screens/home_page.dart:86 — atual
                TextField(
                  controller: controller.textController,
```

## A correção

Adicionar `textSelectionTheme` ao `ThemeData`: a cor da marca com opacidade para a seleção (fica atrás do texto, então precisa de transparência para manter o contraste) e a cor cheia para o cursor e as alças de seleção.

```dart
// alvo — lib/main.dart
        fontFamily: 'Rubik',
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Color.fromARGB(255, 51, 204, 204).withValues(alpha: 0.3),
          selectionHandleColor: Color.fromARGB(255, 51, 204, 204),
          cursorColor: Color.fromARGB(255, 51, 204, 204),
        ),
      ),
```

## Passos

1. Em `lib/main.dart`, dentro de `ThemeData(...)`, logo depois da linha `fontFamily: 'Rubik',`, adicione o bloco `textSelectionTheme: TextSelectionThemeData(...)` exatamente como no alvo acima.

## Verificação

- `dart analyze` termina sem **erros**.
- `grep -c "textSelectionTheme: TextSelectionThemeData" lib/main.dart` → 1
- `grep -c "selectionHandleColor" lib/main.dart` → 1

## Não mexer

- `lib/screens/home_page.dart`: o `TextField` herda o tema, não precisa mudar.
- As outras propriedades do `ThemeData`.
- Nada de novas dependências.
- Nada de refatorar, renomear ou limpar código além desta correção.

## PARE se

- O `ThemeData` em `lib/main.dart` não tiver mais a linha `fontFamily: 'Rubik',` ou já tiver um `textSelectionTheme`. Outros planos desta pasta podem ter mudado outras partes de `main.dart`; isso é normal.
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que o cursor, as alças e o destaque de seleção do campo de texto agora usam o turquesa do app. Para ver, abra o app, digite algo e dê um toque longo numa palavra.
