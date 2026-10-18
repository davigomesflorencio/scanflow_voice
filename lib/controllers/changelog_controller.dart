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
