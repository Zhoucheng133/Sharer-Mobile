import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:local_sink/lang/zh_cn.dart';
import 'package:local_sink/main_view.dart';
import 'package:local_sink/utils/controller.dart';

Future<void> main() async {
  final controller=Get.put(Controller());
  await controller.init();
  runApp(const MainApp());
}

class MainTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': zhCN,
  };
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  final Controller controller=Get.find();

  @override
  Widget build(BuildContext context) {

    final Brightness brightness = MediaQuery.of(context).platformBrightness;

    return Obx(
      () => GetMaterialApp(
        translations: MainTranslations(),
        debugShowCheckedModeBanner: false,
        locale: controller.lang.value.locale, 
        supportedLocales: supportedLocales.map((item)=>item.locale).toList(),
        fallbackLocale: supportedLocales.first.locale,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        theme: ThemeData(
          brightness: brightness,
          fontFamily: 'PuHui', 
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue,
            brightness: brightness,
          ),
          textTheme: brightness==Brightness.dark ? ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ) : ThemeData.light().textTheme.apply(),
        ),
        home: MainView()
      ),
    );
  }
}
