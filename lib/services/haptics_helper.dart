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
