import 'package:sqflite/sqflite.dart';

import '../models/partida_guardada.dart';
import 'cambios_datos.dart';
import 'database_helper.dart';
import 'datos_exception.dart';

/// DAO de la tabla `partida_guardada` (partida en curso, id siempre 1).
class PartidaGuardadaDao {
  final DatabaseHelper _helper = DatabaseHelper.instancia;
  static const String _tabla = DatabaseHelper.tablaPartidaGuardada;

  /// Guarda (o sobrescribe) la partida en curso.
  Future<void> guardar(PartidaGuardada partida) async {
    try {
      final db = await _helper.database;
      await db.insert(_tabla, partida.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      CambiosDatos.instancia.notificar();
    } catch (e) {
      throw DatosException('No se ha podido guardar la partida en curso', e);
    }
  }

  Future<PartidaGuardada?> obtener() async {
    try {
      final db = await _helper.database;
      final filas = await db.query(
        _tabla,
        where: 'id = ?',
        whereArgs: [PartidaGuardada.idUnico],
        limit: 1,
      );
      return filas.isEmpty ? null : PartidaGuardada.fromMap(filas.first);
    } catch (e) {
      throw DatosException('No se ha podido recuperar la partida en curso', e);
    }
  }

  Future<bool> existe() async => (await obtener()) != null;

  Future<void> borrar() async {
    try {
      final db = await _helper.database;
      await db.delete(_tabla,
          where: 'id = ?', whereArgs: [PartidaGuardada.idUnico]);
      CambiosDatos.instancia.notificar();
    } catch (e) {
      throw DatosException('No se ha podido borrar la partida en curso', e);
    }
  }
}
