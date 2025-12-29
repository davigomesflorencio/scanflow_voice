import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gnix_tts/controllers/home_controller.dart';
import 'package:gnix_tts/screens/home_page.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

String API_KEY = dotenv.env['API_KEY'] as String;
late List<CameraDescription> _cameras;

Future main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ScanFlow Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 51, 204, 204),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        fontFamily: 'Rubik',
      ),
      initialBinding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
      home: HomePage(),
    );
  }
}
