# Changelog

Todas as mudanças relevantes deste projeto são documentadas neste arquivo.

O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/)
e o projeto adota o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [2.0.0] - 2026-10-17

### Adicionado

- **Novo visual da tela principal**, focado no texto: o campo ocupa a tela, com uma barra de ações (câmera, galeria, colar, limpar) e contador de caracteres. O botão "Ouvir texto" e o player ficam num painel fixo embaixo.
- **Player com tocar/pausar**, tempos com algarismos de largura fixa e barra de posição nas cores do tema. A onda animada aparece enquanto o áudio toca.
- **Modo escuro**, seguindo o tema do sistema.
- **Contador de caracteres** (a ElevenLabs cobra por caractere).
- Botão para **colar** o texto copiado.
- Diálogo "Novidades" na primeira abertura após uma atualização (nunca na primeira instalação), com as mudanças de todas as versões que o usuário ainda não viu. Textos em `lib/changelog/changelog.dart`.
- Vibração em sucessos (áudio pronto, texto reconhecido), erros e cancelamentos, com o pacote `haptic_feedback`.
- Versão e build do app no fim da tela.
- Barra de progresso enquanto a versão web carrega.
- Dependências `package_info_plus`, `shared_preferences`, `pub_semver` e `haptic_feedback`.
- Planos de melhoria de design em `docs/improvements/design/`.

### Alterado

- Interface toda em português (antes misturava "Enter some text", "Take Photo" etc. com mensagens em português).
- Cores vindas do tema em vez de valores fixos (título preto, slider preto e cinza, fundo branco).
- O ícone do microfone foi para o lado do título, num círculo claro legível nos dois temas.
- Mensagens de erro sem detalhes técnicos da exceção.
- Cursor e seleção de texto com o turquesa do app.
- O conteúdo rola até a borda, com espaço da altura da barra de navegação do sistema.
- O ícone do app é pré-carregado antes do primeiro quadro.

- Dependências atualizadas para as versões mais recentes compatíveis com Flutter 3.47 / Dart 3.13:

  | Pacote                          | Antes        | Depois    |
  | ------------------------------- | ------------ | --------- |
  | `camera`                        | ^0.11.3      | ^0.12.1   |
  | `camera_android`                | ^0.10.10+14  | ^0.10.12  |
  | `cupertino_icons`               | ^1.0.8       | ^2.0.0    |
  | `flutter_dotenv`                | ^6.0.0       | ^6.0.1    |
  | `google_mlkit_commons`          | ^0.11.0      | ^0.13.0   |
  | `google_mlkit_text_recognition` | ^0.15.0      | ^0.17.1   |
  | `image_picker`                  | ^1.2.1       | ^1.2.4    |
  | `just_audio`                    | ^0.10.5      | ^0.10.6   |
  | `siri_wave`                     | ^2.3.0       | ^2.3.1    |
  | `icons_launcher` (dev)          | ^3.0.3       | ^3.1.0    |

- Dependências transitivas atualizadas via `pubspec.lock`.
- Android: Android Gradle Plugin 8.11.1 → 9.0.1, Gradle 8.14 → 9.2.0 e Kotlin 2.2.20 → 2.3.20; `kotlinOptions` migrado para `kotlin { compilerOptions { } }`. O Kotlin embutido do AGP 9 continua desligado (`android.builtInKotlin=false`) enquanto o plugin `audio_session` aplicar o Kotlin Gradle Plugin.
- Android: `versionCode` e `versionName` passam a vir do `pubspec.yaml` (build number `11`, acima do `versionCode` 10 fixo anterior).
- Android: o build de release não falha mais sem `android/key.properties`; nesse caso assina com a chave de debug.
- `analysis_options.yaml` passa a excluir da análise as pastas de build e de plataforma (`android`, `ios`, `web`, `windows`, `macos`, `linux`).

### Removido

- Botão flutuante expansível de câmera e galeria (as ações foram para a barra do campo de texto) e a dependência `flutter_expandable_fab`.
- `autofocus` do campo de texto: o teclado não abre mais sozinho, nem volta depois do diálogo de novidades.

### Corrigido

- O botão de gerar áudio ficava "carregando" durante toda a reprodução, porque `player.play()` do `just_audio` só retorna quando o áudio termina.
- Os ouvintes de posição e duração do player eram criados de novo a cada áudio gerado.
- O card do player dependia de `player.audioSource`, que não é reativo, e podia não atualizar.
- Erro quando a duração do áudio vinha nula.
- Player, campo de texto e reconhecedor de texto agora são liberados quando o controller é fechado.
- Aviso quando a foto não tem texto, em vez de apagar o campo.

## [1.0.0] - 2025-12-29

### Adicionado

- Primeira versão do ScanFlow Voice.
- Síntese de voz a partir de texto digitado, usando a API da ElevenLabs (modelo `eleven_multilingual_v2`).
- Reconhecimento de texto (OCR) em fotos da câmera ou da galeria com Google ML Kit.
- Player de áudio com onda animada (Siri wave), barra de progresso e controle de reprodução.
- Ícone do app e capturas de tela de pré-visualização.

[2.0.0]: https://github.com/davigomesflorencio/scanflow_voice/compare/b265d3c...HEAD
[1.0.0]: https://github.com/davigomesflorencio/scanflow_voice/commits/b265d3c
