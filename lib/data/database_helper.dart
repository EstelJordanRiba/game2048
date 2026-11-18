import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Clase auxiliar de base de datos (patrón singleton).
/// Abre `game2048.db`, crea las tablas y gestiona las migraciones.
class DatabaseHelper {
  static const String nombreBd = 'game2048.db';

  /// Versión 1: tablas usuarios, partidas y partida_guardada.
  /// Versión 2: se añade la columna `tamano_tablero` a `partidas`.
  static const int versionBd = 2;

  // Nombres de tablas como constantes (no se repiten cadenas por el código)
  static const String tablaUsuarios = 'usuarios';
  static const String tablaPartidas = 'partidas';
  static const String tablaPartidaGuardada = 'partida_guardada';

  DatabaseHelper._interno();
  static final DatabaseHelper instancia = DatabaseHelper._interno();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), nombreBd);
    return openDatabase(
      ruta,
      version: versionBd,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Se activan las claves foráneas (en SQLite vienen desactivadas).
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Instalación nueva: se crea la versión 1 y se aplican las migraciones
  /// hasta la versión actual, así el esquema es idéntico al de una
  /// instalación que se ha ido actualizando.
  Future<void> _onCreate(Database db, int version) async {
    await _crearEsquemaV1(db);
    if (version >= 2) await _migrarAV2(db);
  }

  /// Actualización: se aplican solo las migraciones que faltan.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _migrarAV2(db);
  }

  Future<void> _crearEsquemaV1(Database db) async {
    await db.execute('''
      CREATE TABLE $tablaUsuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL UNIQUE,
        fecha_registro TEXT NOT NULL,
        email TEXT NOT NULL,
        contrasena TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaPartidas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER,
        usuario TEXT NOT NULL,
        puntuacion INTEGER NOT NULL,
        ficha_maxima INTEGER NOT NULL,
        movimientos INTEGER NOT NULL,
        duracion_segundos INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES $tablaUsuarios (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaPartidaGuardada (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        tablero TEXT NOT NULL,
        puntuacion INTEGER NOT NULL,
        movimientos INTEGER NOT NULL,
        segundos_transcurridos INTEGER NOT NULL
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_partidas_puntuacion ON $tablaPartidas (puntuacion)');
  }

  /// Migración 1 -> 2: nueva columna con valor por defecto 4.
  /// ALTER TABLE ADD COLUMN conserva todas las filas existentes.
  Future<void> _migrarAV2(Database db) async {
    await db.execute(
        'ALTER TABLE $tablaPartidas ADD COLUMN tamano_tablero INTEGER NOT NULL DEFAULT 4');
  }

  Future<void> cerrar() async {
    await _db?.close();
    _db = null;
  }
}
