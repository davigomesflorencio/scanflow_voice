# Correção: o teclado continua aberto quando o usuário rola a tela

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/dismiss-keyboard-on-scroll
- **Nova dependência**: nenhuma

## Por quê

Na tela principal, o usuário digita o texto no campo (que abre com foco automático) e depois rola para baixo para chegar ao botão de gerar áudio e ao player. O teclado continua cobrindo metade da tela. Rolar significa que ele terminou de digitar, então o teclado deve fechar sozinho.

## Onde

O único conteúdo rolável do app, que contém o `TextField` (linha 86):

```dart
// lib/screens/home_page.dart:63 — atual
          child: SingleChildScrollView(
            child: Column(
```

## A correção

Definir `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` nesse `SingleChildScrollView`. Esta tela não é um chat (o usuário não rola enquanto ainda digita), então `onDrag` é o correto.

```dart
// alvo
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
```

## Passos

1. Em `lib/screens/home_page.dart`, no `SingleChildScrollView` que envolve a `Column` principal da tela, adicione o parâmetro `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,`. Se outros planos desta pasta já tiverem adicionado parâmetros a ele (ex.: `padding:`) ou mudado a indentação, apenas acrescente este parâmetro, mantendo os existentes.

## Verificação

- `dart analyze` termina sem **erros**.
- `grep -c "ScrollViewKeyboardDismissBehavior.onDrag" lib/screens/home_page.dart` → 1

## Não mexer

- O `TextField` (inclusive o `autofocus: true`).
- O resto da estrutura do `body`.
- Nada de novas dependências.
- Nada de refatorar, renomear ou limpar código além desta correção.

## PARE se

- Não houver um `SingleChildScrollView(` em `lib/screens/home_page.dart`, ou ele já tiver um `keyboardDismissBehavior` com outro valor.
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que agora o teclado fecha sozinho assim que o usuário arrasta a tela principal. Para ver, digite algo no campo de texto e role a tela para baixo.
