import 'package:flutter/material.dart';

import 'screens/detail_screen.dart';
import 'screens/game_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

/// Argumentos de la ruta del juego.
class JuegoArgs {
  final bool continuar;
  const JuegoArgs({this.continuar = false});
}

/// Sistema de rutas centralizado: todas las rutas de la app están aquí
/// (rutas con nombre + onGenerateRoute). Ninguna pantalla crea
/// MaterialPageRoute por su cuenta.
class Rutas {
  Rutas._();

  static const String login = '/';
  static const String principal = '/principal';
  static const String juego = '/juego';
  static const String detalle = '/detalle';

  static Route<dynamic> generar(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case principal:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainShell(),
        );
      case juego:
        final args = settings.arguments is JuegoArgs
            ? settings.arguments as JuegoArgs
            : const JuegoArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => GameScreen(continuar: args.continuar),
        );
      case detalle:
        // Solo se pasa el id: la pantalla de detalle consulta la BD.
        final id = settings.arguments as int;
        return MaterialPageRoute<bool>(
          settings: settings,
          builder: (_) => DetailScreen(partidaId: id),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
