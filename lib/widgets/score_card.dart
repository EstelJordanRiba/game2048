import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Etiqueta + valor (por ejemplo «PUNTOS» / «1024»).
/// Reutilizado en: pantalla de juego e Inicio.
class ScoreCard extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const ScoreCard({super.key, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstantes.espacioM,
        vertical: AppConstantes.espacioS,
      ),
      decoration: BoxDecoration(
        color: colores.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstantes.radioTarjeta),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            etiqueta.toUpperCase(),
            style: AppTextos.etiqueta
                .copyWith(color: colores.onPrimaryContainer),
          ),
          const SizedBox(height: AppConstantes.espacioXs),
          FittedBox(
            child: Text(
              valor,
              style: AppTextos.valor.copyWith(color: colores.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
