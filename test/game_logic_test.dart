import 'package:flutter_test/flutter_test.dart';
import 'package:game2048/logic/game_logic.dart';

void main() {
  test('fusiona dos fichas iguales hacia la izquierda', () {
    final juego = GameLogic();
    juego.restaurar([
      2, 2, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0,
    ], 0, 0);

    final haCambiado = juego.mover(Direccion.izquierda);

    expect(haCambiado, isTrue);
    expect(juego.tablero[0], 4);
    expect(juego.puntuacion, 4);
    expect(juego.movimientos, 1);
  });

  test('no hay movimientos con el tablero lleno y sin parejas', () {
    final juego = GameLogic();
    juego.restaurar([
      2, 4, 2, 4,
      4, 2, 4, 2,
      2, 4, 2, 4,
      4, 2, 4, 2,
    ], 0, 0);

    expect(juego.hayMovimientos, isFalse);
  });
}
