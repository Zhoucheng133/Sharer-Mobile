import 'dart:io';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharer_mobile/utils/types.dart';

class LanguageType{
  String name;
  Locale locale;

  LanguageType(this.name, this.locale);
}

List<LanguageType> get supportedLocales => [
  LanguageType("English", const Locale("en", "US")),
  LanguageType("简体中文", const Locale("zh", "CN")),
  LanguageType("繁體中文", const Locale("zh", "TW")),
];

enum Pages{
  files,
  server,
  settings,
}

enum CopyMoveType{
  copy,
  move,
}

class MultiSelect{
  bool multiSelect=false;
  List<FileType> selected=[];
}

class CopyMoveItem{
  CopyMoveType? type;
  List<FileType> items=[];
}

class Controller extends GetxController {
  Rx<LanguageType> lang=Rx(supportedLocales[0]);

  late SharedPreferences prefs;

  Rx<Pages> page=Rx(Pages.files);
  RxString filesDir="".obs;
  RxBool running=false.obs;
  RxString nowDir="".obs;

  Rx<MultiSelect> multiSelect=MultiSelect().obs;
  Rx<CopyMoveItem> copyMoveItem=CopyMoveItem().obs;

  RxBool initNetwork=false.obs;

  void initLanguage(){
    int? langIndex=prefs.getInt("langIndex");

    if(langIndex==null){
      final deviceLocale=PlatformDispatcher.instance.locale;
      final local=Locale(deviceLocale.languageCode, deviceLocale.countryCode);
      int index=supportedLocales.indexWhere((element) => element.locale==local);
      if(index!=-1){
        lang.value=supportedLocales[index];
        lang.refresh();
      }
    }else{
      lang.value=supportedLocales[langIndex];
    }
  }

  Future<void> initFiles() async {
    final docDir=await getApplicationDocumentsDirectory();
    final targetPath = p.join(docDir.path, "files");
    final dir = Directory(targetPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true); 
    }
    filesDir.value = targetPath;
    nowDir.value=targetPath;
  }

  RxString port=RxString("8080");
  RxBool useAuth=RxBool(false);
  RxString username=RxString("");
  RxString password=RxString("");

  void initPrefs(){
    initNetwork.value=prefs.getBool("initNetwork")??false;
    port.value=prefs.getString("port")??"8080";
    useAuth.value=prefs.getBool("useAuth")??false;
    username.value=prefs.getString("username")??"";
    password.value=prefs.getString("password")??"";
  }

  Future<void> init() async {
    prefs=await SharedPreferences.getInstance();

    initLanguage();
    initPrefs();
    await initFiles();
  }

  void changeLanguage(int index){
    lang.value=supportedLocales[index];
    prefs.setInt("langIndex", index);
    lang.refresh();
    Get.updateLocale(lang.value.locale);
  }
}