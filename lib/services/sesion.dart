import '../models/usuario.dart';

/// Usuario que ha iniciado sesión en esta ejecución de la app.
class Sesion {
  Sesion._();

  static Usuario? usuarioActual;

  static bool get iniciada => usuarioActual != null;

  static String get nombre => usuarioActual?.usuario ?? 'Invitado';

  static void cerrar() => usuarioActual = null;
}
