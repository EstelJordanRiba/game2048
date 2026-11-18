import 'dart:convert';

/// Modelo de la tabla `partida_guardada` (partida en curso).
/// Solo existe una fila, siempre con id = 1.
class PartidaGuardada {
  static const int idUnico = 1;

  final List<int> tablero; // 16 valores (0 = casilla vacía)
  final int puntuacion;
  final int movimientos;
  final int segundosTranscurridos;

  const PartidaGuardada({
    required this.tablero,
    required this.puntuacion,
    required this.movimientos,
    required this.segundosTranscurridos,
  });

  Map<String, Object?> toMap() => {
        'id': idUnico,
        'tablero': jsonEncode(tablero), // se serializa como JSON
        'puntuacion': puntuacion,
        'movimientos': movimientos,
        'segundos_transcurridos': segundosTranscurridos,
      };

  factory PartidaGuardada.fromMap(Map<String, Object?> map) => PartidaGuardada(
        tablero: (jsonDecode(map['tablero'] as String) as List)
            .map((e) => e as int)
            .toList(),
        puntuacion: map['puntuacion'] as int,
        movimientos: map['movimientos'] as int,
        segundosTranscurridos: map['segundos_transcurridos'] as int,
      );
}
