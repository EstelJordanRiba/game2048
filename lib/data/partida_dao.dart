import 'package:sqflite/sqflite.dart';

import '../models/estadisticas.dart';
import '../models/partida.dart';
import 'cambios_datos.dart';
import 'database_helper.dart';
import 'datos_exception.dart';

/// DAO de la tabla `partidas` (historial).
/// Ninguna pantalla contiene SQL: todo pasa por aquí.
/// Todas las consultas usan whereArgs (?), nunca concatenación.
class PartidaDao {
  final DatabaseHelper _helper = DatabaseHelper.instancia;
  static const String _tabla = DatabaseHelper.tablaPartidas;

  // ---------------------------------------------------------------- CRUD

  Future<int> insertar(Partida partida) async {
    try {
      final db = await _helper.database;
      final id = await db.insert(_tabla, partida.toMap());
      CambiosDatos.instancia.notificar();
      return id;
    } catch (e) {
      throw DatosException('No se ha podido guardar la partida', e);
    }
  }

  /// Historial completo ordenado por fecha descendente, con filtros opcionales
  /// por nombre de jugador y ficha máxima mínima.
  Future<List<Partida>> obtenerHistorial({
    String? jugador,
    int? fichaMinima,
  }) async {
    try {
      final db = await _helper.database;
      final condiciones = <String>[];
      final argumentos = <Object?>[];

      if (jugador != null && jugador.trim().isNotEmpty) {
        condiciones.add('usuario LIKE ?');
        argumentos.add('%${jugador.trim()}%');
      }
      if (fichaMinima != null && fichaMinima > 0) {
        condiciones.add('ficha_maxima >= ?');
        argumentos.add(fichaMinima);
      }

      final filas = await db.query(
        _tabla,
        where: condiciones.isEmpty ? null : condiciones.join(' AND '),
        whereArgs: argumentos.isEmpty ? null : argumentos,
        orderBy: 'fecha DESC',
      );
      return filas.map(Partida.fromMap).toList();
    } catch (e) {
      throw DatosException('No se ha podido cargar el historial', e);
    }
  }

  Future<Partida?> obtenerPorId(int id) async {
    try {
      final db = await _helper.database;
      final filas = await db.query(
        _tabla,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return filas.isEmpty ? null : Partida.fromMap(filas.first);
    } catch (e) {
      throw DatosException('No se ha podido cargar la partida', e);
    }
  }

  Future<int> eliminar(int id) async {
    try {
      final db = await _helper.database;
      final n = await db.delete(_tabla, where: 'id = ?', whereArgs: [id]);
      CambiosDatos.instancia.notificar();
      return n;
    } catch (e) {
      throw DatosException('No se ha podido eliminar la partida', e);
    }
  }

  /// Vuelve a insertar una partida borrada con su mismo id (acción «Deshacer»).
  Future<void> restaurar(Partida partida) async {
    try {
      final db = await _helper.database;
      await db.insert(_tabla, partida.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      CambiosDatos.instancia.notificar();
    } catch (e) {
      throw DatosException('No se ha podido restaurar la partida', e);
    }
  }

  Future<int> eliminarTodo() async {
    try {
      final db = await _helper.database;
      final n = await db.delete(_tabla);
      CambiosDatos.instancia.notificar();
      return n;
    } catch (e) {
      throw DatosException('No se ha podido borrar el historial', e);
    }
  }

  // --------------------------------------------------------- TRANSACCIÓN

  /// Al terminar una partida: se inserta en el historial y se elimina la
  /// partida guardada de forma atómica (o se hacen las dos cosas o ninguna).
  Future<int> finalizarPartida(Partida partida) async {
    try {
      final db = await _helper.database;
      final id = await db.transaction<int>((txn) async {
        final nuevoId = await txn.insert(_tabla, partida.toMap());
        await txn.delete(
          DatabaseHelper.tablaPartidaGuardada,
          where: 'id = ?',
          whereArgs: [1],
        );
        return nuevoId;
      });
      CambiosDatos.instancia.notificar();
      return id;
    } catch (e) {
      throw DatosException('No se ha podido registrar el final de partida', e);
    }
  }

  // ------------------------------------------ CONSULTAS CON AGREGACIONES

  /// Ranking: las 10 mejores partidas (ORDER BY + LIMIT).
  Future<List<Partida>> ranking({int limite = 10}) async {
    try {
      final db = await _helper.database;
      final filas = await db.query(
        _tabla,
        orderBy: 'puntuacion DESC, fecha ASC',
        limit: limite,
      );
      return filas.map(Partida.fromMap).toList();
    } catch (e) {
      throw DatosException('No se ha podido cargar el ranking', e);
    }
  }

  /// Estadísticas globales (COUNT, MAX, AVG, SUM).
  Future<EstadisticasGlobales> estadisticasGlobales() async {
    try {
      final db = await _helper.database;
      final filas = await db.rawQuery('''
        SELECT COUNT(*) AS partidas,
               MAX(puntuacion) AS maxima,
               AVG(puntuacion) AS media,
               MAX(ficha_maxima) AS ficha,
               SUM(duracion_segundos) AS tiempo
        FROM $_tabla
      ''');
      return EstadisticasGlobales.fromMap(filas.first);
    } catch (e) {
      throw DatosException('No se han podido calcular las estadísticas', e);
    }
  }

  /// Mejor puntuación y número de partidas de cada jugador (GROUP BY).
  Future<List<EstadisticaJugador>> estadisticasPorJugador() async {
    try {
      final db = await _helper.database;
      final filas = await db.rawQuery('''
        SELECT usuario,
               MAX(puntuacion) AS mejor,
               COUNT(*) AS partidas
        FROM $_tabla
        GROUP BY usuario
        ORDER BY mejor DESC
      ''');
      return filas.map(EstadisticaJugador.fromMap).toList();
    } catch (e) {
      throw DatosException('No se han podido calcular las estadísticas', e);
    }
  }

  /// Mejor puntuación registrada (para la pantalla de inicio y de juego).
  Future<int> mejorPuntuacion() async {
    try {
      final db = await _helper.database;
      final filas =
          await db.rawQuery('SELECT MAX(puntuacion) AS mejor FROM $_tabla');
      return (filas.first['mejor'] as int?) ?? 0;
    } catch (e) {
      throw DatosException('No se ha podido leer la mejor puntuación', e);
    }
  }
}
