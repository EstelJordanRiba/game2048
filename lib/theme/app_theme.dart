import 'package:flutter/material.dart';

/// Constantes visuales: ningún valor de tamaño o espaciado se repite a mano.
class AppConstantes {
  static const double espacioXs = 4;
  static const double espacioS = 8;
  static const double espacioM = 16;
  static const double espacioL = 24;
  static const double espacioXl = 32;

  static const double radioFicha = 8;
  static const double radioTarjeta = 12;
  static const double separacionFichas = 8;
  static const double anchoMaximoTablero = 420;

  static const int tamanoTablero = 4;
  static const double umbralSwipe = 24; // px mínimos para aceptar un deslizamiento

  static const Duration animacionFicha = Duration(milliseconds: 150);
  static const Duration animacionColor = Duration(milliseconds: 200);
}

/// Estilos de texto reutilizados.
class AppTextos {
  static const TextStyle tituloJuego =
      TextStyle(fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -1);
  static const TextStyle etiqueta =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1);
  static const TextStyle valor =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w800);

  static double tamanoTextoFicha(int valor) {
    if (valor < 100) return 32;
    if (valor < 1000) return 28;
    if (valor < 10000) return 22;
    return 18;
  }
}

/// Paletas de colores de las fichas que el usuario puede elegir en Ajustes.
enum PaletaFichas { clasica, oceano, bosque }

extension PaletaFichasX on PaletaFichas {
  String get nombre => switch (this) {
        PaletaFichas.clasica => 'Clásica',
        PaletaFichas.oceano => 'Océano',
        PaletaFichas.bosque => 'Bosque',
      };

  /// Colores base de cada paleta, de la ficha 2 a la 2048.
  List<Color> get _colores => switch (this) {
        PaletaFichas.clasica => const [
            Color(0xFFEEE4DA), Color(0xFFEDE0C8), Color(0xFFF2B179),
            Color(0xFFF59563), Color(0xFFF67C5F), Color(0xFFF65E3B),
            Color(0xFFEDCF72), Color(0xFFEDCC61), Color(0xFFEDC850),
            Color(0xFFEDC53F), Color(0xFFEDC22E),
          ],
        PaletaFichas.oceano => const [
            Color(0xFFE0F2F1), Color(0xFFB2EBF2), Color(0xFF80DEEA),
            Color(0xFF4DD0E1), Color(0xFF26C6DA), Color(0xFF00ACC1),
            Color(0xFF0097A7), Color(0xFF00838F), Color(0xFF006064),
            Color(0xFF01579B), Color(0xFF0D47A1),
          ],
        PaletaFichas.bosque => const [
            Color(0xFFF1F8E9), Color(0xFFDCEDC8), Color(0xFFC5E1A5),
            Color(0xFFAED581), Color(0xFF9CCC65), Color(0xFF8BC34A),
            Color(0xFF7CB342), Color(0xFF689F38), Color(0xFF558B2F),
            Color(0xFF33691E), Color(0xFF1B5E20),
          ],
      };

  Color colorFicha(int valor) {
    if (valor <= 0) return Colors.transparent;
    var indice = 0;
    var v = valor;
    while (v > 2) {
      v ~/= 2;
      indice++;
    }
    final colores = _colores;
    return indice < colores.length ? colores[indice] : const Color(0xFF3C3A32);
  }

  /// Color del número: oscuro sobre fichas claras y blanco sobre oscuras,
  /// así es legible tanto en modo claro como en oscuro.
  Color colorTexto(int valor) {
    final fondo = colorFicha(valor);
    return fondo.computeLuminance() > 0.45
        ? const Color(0xFF3C3A32)
        : Colors.white;
  }
}

/// Temas claro y oscuro de la aplicación.
class AppTheme {
  static const Color semilla = Color(0xFFF59563);

  // Colores del tablero según el modo
  static const Color tableroClaro = Color(0xFFBBADA0);
  static const Color tableroOscuro = Color(0xFF3A3530);
  static const Color casillaClara = Color(0xFFCDC1B4);
  static const Color casillaOscura = Color(0xFF4D4740);

  static ThemeData get claro => _construir(Brightness.light);
  static ThemeData get oscuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    final esquema =
        ColorScheme.fromSeed(seedColor: semilla, brightness: brillo);
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstantes.radioTarjeta),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstantes.radioTarjeta),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstantes.radioTarjeta),
        ),
      ),
    );
  }

  static Color colorTablero(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? tableroOscuro
          : tableroClaro;

  static Color colorCasillaVacia(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? casillaOscura
          : casillaClara;
}
