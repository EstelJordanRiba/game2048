import 'dart:math';

import '../theme/app_theme.dart';

enum Direccion { arriba, abajo, izquierda, derecha }

/// Lógica pura del 2048 (sin widgets ni base de datos).
/// El tablero es una lista de 16 enteros por filas (0 = vacío).
class GameLogic {
  static const int lado = AppConstantes.tamanoTablero;
  static const int totalCasillas = lado * lado;

  final Random _random;

  List<int> tablero = List.filled(totalCasillas, 0);
  int puntuacion = 0;
  int movimientos = 0;

  /// Índice de la última ficha aparecida y de las fichas fusionadas
  /// en el último movimiento (se usan para las animaciones).
  int? ultimaNueva;
  Set<int> fusionadas = {};

  GameLogic({Random? random}) : _random = random ?? Random();

  /// Empieza una partida nueva con dos fichas.
  void nuevaPartida() {
    tablero = List.filled(totalCasillas, 0);
    puntuacion = 0;
    movimientos = 0;
    fusionadas = {};
    _anadirFichaAleatoria();
    _anadirFichaAleatoria();
  }

  /// Restaura una partida guardada en la base de datos.
  void restaurar(List<int> valores, int puntos, int movs) {
    tablero = List.of(valores);
    puntuacion = puntos;
    movimientos = movs;
    ultimaNueva = null;
    fusionadas = {};
  }

  int get fichaMaxima => tablero.reduce(max);

  /// Mueve las fichas. Devuelve true si el tablero ha cambiado.
  bool mover(Direccion direccion) {
    var haCambiado = false;
    final nuevasFusionadas = <int>{};

    for (var linea = 0; linea < lado; linea++) {
      final indices = _indicesLinea(linea, direccion);
      final valores = indices.map((i) => tablero[i]).where((v) => v != 0).toList();

      final resultado = <int>[];
      var i = 0;
      while (i < valores.length) {
        if (i + 1 < valores.length && valores[i] == valores[i + 1]) {
          final suma = valores[i] * 2;
          resultado.add(suma);
          puntuacion += suma;
          nuevasFusionadas.add(indices[resultado.length - 1]);
          i += 2;
        } else {
          resultado.add(valores[i]);
          i++;
        }
      }
      while (resultado.length < lado) {
        resultado.add(0);
      }

      for (var k = 0; k < lado; k++) {
        if (tablero[indices[k]] != resultado[k]) {
          tablero[indices[k]] = resultado[k];
          haCambiado = true;
        }
      }
    }

    if (haCambiado) {
      movimientos++;
      fusionadas = nuevasFusionadas;
      _anadirFichaAleatoria();
    }
    return haCambiado;
  }

  /// La partida termina cuando no quedan casillas vacías ni fusiones posibles.
  bool get hayMovimientos {
    if (tablero.contains(0)) return true;
    for (var f = 0; f < lado; f++) {
      for (var c = 0; c < lado; c++) {
        final v = tablero[f * lado + c];
        if (c + 1 < lado && v == tablero[f * lado + c + 1]) return true;
        if (f + 1 < lado && v == tablero[(f + 1) * lado + c]) return true;
      }
    }
    return false;
  }

  /// Índices de una fila o columna en el orden en que se desplazan las fichas.
  List<int> _indicesLinea(int linea, Direccion direccion) {
    final rango = List.generate(lado, (k) => k);
    switch (direccion) {
      case Direccion.izquierda:
        return rango.map((c) => linea * lado + c).toList();
      case Direccion.derecha:
        return rango.reversed.map((c) => linea * lado + c).toList();
      case Direccion.arriba:
        return rango.map((f) => f * lado + linea).toList();
      case Direccion.abajo:
        return rango.reversed.map((f) => f * lado + linea).toList();
    }
  }

  /// Nueva ficha en una casilla vacía: 90 % un 2 y 10 % un 4.
  void _anadirFichaAleatoria() {
    final vacias = <int>[
      for (var i = 0; i < totalCasillas; i++)
        if (tablero[i] == 0) i,
    ];
    if (vacias.isEmpty) {
      ultimaNueva = null;
      return;
    }
    final indice = vacias[_random.nextInt(vacias.length)];
    tablero[indice] = _random.nextDouble() < 0.9 ? 2 : 4;
    ultimaNueva = indice;
  }
}
