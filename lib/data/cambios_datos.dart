import 'package:flutter/foundation.dart';

/// Aviso global de que los datos de la BD han cambiado.
/// Los DAO llaman a [notificar] tras insertar o borrar, y las pantallas
/// de historial, ranking e inicio se recargan solas sin reiniciar la app.
class CambiosDatos extends ChangeNotifier {
  CambiosDatos._();
  static final CambiosDatos instancia = CambiosDatos._();

  void notificar() => notifyListeners();
}
