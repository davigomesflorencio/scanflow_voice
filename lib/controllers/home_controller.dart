import 'dart:async';
import 'dart:io';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:gnix_tts/components/painters/text_detector_painter.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:gnix_tts/domain/audio/gnix_audio_source.dart';
import 'package:gnix_tts/main.dart';
import 'package:gnix_tts/services/haptics_helper.dart';
import 'package:gnix_tts/services/tts_service.dart';
import 'package:siri_wave/siri_wave.dart';

class HomeController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final AudioPlayer player = AudioPlayer();
  final RxBool isLoading = false.obs;
  late TtsService _ttsService;

  File? image;
  String? path;
  ImagePicker? imagePicker;
  RxBool isProcessing = false.obs;
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  RxBool canProcess = true.obs;
  RxBool isBusy = false.obs;
  CustomPaint? customPaint;
  RxString textObx = "".obs;

  // Quantidade de caracteres do texto (a ElevenLabs cobra por caractere)
  final RxInt charCount = 0.obs;

  // Estado do player
  final RxBool hasAudio = false.obs;
  final RxBool isPlaying = false.obs;
  Rx<Duration> duration = const Duration().obs;
  Rx<Duration> position = const Duration().obs;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  final controllerWaveForm = IOS7SiriWaveformController(
    amplitude: 0.7,
    color: Color.fromARGB(255, 51, 204, 204),
    frequency: 10,
    speed: 0.15,
  );

  @override
  void onInit() {
    super.onInit();
    _ttsService = TtsService(API_KEY);
    imagePicker = ImagePicker();
    textController.addListener(() {
      charCount.value = textController.text.length;
    });
    observeAudioStream();
  }

  Future<void> speak() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    try {
      final bytes = await _ttsService.synthesize(text);
      final audioSource = GnixAudioSource(bytes);
      await player.setAudioSource(audioSource);
      hasAudio.value = true;
      HapticsHelper.success();
      // Sem await: no just_audio, play() só retorna quando a reprodução termina
      player.play();
    } catch (e) {
      HapticsHelper.error();
      showMessage('Não foi possível gerar o áudio.');
      debugPrint('Erro ao sintetizar o texto: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void togglePlayback() {
    if (player.playing && player.processingState != ProcessingState.completed) {
      player.pause();
      return;
    }
    if (player.processingState == ProcessingState.completed) {
      player.seek(Duration.zero);
    }
    player.play();
  }

  void clearText() {
    textController.clear();
  }

  Future<void> pasteText() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? text = data?.text;
    if (text == null || text.isEmpty) {
      HapticsHelper.warning();
      showMessage('Não há texto copiado para colar.');
      return;
    }
    textController.text = text;
    textController.selection = TextSelection.collapsed(offset: text.length);
  }

  void showMessage(String text) {
    DelightToastBar(
      autoDismiss: true,
      builder: (context) => ToastCard(
        leading: const Icon(Icons.info_outline_rounded, size: 28),
        title: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    ).show(Get.context!);
  }

  void observeAudioStream() {
    _subscriptions.addAll([
      player.durationStream.listen((d) {
        duration.value = d ?? Duration.zero;
      }),
      player.positionStream.listen((p) {
        position.value = p;
      }),
      player.playerStateStream.listen((state) {
        isPlaying.value =
            state.playing && state.processingState != ProcessingState.completed;
      }),
    ]);
  }

  void changeToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    player.seek(newDuration);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  Future<void> processImagePicker(ImageSource source) async {
    if (isProcessing.value) return;

    FocusManager.instance.primaryFocus?.unfocus();
    isProcessing.value = true;
    image = null;
    path = null;

    try {
      final pickedFile = await imagePicker?.pickImage(source: source);

      if (pickedFile != null) {
        await _processFile(pickedFile.path);
      } else {
        HapticsHelper.warning();
        showMessage('Nenhuma imagem selecionada.');
      }
    } on PlatformException catch (e) {
      HapticsHelper.error();
      showMessage('Falha ao obter imagem: ${e.message}');
      debugPrint('PlatformException ao obter imagem: ${e.toString()}');
    } catch (e) {
      HapticsHelper.error();
      showMessage('Ocorreu um erro ao obter a imagem.');
      debugPrint('Erro ao obter imagem: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _processFile(String path) async {
    image = File(path);
    path = path;

    try {
      final inputImage = InputImage.fromFilePath(path);
      await _processImage2(inputImage);
    } catch (e) {
      HapticsHelper.error();
      showMessage('Não foi possível processar a imagem.');
      debugPrint('Erro ao processar arquivo: ${e.toString()}');
    }
  }

  Future<void> _processImage2(InputImage inputImage) async {
    try {
      // Verificações iniciais
      if (!canProcess.value || isBusy.value) return;

      isBusy.value = true;
      textObx.value = '';

      // Processamento do texto
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Atualização da UI com os resultados
      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = TextRecognizerPainter(
          recognizedText,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
        );
        customPaint = CustomPaint(painter: painter);
      } else if (recognizedText.text.trim().isEmpty) {
        HapticsHelper.warning();
        showMessage('Nenhum texto encontrado na imagem.');
      } else {
        textObx.value = recognizedText.text;
        textController.text = recognizedText.text;
        HapticsHelper.success();
        customPaint = null;
        await player.stop();
        hasAudio.value = false;
      }
      isBusy.value = false;
    } on PlatformException catch (e) {
      _handleError('Erro na plataforma: ${e.message}');
    } on TimeoutException catch (e) {
      _handleError(e.message ?? 'Tempo limite excedido');
    } on Exception catch (e) {
      _handleError('Erro no processamento: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    HapticsHelper.error();
    isBusy.value = false;
    textObx.value = 'Falha ao processar imagem';
    customPaint = null;
    showMessage('Não foi possível ler o texto da imagem.');

    // Opcional: Log para debug
    debugPrint('Erro no processamento de imagem: $message');
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    textController.dispose();
    player.dispose();
    textRecognizer.close();
    super.onClose();
  }
}
