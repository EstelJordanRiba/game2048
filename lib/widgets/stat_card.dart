import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tarjeta con icono, título y valor para una estadística.
/// Reutilizado en: Ranking y estadísticas, y Detalle de partida.
class StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;

  const StatCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppConstantes.espacioM),
        child: Row(
          children: [
            Icon(icono, color: colores.primary),
            const SizedBox(width: AppConstantes.espacioM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstantes.espacioXs),
                  Text(
                    valor,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
