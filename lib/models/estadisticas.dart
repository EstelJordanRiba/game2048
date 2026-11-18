/// Resultado de las consultas con agregaciones (COUNT, MAX, AVG, SUM).
class EstadisticasGlobales {
  final int partidasJugadas;
  final int puntuacionMaxima;
  final double puntuacionMedia;
  final int fichaMaxima;
  final int tiempoTotalSegundos;

  const EstadisticasGlobales({
    required this.partidasJugadas,
    required this.puntuacionMaxima,
    required this.puntuacionMedia,
    required this.fichaMaxima,
    required this.tiempoTotalSegundos,
  });

  factory EstadisticasGlobales.fromMap(Map<String, Object?> map) =>
      EstadisticasGlobales(
        partidasJugadas: (map['partidas'] as int?) ?? 0,
        puntuacionMaxima: (map['maxima'] as int?) ?? 0,
        puntuacionMedia: ((map['media'] as num?) ?? 0).toDouble(),
        fichaMaxima: (map['ficha'] as int?) ?? 0,
        tiempoTotalSegundos: (map['tiempo'] as int?) ?? 0,
      );
}

/// Estadísticas agrupadas por jugador (GROUP BY usuario).
class EstadisticaJugador {
  final String usuario;
  final int mejorPuntuacion;
  final int partidas;

  const EstadisticaJugador({
    required this.usuario,
    required this.mejorPuntuacion,
    required this.partidas,
  });

  factory EstadisticaJugador.fromMap(Map<String, Object?> map) =>
      EstadisticaJugador(
        usuario: map['usuario'] as String,
        mejorPuntuacion: (map['mejor'] as int?) ?? 0,
        partidas: (map['partidas'] as int?) ?? 0,
      );
}
