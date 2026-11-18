import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'preferencias_service.dart';

/// Gestor de estado de las preferencias (ChangeNotifier).
/// Cuando cambia el tema o la paleta, notifica y toda la app se redibuja
/// al instante, sin reiniciarla.
class AjustesController extends ChangeNotifier {
  final PreferenciasService _servicio;

  AjustesController(this._servicio);

  ThemeMode _modoTema = ThemeMode.system;
  PaletaFichas _paleta = PaletaFichas.clasica;
  bool _vibracion = true;

  ThemeMode get modoTema => _modoTema;
  PaletaFichas get paleta => _paleta;
  bool get vibracion => _vibracion;

  /// Se llama ANTES de runApp para evitar el parpadeo de tema incorrecto.
  Future<void> cargar() async {
    _modoTema = await _servicio.leerModoTema();
    _paleta = await _servicio.leerPaletaFichas();
    _vibracion = await _servicio.leerVibracion();
  }

  Future<void> cambiarModoTema(ThemeMode modo) async {
    if (modo == _modoTema) return;
    _modoTema = modo;
    notifyListeners();
    await _servicio.guardarModoTema(modo);
  }

  Future<void> cambiarPaleta(PaletaFichas paleta) async {
    if (paleta == _paleta) return;
    _paleta = paleta;
    notifyListeners();
    await _servicio.guardarPaletaFichas(paleta);
  }

  Future<void> cambiarVibracion(bool activa) async {
    _vibracion = activa;
    notifyListeners();
    await _servicio.guardarVibracion(activa);
  }
}

/// Hace accesible el [AjustesController] a cualquier widget con
/// `AjustesScope.of(context)` y lo redibuja cuando cambia.
class AjustesScope extends InheritedNotifier<AjustesController> {
  const AjustesScope({
    super.key,
    required AjustesController controller,
    required super.child,
  }) : super(notifier: controller);

  static AjustesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AjustesScope>();
    assert(scope != null, 'No hay AjustesScope en el árbol de widgets');
    return scope!.notifier!;
  }
}
