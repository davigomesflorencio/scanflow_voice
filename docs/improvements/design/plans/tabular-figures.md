# Correção: o tempo do player "treme" enquanto o áudio toca

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/tabular-figures
- **Nova dependência**: nenhuma

## Por quê

O player mostra a posição atual (`00:12`) e a duração do áudio ao lado da barra. Na fonte Rubik os dígitos têm larguras diferentes, então a cada segundo o número muda de largura, e o texto e a barra ao lado se deslocam. Com algarismos tabulares, todos os dígitos têm a mesma largura e nada se mexe.

## Onde

```dart
// lib/screens/home_page.dart:203 — atual (posição atual, muda a cada segundo)
                                  Obx(
                                    () => Text(
                                      controller.formatDuration(
                                        controller.position.value,
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
```

```dart
// lib/screens/home_page.dart:212 — atual (duração total, alinhada com a posição)
                                  Obx(
                                    () => Text(
                                      controller.formatDuration(
                                        controller.duration.value,
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
```

## A correção

Ativar `FontFeature.tabularFigures()` nos dois textos de tempo. Só neles: textos em frases continuam com os algarismos normais.

```dart
// alvo (nos dois Text acima)
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
```

`FontFeature` vem de `dart:ui` e já é exportado por `package:flutter/material.dart`, que o arquivo já importa.

## Passos

1. Em `lib/screens/home_page.dart`, no `Text` que exibe `controller.formatDuration(controller.position.value)`, troque `style: const TextStyle(fontSize: 16),` pelo `style` do alvo acima.
2. No `Text` que exibe `controller.formatDuration(controller.duration.value)`, faça a mesma troca.

## Verificação

- `dart analyze` termina sem **erros**.
- `grep -c "FontFeature.tabularFigures()" lib/screens/home_page.dart` → 2

## Não mexer

- Os outros `Text` com `style: const TextStyle(fontSize: 16)` da tela ("Click here to generate the text audio", "Control the audio using the bar below"): são frases, não números que mudam.
- `formatDuration` em `lib/controllers/home_controller.dart`.
- Nada de novas dependências.
- Nada de refatorar, renomear ou limpar código além desta correção.

## PARE se

- Os dois `Text` citados em "Onde" não existirem mais com `style: const TextStyle(fontSize: 16)`. Os números de linha podem ter mudado por outros planos desta pasta; o que importa é o texto citado.
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que os tempos do player agora ficam parados enquanto o áudio toca, sem empurrar a barra de um lado para o outro. Para ver, gere um áudio e observe os números ao lado da barra.
