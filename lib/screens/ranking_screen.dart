import 'package:flutter/material.dart';

import '../data/cambios_datos.dart';
import '../data/partida_dao.dart';
import '../models/estadisticas.dart';
import '../models/partida.dart';
import '../routes.dart';
import '../services/ajustes_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/async_data_view.dart';
import '../widgets/partida_list_item.dart';
import '../widgets/stat_card.dart';

class _DatosRanking {
  final List<Partida> top;
  final EstadisticasGlobales globales;
  final List<EstadisticaJugador> porJugador;
  const _DatosRanking(this.top, this.globales, this.porJugador);
}

/// Top 10 de partidas, estadísticas globales y por jugador.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _dao = PartidaDao();
  late Future<_DatosRanking> _futuro;

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

  Future<_DatosRanking> _cargar() async {
    final top = await _dao.ranking();
    final globales = await _dao.estadisticasGlobales();
    final porJugador = await _dao.estadisticasPorJugador();
    return _DatosRanking(top, globales, porJugador);
  }

  void _recargar() {
    if (mounted) setState(() => _futuro = _cargar());
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.fromLTRB(AppConstantes.espacioM,
            AppConstantes.espacioL, AppConstantes.espacioM, AppConstantes.espacioS),
        child: Text(texto, style: Theme.of(context).textTheme.titleLarge),
      );

  Widget _parTarjetas(Widget a, Widget b) => Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstantes.espacioM,
            vertical: AppConstantes.espacioXs),
        child: Row(
          children: [
            Expanded(child: a),
            const SizedBox(width: AppConstantes.espacioS),
            Expanded(child: b),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final paleta = AjustesScope.of(context).paleta;
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking y estadísticas')),
      body: RefreshIndicator(
        onRefresh: () async {
          _recargar();
          try {
            await _futuro;
          } catch (_) {
            // el error ya lo muestra AsyncDataView
          }
        },
        child: AsyncDataView<_DatosRanking>(
          future: _futuro,
          onRetry: _recargar,
          estaVacio: (d) => d.globales.partidasJugadas == 0,
          iconoVacio: Icons.emoji_events_outlined,
          mensajeVacio: 'Juega tu primera partida para ver el ranking',
          builder: (context, datos) {
            final g = datos.globales;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _titulo('Estadísticas globales'),
                _parTarjetas(
                  StatCard(
                      titulo: 'Partidas',
                      valor: '${g.partidasJugadas}',
                      icono: Icons.videogame_asset),
                  StatCard(
                      titulo: 'Puntuación máx.',
                      valor: '${g.puntuacionMaxima}',
                      icono: Icons.star),
                ),
                _parTarjetas(
                  StatCard(
                      titulo: 'Media',
                      valor: g.puntuacionMedia.toStringAsFixed(0),
                      icono: Icons.equalizer),
                  StatCard(
                      titulo: 'Ficha máx.',
                      valor: '${g.fichaMaxima}',
                      icono: Icons.grid_view),
                ),
                _parTarjetas(
                  StatCard(
                      titulo: 'Tiempo total',
                      valor: Formato.duracion(g.tiempoTotalSegundos),
                      icono: Icons.timer),
                  StatCard(
                      titulo: 'Jugadores',
                      valor: '${datos.porJugador.length}',
                      icono: Icons.people),
                ),
                _titulo('Top 10'),
                for (var i = 0; i < datos.top.length; i++)
                  PartidaListItem(
                    partida: datos.top[i],
                    paleta: paleta,
                    posicion: i + 1,
                    onTap: () => Navigator.of(context).pushNamed<bool>(
                        Rutas.detalle,
                        arguments: datos.top[i].id),
                  ),
                _titulo('Por jugador'),
                for (final j in datos.porJugador)
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(j.usuario),
                    subtitle: Text('${j.partidas} partidas'),
                    trailing: Text(
                      '${j.mejorPuntuacion}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                const SizedBox(height: AppConstantes.espacioL),
              ],
            );
          },
        ),
      ),
    );
  }
}
