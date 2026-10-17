# Changelog

Todas as mudanças relevantes deste projeto são documentadas neste arquivo.

O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/)
e o projeto adota o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [1.0.1] - 2026-10-17

### Alterado

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
- `analysis_options.yaml` passa a excluir da análise as pastas de build e de plataforma (`android`, `ios`, `web`, `windows`, `macos`, `linux`).

### Observações

- `flutter_expandable_fab` foi mantido em `^2.5.2`. A versão 3.0.0 migrou para `package:material_ui`, e seu `ExpandableFab.location` deixou de ser compatível com o `Scaffold` de `package:flutter/material.dart`. A atualização exige migrar o app inteiro para `material_ui`.

## [1.0.0] - 2025-12-29

### Adicionado

- Primeira versão do ScanFlow Voice.
- Síntese de voz a partir de texto digitado, usando a API da ElevenLabs (modelo `eleven_multilingual_v2`).
- Reconhecimento de texto (OCR) em fotos da câmera ou da galeria com Google ML Kit.
- Player de áudio com onda animada (Siri wave), barra de progresso e controle de reprodução.
- Ícone do app e capturas de tela de pré-visualização.

[1.0.1]: https://github.com/davigomesflorencio/scanflow_voice/compare/b265d3c...HEAD
[1.0.0]: https://github.com/davigomesflorencio/scanflow_voice/commits/b265d3c
