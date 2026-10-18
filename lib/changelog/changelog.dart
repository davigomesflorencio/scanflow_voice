import 'package:pub_semver/pub_semver.dart';

enum Language { pt }

const Map<String, Map<Language, List<String>>> _changelog = {
  '2.0.0': {
    Language.pt: [
      'Visual novo: o texto ocupa a tela e o botão de ouvir fica sempre à mão.',
      'Pause e retome o áudio quando quiser.',
      'Modo escuro, seguindo o tema do seu celular.',
      'Contador de caracteres e botão para colar texto.',
      'Vibração sutil quando o áudio fica pronto ou algo dá errado.',
      'Agora o app mostra as novidades sempre que for atualizado.',
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
