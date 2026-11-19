import 'package:flutter/material.dart';

import 'app.dart';
import 'data/database_helper.dart';
import 'services/ajustes_controller.dart';
import 'services/preferencias_service.dart';

Future<void> main() async {
  // Necesario para usar plugins (shared_preferences, sqflite) antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Se cargan las preferencias ANTES de runApp: así la app arranca ya con
  // el tema correcto y no hay parpadeo.
  final ajustes = AjustesController(PreferenciasService.instancia);
  await ajustes.cargar();

  // Se abre la base de datos (crea las tablas o aplica la migración).
  try {
    await DatabaseHelper.instancia.database;
  } catch (e) {
    debugPrint('Error al abrir la base de datos: $e');
  }

  runApp(Game2048App(ajustes: ajustes));
}
