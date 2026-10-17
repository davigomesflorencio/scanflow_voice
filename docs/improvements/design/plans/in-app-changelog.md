# Correção: depois de atualizar, o usuário não fica sabendo o que mudou

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/in-app-changelog
- **Nova dependência**: `package_info_plus` (ler a versão instalada), `shared_preferences` (guardar a última versão vista), `pub_semver` (comparar versões; hoje já vem como dependência transitiva, precisa virar direta)

## Por quê

Depois de uma atualização do ScanFlow Voice, nada diz ao usuário o que mudou, então correções e recursos novos passam despercebidos. Mostrar a lista de novidades na primeira abertura após a atualização faz o usuário perceber o que foi feito, e quem pediu aquela melhoria sabe que foi ouvido.

## Onde

O app tem uma única tela, `HomePage`, e usa GetX. O controller da tela é registrado aqui:

```dart
// lib/main.dart:43 — atual
      initialBinding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
```

A versão atual do app está em `pubspec.yaml:7`:

```yaml
version: 1.0.1+11
```

Nenhum arquivo do app trata changelog hoje.

## A correção

1. Um mapa versionado de novidades em Dart, com um `enum` de idioma como chave (o app hoje só tem textos em português).
2. Uma função `unseenChanges` que devolve **todas** as novidades entre a última versão vista (exclusive) e a atual (inclusive), comparando com `pub_semver`.
3. Um `ChangelogController` (GetX, como o resto do app) que:
   - lê a versão atual com `PackageInfo.fromPlatform()`;
   - lê `last_seen_version` do `SharedPreferences`;
   - **primeira instalação** (`lastSeen == null`): salva a versão atual e não mostra nada;
   - mesma versão: não faz nada;
   - sem novidades no intervalo: salva a versão atual e não mostra nada;
   - caso contrário, mostra um diálogo com a lista e, quando ele fecha, chama `dismiss()`, que salva a versão atual.

Arquivo novo `lib/changelog/changelog.dart`, conteúdo exato:

```dart
import 'package:pub_semver/pub_semver.dart';

enum Language { pt }

const Map<String, Map<Language, List<String>>> _changelog = {
  '1.0.1': {
    Language.pt: [
      'Bibliotecas atualizadas para mais estabilidade.',
    ],
  },
};

List<String> unseenChanges({
  required String lastSeen,
  required String current,
  required Language language,
}) {
  final Version lastSeenVersion = Version.parse(lastSeen);
  final Version currentVersion = Version.parse(current);

  final List<String> result = [];

  for (final entry in _changelog.entries) {
    final Version entryVersion = Version.parse(entry.key);

    if (entryVersion > lastSeenVersion && entryVersion <= currentVersion) {
      final changes = entry.value[language];
      if (changes != null) result.addAll(changes);
    }
  }

  return result;
}
```

Arquivo novo `lib/controllers/changelog_controller.dart`, conteúdo exato:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gnix_tts/changelog/changelog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangelogController extends GetxController {
  String? _currentVersion;

  @override
  void onReady() {
    super.onReady();
    initialize(language: Language.pt);
  }

  Future<void> initialize({required Language language}) async {
    final String current = (await PackageInfo.fromPlatform()).version;
    _currentVersion = current;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastSeen = prefs.getString('last_seen_version');

    // Primeira instalação — nada para mostrar, salva e segue
    if (lastSeen == null) {
      await prefs.setString('last_seen_version', current);
      return;
    }

    // Já está atualizado
    if (lastSeen == current) return;

    final List<String> changes = unseenChanges(
      lastSeen: lastSeen,
      current: current,
      language: language,
    );

    if (changes.isEmpty) {
      await prefs.setString('last_seen_version', current);
      return;
    }

    await Get.dialog(
      AlertDialog(
        title: const Text('Novidades'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final String change in changes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $change'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );

    await dismiss();
  }

  Future<void> dismiss() async {
    final String? version = _currentVersion;
    if (version != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_seen_version', version);
    }
  }
}
```

Registro no binding (alvo):

```dart
// lib/main.dart — alvo
      initialBinding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
        Get.put(ChangelogController());
      }),
```

`Get.put` (e não `lazyPut`) é necessário: nada na tela pede o `ChangelogController`, então ele precisa ser criado logo para o `onReady` rodar.

## Passos

1. Na raiz do projeto, rode `flutter pub add package_info_plus shared_preferences pub_semver`. Se algum já estiver em `dependencies` no `pubspec.yaml`, tudo bem, o comando só ajusta a versão.
2. Crie `lib/changelog/changelog.dart` com o conteúdo exato mostrado acima.
3. Crie `lib/controllers/changelog_controller.dart` com o conteúdo exato mostrado acima.
4. Em `lib/main.dart`, adicione `import 'package:gnix_tts/controllers/changelog_controller.dart';` junto aos outros imports `package:gnix_tts/...`.
5. Em `lib/main.dart`, dentro de `BindingsBuilder(() { ... })`, adicione a linha `Get.put(ChangelogController());` logo depois de `Get.lazyPut(() => HomeController());`.

## Verificação

- `dart analyze` termina sem **erros** (os avisos que já existiam antes podem continuar).
- `grep -c "Get.put(ChangelogController())" lib/main.dart` → 1
- `grep -c "last_seen_version" lib/controllers/changelog_controller.dart` → 4
- `grep -c "'1.0.1'" lib/changelog/changelog.dart` → 1
- `grep -cE "^  (package_info_plus|shared_preferences|pub_semver):" pubspec.yaml` → 3

## Não mexer

- `lib/controllers/home_controller.dart` e `lib/screens/home_page.dart`: a lógica de novidades fica isolada no controller novo.
- `CHANGELOG.md` na raiz: é o changelog técnico do repositório, não o que aparece no app.
- Nada de outras dependências além das três do cabeçalho.
- Nada de refatorar, renomear ou limpar código além desta correção.

## PARE se

- O trecho de `lib/main.dart` citado em "Onde" não existir mais (o código mudou desde que este plano foi escrito). Outros planos desta pasta podem ter mudado linhas próximas em `main.dart`; isso é normal, desde que o bloco `BindingsBuilder` continue lá.
- A versão em `pubspec.yaml` não for `1.0.1+...` (a entrada do mapa precisa ser revista).
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que o app agora mostra um diálogo "Novidades" na primeira abertura após uma atualização (nunca na primeira instalação). Para ver, instale a versão anterior, atualize para a nova e abra o app. Lembre que, a cada nova versão, é preciso adicionar uma entrada no mapa `_changelog` em `lib/changelog/changelog.dart`.
