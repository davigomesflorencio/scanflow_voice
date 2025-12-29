import 'dart:async';
import 'dart:io';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:gnix_tts/components/painters/text_detector_painter.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:gnix_tts/domain/audio/gnix_audio_source.dart';
import 'package:gnix_tts/main.dart';
import 'package:gnix_tts/services/tts_service.dart';
import 'package:siri_wave/siri_wave.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  final TextEditingController textController = TextEditingController();
  RxString get textCtl => textController.text.obs;
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

  Rx<Duration> duration = const Duration().obs;
  Rx<Duration> position = const Duration().obs;

  late AnimationController animationController;
  late Animation<double> buttonAnimatedIcon;
  // This is used for the child FABs
  late Animation<double> translateButton;
  RxBool isExpandedMenu = false.obs;

  final key = GlobalKey<ExpandableFabState>();

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
    animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addListener(() {
          update();
        });

    buttonAnimatedIcon = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animationController);
  }

  Future<void> speak() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    isLoading.value = true;
    try {
      final bytes = await _ttsService.synthesize(text);
      final audioSource = GnixAudioSource(bytes);
      await player.setAudioSource(audioSource);
      await player.play();
      observeAudioStream();
    } catch (e) {
      DelightToastBar(
        autoDismiss: false,
        builder: (context) => const ToastCard(
          leading: Icon(Icons.flutter_dash, size: 28),
          title: Text(
            "Erro ao sintetizar o texto.",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ).show(Get.context!);
    } finally {
      isLoading.value = false;
    }
  }

  void showMessage(String text) {
    DelightToastBar(
      autoDismiss: false,
      builder: (context) => ToastCard(
        leading: const Icon(Icons.flutter_dash, size: 28),
        title: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    ).show(Get.context!);
  }

  void toggle() {
    if (isExpandedMenu.value) {
      animationController.reverse();
    } else {
      animationController.forward();
    }

    isExpandedMenu.value = !isExpandedMenu.value;
  }

  void observeAudioStream() {
    player.durationStream.listen((d) {
      duration.value = d!;
    });
    player.positionStream.listen((p) {
      position.value = p;
    });
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

    isProcessing.value = true;
    image = null;
    path = null;

    try {
      final pickedFile = await imagePicker?.pickImage(source: source);

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
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text('Erro ao processar imagem: ${e.toString()}')),
      );
      print('Erro ao processar arquivo: ${e.toString()}');
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
      // .timeout(const Duration(seconds: 10), onTimeout: () {
      //   throw TimeoutException('Tempo limite excedido no processamento de texto');
      // });

      // Atualização da UI com os resultados
      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = TextRecognizerPainter(
          recognizedText,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
        );
        customPaint = CustomPaint(painter: painter);
      } else {
        textObx.value = recognizedText.text;
        textController.text = recognizedText.text;
        customPaint = null;
        player.clearAudioSources();
        key.currentState?.toggle();
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
    textObx.value = 'Falha ao processar imagem';
    customPaint = null;

    // Opcional: Log para debug
    debugPrint('Erro no processamento de imagem: $message');
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
    disposee();
  }

  void disposee() {
    textController.dispose();
    player.dispose();
    isLoading.value = false;
  }
}
