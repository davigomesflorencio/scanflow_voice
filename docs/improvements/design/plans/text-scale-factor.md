# Correção: com o texto do aparelho aumentado, o layout transborda

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/text-scale-factor
- **Nova dependência**: nenhuma

## Por quê

Quem aumenta o tamanho do texto do aparelho por acessibilidade vê o layout quebrar em escalas altas. Na tela principal há linhas com botão e texto lado a lado e um card de altura fixa (170) com o player, que transbordam fácil. Limitar a escala a 1.1× respeita a preferência do usuário sem quebrar a tela.

## Onde

O app não limita `textScaler` em lugar nenhum. A raiz do app:

```dart
// lib/main.dart:26 — atual
    return GetMaterialApp(
      title: 'ScanFlow Voice',
      debugShowCheckedModeBanner: false,
```

Exemplo do que quebra: o card do player tem altura fixa.

```dart
// lib/screens/home_page.dart:110 — atual
                  height: 170,
```

## A correção

Sobrescrever `MediaQuery.textScaler` no `builder` do `GetMaterialApp`, limitando a escala a no máximo 1.1×.

```dart
// alvo — lib/main.dart
    return GetMaterialApp(
      title: 'ScanFlow Voice',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final MediaQueryData mediaQueryData = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: mediaQueryData.textScaler.clamp(
              maxScaleFactor: 1.1,
            ),
          ),
          child: child!,
        );
      },
```

## Passos

1. Em `lib/main.dart`, dentro de `GetMaterialApp(...)`, logo depois de `debugShowCheckedModeBanner: false,`, adicione o parâmetro `builder:` exatamente como no alvo acima.
2. Rode o app num aparelho ou emulador com a fonte do sistema no máximo e confira se a tela principal (campo de texto, botão de falar e player depois de gerar um áudio) aparece sem faixas amarelas e pretas de overflow.

## Verificação

- `dart analyze` termina sem **erros**.
- `grep -c "maxScaleFactor: 1.1" lib/main.dart` → 1
- `grep -c "builder: (context, child)" lib/main.dart` → 1

## Não mexer

- `lib/screens/home_page.dart`: o limite resolve os casos comuns. Se algo ainda transbordar a 1.1×, reporte em vez de mudar layout.
- Os outros parâmetros do `GetMaterialApp`.
- Nada de novas dependências.
- Nada de refatorar, renomear ou limpar código além desta correção.

## PARE se

- `GetMaterialApp` em `lib/main.dart` já tiver um parâmetro `builder:`.
- A tela ainda transbordar com a fonte do sistema no máximo (o limite de 1.1× não basta; o desenvolvedor decide se adapta o layout ou limita a 1.0×).
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que o app agora respeita o aumento de fonte do aparelho até 1.1× e não passa disso, para não quebrar a tela. Para ver, aumente a fonte do sistema ao máximo e abra o app.
