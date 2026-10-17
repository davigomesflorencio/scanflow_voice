# Correção: o usuário não tem onde ver a versão do app

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/show-app-version
- **Nova dependência**: `package_info_plus` (ler nome, versão e build do app instalado)

## Por quê

Quando alguém relata um bug, a primeira pergunta é qual versão está instalada, e o ScanFlow Voice não mostra isso em lugar nenhum. Uma linha discreta com nome, versão e número de build resolve, e também ajuda quem está testando a saber qual build tem em mãos.

## Onde

O app tem uma única tela e não tem página de configurações. O lugar equivalente é o fim do conteúdo rolável da tela principal, logo depois do card do player:

```dart
// lib/screens/home_page.dart:222 — atual
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
```

(Nessa sequência, o `)` da linha 225 fecha o `Obx` do card, o `),` da linha 226 fecha o `Container` do card, e o `],` da linha 227 fecha a lista `children` da `Column` principal.)

O projeto não usa Shorebird (não há `shorebird` no `pubspec.yaml`), então não existe número de patch para mostrar.

## A correção

O widget `VersionIndicator` do artigo, sem a parte do Shorebird: mostra `<nome> <versão> (<build>)`, discreto, em fonte pequena, cinza e com algarismos tabulares. Ele fica centralizado no fim da tela.

Arquivo novo `lib/components/version_indicator.dart`, conteúdo exato:

```dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionIndicator extends StatefulWidget {
  const VersionIndicator({super.key});

  @override
  State<VersionIndicator> createState() => _VersionIndicatorState();
}

class _VersionIndicatorState extends State<VersionIndicator> {
  String? _label;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final PackageInfo info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      _label = '${info.appName} ${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_label == null) {
      return const SizedBox.shrink();
    }

    return Text(
      _label!,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: Colors.grey.shade500,
      ),
    );
  }
}
```

Alvo em `home_page.dart`, como últimos filhos da `Column` principal:

```dart
// alvo
                  ),
                ),
                const SizedBox(height: 24),
                const VersionIndicator(),
              ],
            ),
          ),
```

## Passos

1. Na raiz do projeto, rode `flutter pub add package_info_plus`. Se já estiver em `dependencies` (outro plano pode ter adicionado), pule este passo.
2. Crie `lib/components/version_indicator.dart` com o conteúdo exato acima.
3. Em `lib/screens/home_page.dart`, adicione `import 'package:gnix_tts/components/version_indicator.dart';` junto aos imports `package:gnix_tts/...`.
4. Em `lib/screens/home_page.dart`, na lista `children` da `Column` principal (a de `crossAxisAlignment: CrossAxisAlignment.stretch`), depois do `Container` do card do player e antes do `],` que fecha a lista, adicione:
   ```dart
                   const SizedBox(height: 24),
                   const VersionIndicator(),
   ```
   Se outro plano tiver adicionado um `BottomPadding()` como último filho, coloque estas duas linhas antes dele.

## Verificação

- `dart analyze` termina sem **erros**.
- `grep -c "const VersionIndicator()" lib/screens/home_page.dart` → 1
- `grep -c "info.buildNumber" lib/components/version_indicator.dart` → 1
- `grep -c "^  package_info_plus:" pubspec.yaml` → 1

## Não mexer

- O conteúdo do card do player e o resto da tela.
- O campo `version:` do `pubspec.yaml`: é de lá que a versão é lida.
- Nenhuma dependência além de `package_info_plus` (não adicione Shorebird).
- Nada de refatorar, renomear ou limpar código além desta correção.

## PARE se

- A `Column` principal de `lib/screens/home_page.dart` não terminar mais com o `Container` do card do player.
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que o fim da tela principal agora mostra, em cinza discreto, o nome, a versão e o número de build do app (ex.: `gnix_tts 1.0.1 (11)`). Para ver, abra o app e role até o fim da tela.
