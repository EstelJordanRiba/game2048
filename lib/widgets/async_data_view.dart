import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'empty_state_view.dart';

/// Gestiona los estados de un Future: cargando, error (con botón de
/// reintento), vacío o contenido.
/// Reutilizado en: Historial, Ranking y Detalle de partida.
///
/// Los estados de carga, error y vacío se devuelven dentro de un ListView
/// para que funcione «arrastrar hacia abajo» (RefreshIndicator).
class AsyncDataView<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T datos) builder;
  final VoidCallback onRetry;
  final bool Function(T datos)? estaVacio;
  final IconData iconoVacio;
  final String mensajeVacio;

  const AsyncDataView({
    super.key,
    required this.future,
    required this.builder,
    required this.onRetry,
    this.estaVacio,
    this.iconoVacio = Icons.inbox_outlined,
    this.mensajeVacio = 'No hay datos que mostrar',
  });

  Widget _desplazable(Widget hijo) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: AppConstantes.espacioXl * 2),
          Center(child: hijo),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return _desplazable(
            EmptyStateView(
              icono: Icons.error_outline,
              mensaje: 'Ha ocurrido un error:\n${snapshot.error}',
              accion: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ),
          );
        }
        // Cargando (si ya había datos se siguen mostrando mientras recarga)
        if (!snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Future completado con null
            return _desplazable(
              EmptyStateView(icono: iconoVacio, mensaje: mensajeVacio),
            );
          }
          return _desplazable(const CircularProgressIndicator());
        }
        final datos = snapshot.data as T;
        if (estaVacio?.call(datos) ?? false) {
          return _desplazable(
            EmptyStateView(icono: iconoVacio, mensaje: mensajeVacio),
          );
        }
        return builder(context, datos);
      },
    );
  }
}
