import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gnix_tts/components/bottom_padding.dart';
import 'package:gnix_tts/components/version_indicator.dart';
import 'package:gnix_tts/controllers/home_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siri_wave/siri_wave.dart';

const List<FontFeature> _tabularFigures = [FontFeature.tabularFigures()];

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Círculo claro nos dois temas: o ícone tem traços pretos
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: Image.asset('assets/ai-microphone.png'),
            ),
            const SizedBox(width: 10),
            const Text(
              'ScanFlow Voice',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _buildEditor(context),
            ),
          ),
          _buildPanel(context),
        ],
      ),
    );
  }

  /// Área principal: o texto a ser lido e as ações que o preenchem.
  Widget _buildEditor(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              expands: true,
              minLines: null,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              textAlignVertical: TextAlignVertical.top,
              style: tt.bodyLarge?.copyWith(fontSize: 18, height: 1.5),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: 'Digite ou fotografe um texto para ouvir…',
                hintStyle: tt.bodyLarge?.copyWith(
                  fontSize: 18,
                  color: cs.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              ),
            ),
          ),
          Obx(
            () => SizedBox(
              height: 2,
              child: controller.isProcessing.value || controller.isBusy.value
                  ? const LinearProgressIndicator(minHeight: 2)
                  : Divider(height: 2, thickness: 1, color: cs.outlineVariant),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Obx(() {
              final bool busy = controller.isProcessing.value;
              final int count = controller.charCount.value;

              return Row(
                children: [
                  IconButton(
                    tooltip: 'Fotografar texto',
                    icon: const Icon(Icons.photo_camera_outlined),
                    onPressed: busy
                        ? null
                        : () =>
                              controller.processImagePicker(ImageSource.camera),
                  ),
                  IconButton(
                    tooltip: 'Escolher da galeria',
                    icon: const Icon(Icons.photo_library_outlined),
                    onPressed: busy
                        ? null
                        : () => controller.processImagePicker(
                            ImageSource.gallery,
                          ),
                  ),
                  IconButton(
                    tooltip: 'Colar',
                    icon: const Icon(Icons.content_paste_rounded),
                    onPressed: controller.pasteText,
                  ),
                  IconButton(
                    tooltip: 'Limpar texto',
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: count == 0 ? null : controller.clearText,
                  ),
                  const Spacer(),
                  Text(
                    _formatCharCount(count),
                    style: tt.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontFeatures: _tabularFigures,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Painel fixo embaixo: player (depois de gerar o áudio) e botão principal.
  Widget _buildPanel(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final bool keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Material(
      color: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          keyboardOpen ? 12 : BottomPadding.of(context, minimum: 16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => controller.hasAudio.value
                  ? _buildPlayer(context)
                  : const SizedBox.shrink(),
            ),
            Obx(() {
              final bool loading = controller.isLoading.value;
              final bool empty = controller.charCount.value == 0;

              return SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: loading || empty ? null : controller.speak,
                  style: FilledButton.styleFrom(
                    shape: const StadiumBorder(),
                    textStyle: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: cs.primary,
                          ),
                        )
                      : const Icon(Icons.graphic_eq_rounded),
                  label: Text(
                    loading
                        ? 'Gerando áudio…'
                        : controller.hasAudio.value
                        ? 'Gerar áudio de novo'
                        : 'Ouvir texto',
                  ),
                ),
              );
            }),
            if (!keyboardOpen) ...[
              const SizedBox(height: 10),
              const VersionIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final TextStyle? timeStyle = tt.labelLarge?.copyWith(
      fontFeatures: _tabularFigures,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Obx(
              () => controller.isPlaying.value
                  ? LayoutBuilder(
                      builder: (context, constraints) => SiriWaveform.ios7(
                        controller: controller.controllerWaveForm,
                        options: IOS7SiriWaveformOptions(
                          height: 48,
                          width: constraints.maxWidth,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Row(
            children: [
              Obx(
                () => IconButton.filledTonal(
                  iconSize: 28,
                  tooltip: controller.isPlaying.value ? 'Pausar' : 'Tocar',
                  icon: Icon(
                    controller.isPlaying.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  onPressed: controller.togglePlayback,
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  controller.formatDuration(controller.position.value),
                  style: timeStyle,
                ),
              ),
              Expanded(child: slider()),
              Obx(
                () => Text(
                  controller.formatDuration(controller.duration.value),
                  style: timeStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget slider() {
    return Obx(() {
      final double max = controller.duration.value.inSeconds.toDouble();
      final double safeMax = max > 0 ? max : 1;
      final double value = controller.position.value.inSeconds.toDouble().clamp(
        0,
        safeMax,
      );

      return Slider(
        value: value,
        min: 0.0,
        max: safeMax,
        onChanged: max > 0
            ? (double value) => controller.changeToSecond(value.toInt())
            : null,
      );
    });
  }

  /// "1 caractere", "980 caracteres", "1.240 caracteres".
  String _formatCharCount(int count) {
    final String digits = count.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return '$buffer ${count == 1 ? 'caractere' : 'caracteres'}';
  }
}
