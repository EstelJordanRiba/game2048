import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dibuja una ficha del tablero según su valor: un gatito cuadrado.
/// El color del gatito depende del valor (paleta) y el número va sobre una
/// placa clara para que siempre se lea bien.
/// Reutilizado en: pantalla de juego (tablero), detalle de partida y Ajustes.
class TileWidget extends StatelessWidget {
  final int valor;
  final PaletaFichas paleta;

  const TileWidget({super.key, required this.valor, required this.paleta});

  @override
  Widget build(BuildContext context) {
    final vacia = valor == 0;
    if (vacia) {
      return AnimatedContainer(
        duration: AppConstantes.animacionColor,
        decoration: BoxDecoration(
          color: AppTheme.colorCasillaVacia(context),
          borderRadius: BorderRadius.circular(AppConstantes.radioFicha),
        ),
      );
    }
    return CustomPaint(
      painter: _GatitoPainter(paleta.colorFicha(valor)),
      // Animación implícita: el gatito «crece» al aparecer o al fusionarse.
      child: AnimatedSwitcher(
        duration: AppConstantes.animacionFicha,
        transitionBuilder: (child, animacion) =>
            ScaleTransition(scale: animacion, child: child),
        child: LayoutBuilder(
          key: ValueKey<int>(valor),
          builder: (context, c) {
            final lado = c.biggest.shortestSide;
            return Align(
              alignment: const Alignment(0, 0.45),
              child: Container(
                width: lado * 0.78,
                height: lado * 0.44,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(lado * 0.14),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  child: Text(
                    '$valor',
                    style: TextStyle(
                      fontSize: AppTextos.tamanoTextoFicha(valor),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF3B2F2F),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Cara de gatito cuadrada: orejas, ojos, nariz, boca y bigotes.
class _GatitoPainter extends CustomPainter {
  final Color color;
  const _GatitoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final relleno = Paint()..color = color;
    final oscuro = Paint()..color = const Color(0xFF3B2F2F);
    final orejaInterior = Paint()..color = const Color(0xFFFFB6C1);

    // Orejas (triángulos en las esquinas superiores).
    for (final izq in [true, false]) {
      final x0 = izq ? 0.0 : w;
      final dir = izq ? 1.0 : -1.0;
      final oreja = Path()
        ..moveTo(x0, h * 0.32)
        ..lineTo(x0 + dir * w * 0.05, 0)
        ..lineTo(x0 + dir * w * 0.36, h * 0.16)
        ..close();
      canvas.drawPath(oreja, relleno);
      final interior = Path()
        ..moveTo(x0 + dir * w * 0.06, h * 0.22)
        ..lineTo(x0 + dir * w * 0.09, h * 0.07)
        ..lineTo(x0 + dir * w * 0.25, h * 0.16)
        ..close();
      canvas.drawPath(interior, orejaInterior);
    }

    // Cabeza cuadrada con esquinas suaves.
    final cabeza = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.12, w, h * 0.88),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(cabeza, relleno);

    // Ojos.
    canvas.drawCircle(Offset(w * 0.30, h * 0.34), w * 0.055, oscuro);
    canvas.drawCircle(Offset(w * 0.70, h * 0.34), w * 0.055, oscuro);

    // Nariz.
    final nariz = Path()
      ..moveTo(w * 0.455, h * 0.43)
      ..lineTo(w * 0.545, h * 0.43)
      ..lineTo(w * 0.5, h * 0.49)
      ..close();
    canvas.drawPath(nariz, Paint()..color = const Color(0xFFFF8FA3));

    // Bigotes.
    final bigote = Paint()
      ..color = const Color(0xFF3B2F2F).withOpacity(0.7)
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round;
    for (final dy in [0.40, 0.47]) {
      canvas.drawLine(Offset(w * 0.04, h * dy), Offset(w * 0.22, h * (dy + 0.02)), bigote);
      canvas.drawLine(Offset(w * 0.96, h * dy), Offset(w * 0.78, h * (dy + 0.02)), bigote);
    }
  }

  @override
  bool shouldRepaint(_GatitoPainter old) => old.color != color;
}
