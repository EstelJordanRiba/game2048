/// Error de la capa de datos con un mensaje legible para la interfaz.
class DatosException implements Exception {
  final String mensaje;
  final Object? causa;
  const DatosException(this.mensaje, [this.causa]);

  @override
  String toString() => mensaje;
}
