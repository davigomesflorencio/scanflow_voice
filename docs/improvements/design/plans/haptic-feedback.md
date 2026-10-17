# Correção: sucessos e erros acontecem sem nenhuma vibração

> Siga os passos na ordem. Rode todas as verificações. Se algo da seção
> "PARE se" acontecer, pare e reporte em vez de improvisar.

- **Link**: https://flutterpro.design/details/md/haptic-feedback
- **Nova dependência**: `haptic_feedback`. O `HapticFeedback` do Flutter só tem alguns tipos genéricos; este pacote tem tipos específicos para sucesso, aviso e erro.

## Por quê

Hoje o app gera o áudio, reconhece o texto da foto ou mostra um erro em silêncio total. Uma vibração sutil nesses momentos faz o app parecer responsivo na mão: um "sucesso" quando o áudio começa ou o texto é reconhecido, um "erro" quando algo falha e um "aviso" quando o usuário cancela a escolha da imagem.

## Onde

Todos em `lib/controllers/home_controller.dart`:

```dart
// lib/controllers/home_controller.dart:80 — atual (áudio gerado com sucesso)
      final bytes = await _ttsService.synthesize(text);
      final audioSource = GnixAudioSource(bytes);
      await player.setAudioSource(audioSource);
      await player.play();
      observeAudioStream();
    } catch (e) {
      DelightToastBar(
```

(O `catch` da linha 85 é o erro ao sintetizar.)

```dart
// lib/controllers/home_controller.dart:160 — atual (escolha de imagem)
      if (pickedFile != null) {
        await _processFile(pickedFile.path);
      } else {
        showMessage('Nenhuma imagem selecionada.');
      }
    } on PlatformException catch (e) {
      showMessage('Falha ao obter imagem: ${e.message}');
      print('PlatformException ao obter imagem: ${e.toString()}');
    } catch (e) {
      showMessage('Ocorreu um erro: ${e.toString()}');
      print('Erro ao obter imagem: ${e.toString()}');
```

```dart
// lib/controllers/home_controller.dart:183 — atual (erro ao processar a imagem)
    } catch (e) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text('Erro ao processar imagem: ${e.toString()}')),
      );
```

```dart
// lib/controllers/home_controller.dart:214 — atual (texto reconhecido com sucesso)
      } else {
        textObx.value = recognizedText.text;
        textController.text = recognizedText.text;
        customPaint = null;
        player.clearAudioSources();
        key.currentState?.toggle();
      }
```

```dart
// lib/controllers/home_controller.dart:231 — atual (falha no reconhecimento)
  void _handleError(String message) {
    textObx.value = 'Falha ao processar imagem';
    customPaint = null;
```

## A correção

Um helper que encapsula o pacote e a checagem `canVibrate`, exatamente como no artigo, e chamadas nos momentos acima:

- **success**: áudio pronto para tocar; texto reconhecido na imagem.
- **error**: falha ao sintetizar; falha ao obter a imagem; falha ao processar a imagem; falha no reconhecimento.
- **warning**: nenhuma imagem selecionada (o usuário cancelou).

Arquivo novo `lib/services/haptics_helper.dart`, conteúdo exato:

```dart
import 'package:haptic_feedback/haptic_feedback.dart';

class HapticsHelper {
  HapticsHelper._();

  static bool? _canVibrate;

  static Future<void> _vibrate(HapticsType type) async {
    _canVibrate ??= await Haptics.canVibrate();

    if (_canVibrate ?? false) {
      await Haptics.vibrate(type);
    }
  }

  // Atalhos para cada tipo
  static Future<void> success() => _vibrate(HapticsType.success);
  static Future<void> warning() => _vibrate(HapticsType.warning);
  static Future<void> error() => _vibrate(HapticsType.error);
  static Future<void> light() => _vibrate(HapticsType.light);
  static Future<void> medium() => _vibrate(HapticsType.medium);
  static Future<void> heavy() => _vibrate(HapticsType.heavy);
  static Future<void> selection() => _vibrate(HapticsType.selection);
}
```

Alvo do sucesso do áudio. A vibração vai **antes** de `player.play()`, porque no `just_audio` o `await player.play()` só termina quando a reprodução para:

```dart
// alvo
      final bytes = await _ttsService.synthesize(text);
      final audioSource = GnixAudioSource(bytes);
      await player.setAudioSource(audioSource);
      HapticsHelper.success();
      await player.play();
      observeAudioStream();
    } catch (e) {
      HapticsHelper.error();
      DelightToastBar(
```

As chamadas não usam `await`, para não atrasar a interface.

## Passos

1. Na raiz do projeto, rode `flutter pub add haptic_feedback`.
2. Crie `lib/services/haptics_helper.dart` com o conteúdo exato acima.
3. Em `lib/controllers/home_controller.dart`, adicione `import 'package:gnix_tts/services/haptics_helper.dart';` junto aos imports `package:gnix_tts/...`.
4. Em `speak()`: adicione `HapticsHelper.success();` numa linha nova entre `await player.setAudioSource(audioSource);` e `await player.play();`.
5. Em `speak()`: adicione `HapticsHelper.error();` como primeira linha dentro de `} catch (e) {`, antes de `DelightToastBar(`.
6. Em `processImagePicker`: adicione `HapticsHelper.warning();` logo antes de `showMessage('Nenhuma imagem selecionada.');`.
7. Em `processImagePicker`: adicione `HapticsHelper.error();` logo antes de `showMessage('Falha ao obter imagem: ${e.message}');`.
8. Em `processImagePicker`: adicione `HapticsHelper.error();` logo antes de `showMessage('Ocorreu um erro: ${e.toString()}');`.
9. Em `_processFile`: adicione `HapticsHelper.error();` como primeira linha dentro de `} catch (e) {`, antes de `ScaffoldMessenger.of(Get.context!).showSnackBar(`.
10. Em `_processImage2`: adicione `HapticsHelper.success();` logo depois de `textController.text = recognizedText.text;`.
11. Em `_handleError`: adicione `HapticsHelper.error();` como primeira linha do método, antes de `textObx.value = 'Falha ao processar imagem';`.

## Verificação

- `dart analyze` termina sem **erros**.
- `grep -c "HapticsHelper.success()" lib/controllers/home_controller.dart` → 2
- `grep -c "HapticsHelper.error()" lib/controllers/home_controller.dart` → 5
- `grep -c "HapticsHelper.warning()" lib/controllers/home_controller.dart` → 1
- `grep -c "^  haptic_feedback:" pubspec.yaml` → 1

## Não mexer

- O texto e a forma das mensagens (`DelightToastBar`, `showMessage`, `SnackBar`): esta correção só adiciona vibração.
- Os `print(...)` existentes.
- `lib/screens/home_page.dart`.
- Nenhuma dependência além de `haptic_feedback`.
- Nada de refatorar, renomear ou limpar código além desta correção.

## PARE se

- Algum dos trechos citados em "Onde" não existir mais. Os números de linha podem ter mudado por outros planos desta pasta; o que importa é o texto citado.
- A correção parecer exigir mexer em algo de "Não mexer".
- Uma verificação falhar duas vezes.

## Ao terminar

Diga ao desenvolvedor, em duas ou três frases, que o app agora vibra de leve quando o áudio começa e quando o texto da foto é reconhecido, com uma vibração diferente quando algo dá errado ou a escolha da imagem é cancelada. Para sentir, use um aparelho físico (emulador não vibra) e gere um áudio.
