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

  test('una ficha solo se fusiona una vez por movimiento (2,2,2,2 -> 4,4)', () {
    final juego = GameLogic();
    juego.restaurar([
      2, 2, 2, 2,
      0, 0, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0,
    ], 0, 0);

    juego.mover(Direccion.izquierda);

    expect(juego.tablero[0], 4);
    expect(juego.tablero[1], 4);
    expect(juego.puntuacion, 8);
  });

  test('las fichas se desplazan hacia la derecha y se fusionan', () {
    final juego = GameLogic();
    juego.restaurar([
      2, 0, 2, 0,
      0, 0, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0,
    ], 0, 0);

    juego.mover(Direccion.derecha);

    expect(juego.tablero[3], 4);
    expect(juego.puntuacion, 4);
  });

  test('un movimiento que no cambia el tablero devuelve false', () {
    final juego = GameLogic();
    juego.restaurar([
      2, 4, 2, 4,
      4, 2, 4, 2,
      2, 4, 2, 4,
      4, 2, 4, 2,
    ], 10, 3);

    final haCambiado = juego.mover(Direccion.izquierda);

    expect(haCambiado, isFalse);
    expect(juego.movimientos, 3);
    expect(juego.puntuacion, 10);
  });

  test('tras un movimiento válido aparece una ficha nueva (2 o 4)', () {
    final juego = GameLogic();
    juego.restaurar([
      2, 2, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0,
    ], 0, 0);

    juego.mover(Direccion.izquierda);

    final fichas = juego.tablero.where((v) => v != 0).toList();
    expect(fichas.length, 2); // la fusión (4) y la ficha nueva
    expect(juego.ultimaNueva, isNotNull);
    expect([2, 4], contains(juego.tablero[juego.ultimaNueva!]));
  });

  test('una partida nueva empieza con dos fichas y a cero', () {
    final juego = GameLogic()..nuevaPartida();

    expect(juego.tablero.where((v) => v != 0).length, 2);
    expect(juego.puntuacion, 0);
    expect(juego.movimientos, 0);
  });

  test('la ficha máxima es el mayor valor del tablero', () {
    final juego = GameLogic();
    juego.restaurar([
      2, 0, 0, 0,
      0, 128, 0, 0,
      0, 0, 8, 0,
      0, 0, 0, 0,
    ], 0, 0);

    expect(juego.fichaMaxima, 128);
  });
}
