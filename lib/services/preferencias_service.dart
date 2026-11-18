import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// Servicio que encapsula SharedPreferences (almacenamiento clave-valor).
/// Las claves son constantes: no hay cadenas repetidas por el código.
class PreferenciasService {
  static const String claveModoTema = 'modo_tema';
  static const String clavePaletaFichas = 'paleta_fichas';
  static const String claveUltimoJugador = 'ultimo_jugador';
  static const String claveMejorPuntuacion = 'mejor_puntuacion';
  static const String claveVibracion = 'vibracion';

  PreferenciasService._();
  static final PreferenciasService instancia = PreferenciasService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  // --------------------------------------------------------- Modo de tema

  Future<void> guardarModoTema(ThemeMode modo) async {
    final p = await _p;
    await p.setString(claveModoTema, modo.name);
  }

  /// Si no hay valor guardado, el modo por defecto es ThemeMode.system.
  Future<ThemeMode> leerModoTema() async {
    final p = await _p;
    final valor = p.getString(claveModoTema);
    return ThemeMode.values.firstWhere(
      (m) => m.name == valor,
      orElse: () => ThemeMode.system,
    );
  }

  // ----------------------------------------------------- Colores fichas

  Future<void> guardarPaletaFichas(PaletaFichas paleta) async {
    final p = await _p;
    await p.setString(clavePaletaFichas, paleta.name);
  }

  Future<PaletaFichas> leerPaletaFichas() async {
    final p = await _p;
    final valor = p.getString(clavePaletaFichas);
    return PaletaFichas.values.firstWhere(
      (e) => e.name == valor,
      orElse: () => PaletaFichas.clasica,
    );
  }

  // ------------------------------------------- Ampliaciones opcionales

  Future<void> guardarUltimoJugador(String nombre) async {
    final p = await _p;
    await p.setString(claveUltimoJugador, nombre);
  }

  Future<String?> leerUltimoJugador() async {
    final p = await _p;
    return p.getString(claveUltimoJugador);
  }

  /// Solo se sobrescribe si la nueva puntuación es mayor.
  Future<void> guardarMejorPuntuacion(int puntuacion) async {
    final p = await _p;
    final actual = p.getInt(claveMejorPuntuacion) ?? 0;
    if (puntuacion > actual) {
      await p.setInt(claveMejorPuntuacion, puntuacion);
    }
  }

  Future<int> leerMejorPuntuacion() async {
    final p = await _p;
    return p.getInt(claveMejorPuntuacion) ?? 0;
  }

  Future<void> reiniciarMejorPuntuacion() async {
    final p = await _p;
    await p.remove(claveMejorPuntuacion);
  }

  Future<void> guardarVibracion(bool activa) async {
    final p = await _p;
    await p.setBool(claveVibracion, activa);
  }

  Future<bool> leerVibracion() async {
    final p = await _p;
    return p.getBool(claveVibracion) ?? true;
  }
}
