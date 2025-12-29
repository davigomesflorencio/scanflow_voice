import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:gnix_tts/controllers/home_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siri_wave/siri_wave.dart';

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ScanFlow Voice',
          style: TextStyle(
            // fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontFamily: "Rubik",
          ),
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: controller.key,
        type: ExpandableFabType.up,
        distance: 70,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.white.withValues(alpha: .5),
        ),
        children: [
          Row(
            children: [
              Text('Take Photo'),
              SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                child: const Icon(Icons.camera_alt),
                onPressed: () {
                  controller.processImagePicker(ImageSource.camera);
                },
              ),
            ],
          ),
          Row(
            children: [
              Text('Select from Gallery'),
              SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                child: const Icon(Icons.photo_camera_back_outlined),
                onPressed: () {
                  controller.processImagePicker(ImageSource.gallery);
                },
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 50),
                  child: Image(
                    image: AssetImage('assets/ai-microphone.png'),
                    width: 150,
                    height: 150,
                  ),
                ),
                Obx(
                  () => controller.isLoading.value
                      ? SiriWaveform.ios7(
                          controller: controller.controllerWaveForm,
                          options: const IOS7SiriWaveformOptions(
                            height: 100,
                            width: 400,
                          ),
                        )
                      : SizedBox(),
                ),
                TextField(
                  controller: controller.textController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Enter some text',
                  ),
                  minLines: 1,
                  maxLines: null,
                ),
                const SizedBox(height: 32.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                    color: Colors.white, // Fundo branco para ver a sombra
                  ),
                  height: 170,
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 5,
                    top: 20,
                    bottom: 20,
                  ),
                  child: Obx(
                    () => (controller.player.audioSource == null)
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(5), // Adjust for size
                                ),
                                onPressed:
                                    controller.isLoading.value &&
                                        controller
                                            .textController
                                            .text
                                            .isNotEmpty
                                    ? null
                                    : controller.speak,
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/speech.png',
                                        width: 40,
                                        height: 40,
                                      ),
                              ),
                              Text(
                                "Click here to generate the text audio",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Obx(
                                    () => ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(
                                          5,
                                        ), // Adjust for size
                                      ),
                                      onPressed:
                                          controller.isLoading.value &&
                                              controller
                                                  .textController
                                                  .text
                                                  .isNotEmpty
                                          ? null
                                          : controller.speak,
                                      child: controller.isLoading.value
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Image.asset(
                                              'assets/speech.png',
                                              width: 40,
                                              height: 40,
                                            ),
                                    ),
                                  ),
                                  Text(
                                    "Control the audio using the bar below",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),

                              SizedBox(height: 15),
                              Row(
                                children: [
                                  SizedBox(width: 5),
                                  Obx(
                                    () => Text(
                                      controller.formatDuration(
                                        controller.position.value,
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  slider(),
                                  Obx(
                                    () => Text(
                                      controller.formatDuration(
                                        controller.duration.value,
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget slider() {
    return Obx(() {
      return Expanded(
        child: Slider(
          activeColor: Colors.black,
          inactiveColor: Colors.grey,
          thumbColor: Color.fromARGB(255, 51, 204, 204),
          value: controller.position.value.inSeconds.toDouble(),
          min: 0.0,
          max: controller.duration.value.inSeconds.toDouble(),
          onChanged: (double value) {
            controller.changeToSecond(value.toInt());
            value = value;
          },
        ),
      );
    });
  }
}
