import 'package:flutter/material.dart';

import 'routes.dart';
import 'services/ajustes_controller.dart';
import 'theme/app_theme.dart';

class Game2048App extends StatelessWidget {
  final AjustesController ajustes;

  const Game2048App({super.key, required this.ajustes});

  @override
  Widget build(BuildContext context) {
    return AjustesScope(
      controller: ajustes,
      // Cuando cambia el modo de tema se reconstruye MaterialApp al instante.
      child: ListenableBuilder(
        listenable: ajustes,
        builder: (context, _) => MaterialApp(
          title: '2048',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          themeMode: ajustes.modoTema,
          initialRoute: Rutas.login,
          onGenerateRoute: Rutas.generar,
        ),
      ),
    );
  }
}
