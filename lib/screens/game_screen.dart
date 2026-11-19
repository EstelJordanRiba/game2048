import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/partida_dao.dart';
import '../data/partida_guardada_dao.dart';
import '../logic/game_logic.dart';
import '../models/partida.dart';
import '../models/partida_guardada.dart';
import '../services/ajustes_controller.dart';
import '../services/preferencias_service.dart';
import '../services/sesion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/board_widget.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/score_card.dart';

enum _OpcionSalida { guardar, salirSinGuardar, cancelar }

enum _OpcionFin { jugarDeNuevo, volver }

/// Pantalla de juego: tablero 4x4, puntuación, mejor puntuación,
/// movimientos, cronómetro y botón de reinicio.
class GameScreen extends StatefulWidget {
  final bool continuar;

  const GameScreen({super.key, this.continuar = false});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final _juego = GameLogic();
  final _partidaDao = PartidaDao();
  final _guardadaDao = PartidaGuardadaDao();
  final _prefs = PreferenciasService.instancia;
  final _foco = FocusNode();

  Timer? _cronometro;
  int _segundos = 0;
  int _mejor = 0;
  bool _cargando = true;
  bool _terminada = false;
  bool _mostrarDetalles = true; // se alterna con doble toque en la puntuación
  bool _vibracion = true; // preferencia leída de AjustesScope en build()

