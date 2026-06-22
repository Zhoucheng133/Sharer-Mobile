import 'dart:ffi';
import 'dart:isolate';
import "package:ffi/ffi.dart";
import 'package:flutter/foundation.dart';

typedef StartServer = void Function(Pointer<Utf8> port, Pointer<Utf8> basePath, Pointer<Utf8> username, Pointer<Utf8> password);
typedef StartServerFunc = Void Function(Pointer<Utf8> port, Pointer<Utf8> basePath, Pointer<Utf8> username, Pointer<Utf8> password);

typedef StopServer=void Function();
typedef StopServerFunc=Void Function();

class Server {
  Isolate? isolate;

  static void runHandler(List<String> params){
    final dynamicLib = DynamicLibrary.process();
    StartServer startServer=dynamicLib
        .lookup<NativeFunction<StartServerFunc>>('StartServer')
        .asFunction();

    startServer(
      params[0].toNativeUtf8(), // port
      params[1].toNativeUtf8(), // path
      params[2].toNativeUtf8(), // username
      params[3].toNativeUtf8(), // password
    );
  }

  static void stopHandler(List? params) {
    final lib = DynamicLibrary.process();
    final stop = lib
        .lookup<NativeFunction<StopServerFunc>>('StopServer')
        .asFunction<StopServer>();
    stop();
  }

  Future<void> run(String username, String password, String port, String path) async {
    isolate=await Isolate.spawn(runHandler, [port, path, username, password]);
  }

  void stop() async {
    if(isolate!=null){
      if (isolate != null) {
        await compute(stopHandler, null);
        isolate!.kill(priority: Isolate.immediate);
        isolate = null;
      }
    }
  }
}