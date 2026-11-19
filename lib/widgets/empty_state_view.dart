import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Mensaje e icono para cuando no hay datos que mostrar.
/// Reutilizado en: Historial, Ranking y Detalle (partida inexistente).
class EmptyStateView extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final Widget? accion;

  const EmptyStateView({
    super.key,
    required this.icono,
    required this.mensaje,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppConstantes.espacioXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 64, color: colores.outline),
          const SizedBox(height: AppConstantes.espacioM),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (accion != null) ...[
            const SizedBox(height: AppConstantes.espacioM),
            accion!,
          ],
        ],
      ),
    );
  }
}