  @override
  void initState() {
    super.initState();
    // Para guardar la partida al pasar la app a segundo plano.
    WidgetsBinding.instance.addObserver(this);
    _iniciar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cronometro?.cancel();
    _foco.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ Arranque

  Future<void> _iniciar() async {
    try {
      PartidaGuardada? guardada;
      if (widget.continuar) guardada = await _guardadaDao.obtener();

      if (guardada != null) {
        _juego.restaurar(
            guardada.tablero, guardada.puntuacion, guardada.movimientos);
        _segundos = guardada.segundosTranscurridos;
      } else {
        _juego.nuevaPartida();
        _segundos = 0;
      }
      _mejor = max(await _partidaDao.mejorPuntuacion(),
          await _prefs.leerMejorPuntuacion());
    } catch (e) {
      _juego.nuevaPartida();
      _mostrarMensaje('No se pudo cargar la partida: $e');
    }
    if (!mounted) return;
    setState(() => _cargando = false);
    _arrancarCronometro();
  }

  void _arrancarCronometro() {
    _cronometro?.cancel();
    _cronometro = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_terminada) setState(() => _segundos++);
    });
  }

  // ---------------------------------------------- Guardado automático

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _cronometro?.cancel();
      _guardarPartida();
    } else if (state == AppLifecycleState.resumed && !_terminada) {
      _arrancarCronometro();
    }
  }

  Future<void> _guardarPartida() async {
    if (_cargando || _terminada) return;
    try {
      await _guardadaDao.guardar(PartidaGuardada(
        tablero: _juego.tablero,
        puntuacion: _juego.puntuacion,
        movimientos: _juego.movimientos,
        segundosTranscurridos: _segundos,
      ));
    } catch (e) {
      _mostrarMensaje('$e');
    }
  }

  // ---------------------------------------------------------- Movimiento

  void _mover(Direccion direccion) {
    if (_cargando || _terminada) return;
    final haCambiado = _juego.mover(direccion);
    if (!haCambiado) return;

    if (_vibracion) HapticFeedback.selectionClick();
    setState(() {});

    if (!_juego.hayMovimientos) _finalizar();
  }

  KeyEventResult _teclado(FocusNode nodo, KeyEvent evento) {
    if (evento is! KeyDownEvent) return KeyEventResult.ignored;
    final tecla = evento.logicalKey;
    Direccion? direccion;
    if (tecla == LogicalKeyboardKey.arrowUp) {
      direccion = Direccion.arriba;
    } else if (tecla == LogicalKeyboardKey.arrowDown) {
      direccion = Direccion.abajo;
    } else if (tecla == LogicalKeyboardKey.arrowLeft) {
      direccion = Direccion.izquierda;
    } else if (tecla == LogicalKeyboardKey.arrowRight) {
      direccion = Direccion.derecha;
    }
    if (direccion == null) return KeyEventResult.ignored;
    _mover(direccion);
    return KeyEventResult.handled;
  }

  // ------------------------------------------------------ Fin de partida

  Future<void> _finalizar() async {
    _cronometro?.cancel();
    setState(() => _terminada = true);

    final partida = Partida(
      usuarioId: Sesion.usuarioActual?.id,
      usuario: Sesion.nombre,
      puntuacion: _juego.puntuacion,
      fichaMaxima: _juego.fichaMaxima,
      movimientos: _juego.movimientos,
      duracionSegundos: _segundos,
      fecha: DateTime.now().toIso8601String(),
    );

    try {
      // Transacción: inserta en el historial y borra la partida guardada.
      await _partidaDao.finalizarPartida(partida);
      await _prefs.guardarMejorPuntuacion(partida.puntuacion);
      await _prefs.guardarUltimoJugador(partida.usuario);
    } catch (e) {
      _mostrarMensaje('$e');
    }

    if (!mounted) return;
    final opcion = await showDialog<_OpcionFin>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Fin de la partida!'),
        content: Text(
          'Puntuación: ${partida.puntuacion}\n'
          'Ficha máxima: ${partida.fichaMaxima}\n'
          'Movimientos: ${partida.movimientos}\n'
          'Tiempo: ${Formato.duracion(partida.duracionSegundos)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_OpcionFin.volver),
            child: const Text('Volver al inicio'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(_OpcionFin.jugarDeNuevo),
            child: const Text('Jugar de nuevo'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (opcion == _OpcionFin.jugarDeNuevo) {
      _empezarDeNuevo();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _empezarDeNuevo() {
    setState(() {
      _mejor = max(_mejor, _juego.puntuacion);
      _juego.nuevaPartida();
      _segundos = 0;
      _terminada = false;
    });
    _arrancarCronometro();
  }

  Future<void> _reiniciar() async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Reiniciar partida',
      mensaje: 'Se perderá la partida actual. ¿Quieres empezar de nuevo?',
      textoConfirmar: 'Reiniciar',
      destructivo: true,
    );
    if (ok) _empezarDeNuevo();
  }

  // ------------------------------------------------ Botón «atrás»

  Future<void> _alIntentarSalir(bool didPop, Object? resultado) async {
    if (didPop) return;
    final opcion = await showDialog<_OpcionSalida>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir de la partida?'),
        content: const Text('Tienes una partida en curso.'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_OpcionSalida.cancelar),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_OpcionSalida.salirSinGuardar),
            child: const Text('Salir sin guardar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_OpcionSalida.guardar),
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    switch (opcion) {
      case _OpcionSalida.guardar:
        await _guardarPartida();
        _salir();
      case _OpcionSalida.salirSinGuardar:
        try {
          await _guardadaDao.borrar();
        } catch (e) {
          _mostrarMensaje('$e');
        }
        _salir();
      case _OpcionSalida.cancelar:
      case null:
        break;
    }
  }

  void _salir() {
    _cronometro?.cancel();
    _terminada = true; // evita que el observer vuelva a guardar
    if (mounted) Navigator.of(context).pop();
  }

  void _mostrarMensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // ------------------------------------------------------------- Interfaz

  Widget _marcadores() {
    final mejor = max(_mejor, _juego.puntuacion);
    return GestureDetector(
      // Doble toque: mostrar u ocultar movimientos y tiempo
      onDoubleTap: () => setState(() => _mostrarDetalles = !_mostrarDetalles),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                  child: ScoreCard(
                      etiqueta: 'Puntos', valor: '${_juego.puntuacion}')),
              const SizedBox(width: AppConstantes.espacioS),
              Expanded(child: ScoreCard(etiqueta: 'Mejor', valor: '$mejor')),
            ],
          ),
          AnimatedSize(
            duration: AppConstantes.animacionColor,
            child: _mostrarDetalles
                ? Padding(
                    padding:
                        const EdgeInsets.only(top: AppConstantes.espacioS),
                    child: Row(
                      children: [
                        Expanded(
                          child: ScoreCard(
                              etiqueta: 'Movimientos',
                              valor: '${_juego.movimientos}'),
                        ),
                        const SizedBox(width: AppConstantes.espacioS),
                        Expanded(
                          child: ScoreCard(
                              etiqueta: 'Tiempo',
                              valor: Formato.duracion(_segundos)),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: AppConstantes.espacioXs),
          Text(
            'Doble toque para ${_mostrarDetalles ? 'ocultar' : 'ver'} detalles',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// Botones en pantalla: alternativa accesible al gesto de deslizar.
  Widget _botonesDireccion() {
    Widget boton(IconData icono, Direccion d, String ayuda) =>
        IconButton.filledTonal(
          tooltip: ayuda,
          onPressed: () => _mover(d),
          icon: Icon(icono),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        boton(Icons.keyboard_arrow_up, Direccion.arriba, 'Arriba'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            boton(Icons.keyboard_arrow_left, Direccion.izquierda, 'Izquierda'),
            const SizedBox(width: AppConstantes.espacioXl),
            boton(Icons.keyboard_arrow_right, Direccion.derecha, 'Derecha'),
          ],
        ),
        boton(Icons.keyboard_arrow_down, Direccion.abajo, 'Abajo'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ajustes = AjustesScope.of(context);
    final paleta = ajustes.paleta;
    _vibracion = ajustes.vibracion;
    final tablero = Center(
      child: BoardWidget(
        valores: _juego.tablero,
        paleta: paleta,
        onSwipe: _mover,
      ),
    );

    return PopScope<Object?>(
      // Si hay partida en curso, al pulsar «atrás» se pide confirmación.
      canPop: _cargando || _terminada,
      onPopInvokedWithResult: _alIntentarSalir,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('2048'),
          actions: [
            IconButton(
              tooltip: 'Reiniciar',
              onPressed: _cargando ? null : _reiniciar,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : Focus(
                  focusNode: _foco,
                  autofocus: true,
                  onKeyEvent: _teclado, // flechas del teclado
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstantes.espacioM),
                    child: OrientationBuilder(
                      builder: (context, orientacion) {
                        if (orientacion == Orientation.landscape) {
                          return Row(
                            children: [
                              Expanded(child: tablero),
                              const SizedBox(width: AppConstantes.espacioM),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _marcadores(),
                                      const SizedBox(
                                          height: AppConstantes.espacioM),
                                      _botonesDireccion(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _marcadores(),
                            const SizedBox(height: AppConstantes.espacioM),
                            Expanded(child: tablero),
                            const SizedBox(height: AppConstantes.espacioM),
                            _botonesDireccion(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
