import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'nucleo/orquestador_sdui.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    
    runApp(const StudioSduiFabricaApp());
  }, (error, stack) {
    debugPrint('Escudo Global Studio SDUI activo: $error');
  });
}

class StudioSduiFabricaApp extends StatelessWidget {
  const StudioSduiFabricaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'STUDIO SDUI - PRD, RFC, SQL y PDF (Esquema 2)',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF071326),
      ),
      home: const LienzoMaestroSdui(),
    );
  }
}