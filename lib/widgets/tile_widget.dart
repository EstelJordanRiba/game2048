import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dibuja una ficha del tablero según su valor.
/// Reutilizado en: pantalla de juego (tablero), detalle de partida y Ajustes.
class TileWidget extends StatelessWidget {
  final int valor;
  final PaletaFichas paleta;

  const TileWidget({super.key, required this.valor, required this.paleta});

  @override
  Widget build(BuildContext context) {
    final vacia = valor == 0;
    return AnimatedContainer(
      duration: AppConstantes.animacionColor,
      decoration: BoxDecoration(
        color: vacia
            ? AppTheme.colorCasillaVacia(context)
            : paleta.colorFicha(valor),
        borderRadius: BorderRadius.circular(AppConstantes.radioFicha),
      ),
      alignment: Alignment.center,
      // Animación implícita: la ficha «crece» al aparecer o al fusionarse.
      child: AnimatedSwitcher(
        duration: AppConstantes.animacionFicha,
        transitionBuilder: (child, animacion) =>
            ScaleTransition(scale: animacion, child: child),
        child: vacia
            ? const SizedBox.shrink(key: ValueKey<int>(0))
            : Padding(
                key: ValueKey<int>(valor),
                padding: const EdgeInsets.all(AppConstantes.espacioXs),
                child: FittedBox(
                  child: Text(
                    '$valor',
                    style: TextStyle(
                      fontSize: AppTextos.tamanoTextoFicha(valor),
                      fontWeight: FontWeight.w900,
                      color: paleta.colorTexto(valor),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
