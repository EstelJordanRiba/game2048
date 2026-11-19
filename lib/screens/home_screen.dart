import 'dart:math';

import 'package:flutter/material.dart';

import '../data/cambios_datos.dart';
import '../data/partida_dao.dart';
import '../data/partida_guardada_dao.dart';
import '../routes.dart';
import '../services/preferencias_service.dart';
import '../services/sesion.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/score_card.dart';

class _DatosInicio {
  final int mejor;
  final bool hayGuardada;
  final String? ultimoJugador;
  const _DatosInicio(this.mejor, this.hayGuardada, this.ultimoJugador);
}

/// Pantalla de inicio: nombre del juego, mejor puntuación y accesos.
class HomeScreen extends StatefulWidget {
  /// Callback para cambiar de pestaña en la barra inferior.
  final ValueChanged<int> onIrA;

  const HomeScreen({super.key, required this.onIrA});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _partidaDao = PartidaDao();
  final _guardadaDao = PartidaGuardadaDao();
  final _prefs = PreferenciasService.instancia;

  late Future<_DatosInicio> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
    CambiosDatos.instancia.addListener(_recargar);
  }

  @override
  void dispose() {
    CambiosDatos.instancia.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    if (mounted) setState(() => _futuro = _cargar());
  }

  Future<_DatosInicio> _cargar() async {
    final mejorBd = await _partidaDao.mejorPuntuacion();
    final mejorPrefs = await _prefs.leerMejorPuntuacion();
    final hayGuardada = await _guardadaDao.existe();
    final ultimo = await _prefs.leerUltimoJugador();
    return _DatosInicio(max(mejorBd, mejorPrefs), hayGuardada, ultimo);
  }

  Future<void> _nuevaPartida(bool hayGuardada) async {
    if (hayGuardada) {
      final ok = await ConfirmDialog.mostrar(
        context,
        titulo: 'Nueva partida',
        mensaje: 'Tienes una partida guardada. Si empiezas una nueva, '
            'la partida guardada se perderá.',
        textoConfirmar: 'Empezar',
      );
      if (!ok) return;
      await _guardadaDao.borrar();
    }
    if (!mounted) return;
    await Navigator.of(context).pushNamed(Rutas.juego);
  }

  Future<void> _continuar() async {
    await Navigator.of(context)
        .pushNamed(Rutas.juego, arguments: const JuegoArgs(continuar: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<_DatosInicio>(
          future: _futuro,
          builder: (context, snapshot) {
            final datos = snapshot.data;
            final hayGuardada = datos?.hayGuardada ?? false;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstantes.espacioL),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('2048',
                          textAlign: TextAlign.center,
                          style: AppTextos.tituloJuego),
                      Text(
                        'Hola, ${Sesion.nombre}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstantes.espacioL),
                      Row(
                        children: [
                          Expanded(
                            child: ScoreCard(
                              etiqueta: 'Mejor',
                              valor: '${datos?.mejor ?? 0}',
                            ),
                          ),
                          const SizedBox(width: AppConstantes.espacioS),
                          Expanded(
                            child: ScoreCard(
                              etiqueta: 'Último jugador',
                              valor: datos?.ultimoJugador ?? '-',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstantes.espacioXl),
                      FilledButton.icon(
                        onPressed: () => _nuevaPartida(hayGuardada),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Nueva partida'),
                      ),
                      // El botón continuar solo aparece si hay partida guardada
                      if (hayGuardada) ...[
                        const SizedBox(height: AppConstantes.espacioS),
                        FilledButton.tonalIcon(
                          onPressed: _continuar,
                          icon: const Icon(Icons.restore),
                          label: const Text('Continuar partida'),
                        ),
                      ],
                      const SizedBox(height: AppConstantes.espacioL),
                      OutlinedButton.icon(
                        onPressed: () => widget.onIrA(1),
                        icon: const Icon(Icons.history),
                        label: const Text('Historial'),
                      ),
                      const SizedBox(height: AppConstantes.espacioS),
                      OutlinedButton.icon(
                        onPressed: () => widget.onIrA(2),
                        icon: const Icon(Icons.emoji_events),
                        label: const Text('Ranking'),
                      ),
                      const SizedBox(height: AppConstantes.espacioS),
                      OutlinedButton.icon(
                        onPressed: () => widget.onIrA(3),
                        icon: const Icon(Icons.settings),
                        label: const Text('Ajustes'),
                      ),
                      const SizedBox(height: AppConstantes.espacioL),
                      Text(
                        'Desliza para mover las fichas. Cuando dos fichas '
                        'iguales chocan se fusionan. ¡Llega a 2048!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
