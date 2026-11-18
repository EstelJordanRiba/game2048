import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../models/usuario.dart';
import 'database_helper.dart';

/// Resultado del registro o del login.
class ResultadoAuth {
  final Usuario? usuario;
  final String? error;
  const ResultadoAuth.exito(this.usuario) : error = null;
  const ResultadoAuth.fallo(this.error) : usuario = null;
  bool get ok => usuario != null;
}

/// DAO de la tabla `usuarios`. Todas las consultas son parametrizadas.
class UsuarioDao {
  final DatabaseHelper _helper = DatabaseHelper.instancia;
  static const String _tabla = DatabaseHelper.tablaUsuarios;

  static final RegExp _regexEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool emailValido(String email) => _regexEmail.hasMatch(email.trim());

  /// La contraseña se guarda cifrada con SHA-256.
  static String cifrar(String contrasena) =>
      sha256.convert(utf8.encode(contrasena)).toString();

  Future<ResultadoAuth> registrar({
    required String usuario,
    required String email,
    required String contrasena,
  }) async {
    try {
      final nombre = usuario.trim();
      if (nombre.isEmpty) {
        return const ResultadoAuth.fallo('El nombre de usuario es obligatorio');
      }
      if (!emailValido(email)) {
        return const ResultadoAuth.fallo('El email no tiene un formato válido');
      }
      if (contrasena.length < 4) {
        return const ResultadoAuth.fallo(
            'La contraseña debe tener al menos 4 caracteres');
      }
      if (await buscarPorNombre(nombre) != null) {
        return const ResultadoAuth.fallo('Ese nombre de usuario ya existe');
      }

      final nuevo = Usuario(
        usuario: nombre,
        fechaRegistro: DateTime.now().toIso8601String(),
        email: email.trim(),
        contrasena: cifrar(contrasena),
      );
      final db = await _helper.database;
      final id = await db.insert(_tabla, nuevo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);
      return ResultadoAuth.exito(Usuario(
        id: id,
        usuario: nuevo.usuario,
        fechaRegistro: nuevo.fechaRegistro,
        email: nuevo.email,
        contrasena: nuevo.contrasena,
      ));
    } catch (e) {
      return ResultadoAuth.fallo('Error al registrar: $e');
    }
  }

  Future<ResultadoAuth> login(String usuario, String contrasena) async {
    try {
      final db = await _helper.database;
      final filas = await db.query(
        _tabla,
        where: 'usuario = ? AND contrasena = ?',
        whereArgs: [usuario.trim(), cifrar(contrasena)],
        limit: 1,
      );
      if (filas.isEmpty) {
        return const ResultadoAuth.fallo('Usuario o contraseña incorrectos');
      }
      return ResultadoAuth.exito(Usuario.fromMap(filas.first));
    } catch (e) {
      return ResultadoAuth.fallo('Error al iniciar sesión: $e');
    }
  }

  Future<Usuario?> buscarPorNombre(String usuario) async {
    final db = await _helper.database;
    final filas = await db.query(
      _tabla,
      where: 'usuario = ?',
      whereArgs: [usuario],
      limit: 1,
    );
    return filas.isEmpty ? null : Usuario.fromMap(filas.first);
  }
}
