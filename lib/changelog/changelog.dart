import 'package:pub_semver/pub_semver.dart';

enum Language { pt }

const Map<String, Map<Language, List<String>>> _changelog = {
  '2.0.0': {
    Language.pt: [
      'Agora o app mostra as novidades sempre que for atualizado.',
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
