import 'package:flutter/material.dart';

import '../logic/game_logic.dart';
import '../theme/app_theme.dart';
import 'tile_widget.dart';

/// Dibuja la cuadrícula 4x4 a partir de una lista de valores y reconoce
/// el gesto de deslizar en las cuatro direcciones.
///
/// Se usa GestureDetector con onPanStart/onPanUpdate/onPanEnd (y no
/// onHorizontalDragEnd + onVerticalDragEnd) porque así se acumula el
/// desplazamiento total en los dos ejes y se puede:
///  - ignorar deslizamientos demasiado cortos (umbral mínimo), y
///  - elegir la dirección dominante comparando |dx| con |dy|.
class BoardWidget extends StatefulWidget {
  final List<int> valores;
  final PaletaFichas paleta;
  final ValueChanged<Direccion> onSwipe;

  const BoardWidget({
    super.key,
    required this.valores,
    required this.paleta,
    required this.onSwipe,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  Offset _desplazamiento = Offset.zero;

  Direccion? _calcularDireccion(Offset d) {
    if (d.distance < AppConstantes.umbralSwipe) return null; // demasiado corto
    if (d.dx.abs() > d.dy.abs()) {
      return d.dx > 0 ? Direccion.derecha : Direccion.izquierda;
    }
    return d.dy > 0 ? Direccion.abajo : Direccion.arriba;
  }

  @override
  Widget build(BuildContext context) {
    const lado = AppConstantes.tamanoTablero;
    const sep = AppConstantes.separacionFichas;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) => _desplazamiento = Offset.zero,
      onPanUpdate: (detalles) => _desplazamiento += detalles.delta,
      onPanEnd: (_) {
        final direccion = _calcularDireccion(_desplazamiento);
        if (direccion != null) widget.onSwipe(direccion);
      },
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: AppConstantes.anchoMaximoTablero),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(sep),
            decoration: BoxDecoration(
              color: AppTheme.colorTablero(context),
              borderRadius: BorderRadius.circular(AppConstantes.radioTarjeta),
            ),
            child: Column(
              children: [
                for (var fila = 0; fila < lado; fila++) ...[
                  if (fila > 0) const SizedBox(height: sep),
                  Expanded(
                    child: Row(
                      children: [
                        for (var col = 0; col < lado; col++) ...[
                          if (col > 0) const SizedBox(width: sep),
                          Expanded(
                            child: TileWidget(
                              valor: widget.valores[fila * lado + col],
                              paleta: widget.paleta,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
