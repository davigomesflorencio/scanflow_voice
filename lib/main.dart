import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gnix_tts/components/asset_preloader.dart';
import 'package:gnix_tts/controllers/changelog_controller.dart';
import 'package:gnix_tts/controllers/home_controller.dart';
import 'package:gnix_tts/screens/home_page.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

String API_KEY = dotenv.env['API_KEY'] as String;
late List<CameraDescription> _cameras;

Future main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  WidgetsBinding.instance.deferFirstFrame();
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
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      initialBinding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
        Get.put(ChangelogController());
      }),
      home: AssetPreloader(child: HomePage()),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    const Color brand = Color.fromARGB(255, 51, 204, 204);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        brightness: brightness,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      fontFamily: 'Rubik',
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: brand.withValues(alpha: 0.3),
        selectionHandleColor: brand,
        cursorColor: brand,
      ),
    );
  }
}
