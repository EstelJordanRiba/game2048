/// Funciones de formato reutilizadas en varias pantallas.
class Formato {
  Formato._();

  static String _dosDigitos(int n) => n.toString().padLeft(2, '0');

  /// '2026-11-17T18:05:00.000' -> '17/11/2026 18:05'
  static String fecha(String iso) {
    final f = DateTime.tryParse(iso);
    if (f == null) return iso;
    return '${_dosDigitos(f.day)}/${_dosDigitos(f.month)}/${f.year} '
        '${_dosDigitos(f.hour)}:${_dosDigitos(f.minute)}';
  }

  /// 125 -> '02:05'   3725 -> '1:02:05'
  static String duracion(int segundos) {
    final h = segundos ~/ 3600;
    final m = (segundos % 3600) ~/ 60;
    final s = segundos % 60;
    if (h > 0) return '$h:${_dosDigitos(m)}:${_dosDigitos(s)}';
    return '${_dosDigitos(m)}:${_dosDigitos(s)}';
  }
}
