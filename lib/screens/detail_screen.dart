import 'package:flutter/material.dart';

import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../services/ajustes_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/stat_card.dart';
import '../widgets/tile_widget.dart';

/// Detalle de una partida. Recibe SOLO el id y consulta la BD con él.
/// Si se elimina la partida, devuelve true con Navigator.pop(context, true).
class DetailScreen extends StatefulWidget {
  final int partidaId;

  const DetailScreen({super.key, required this.partidaId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _dao = PartidaDao();
  late Future<Partida?> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _dao.obtenerPorId(widget.partidaId);
  }

  void _recargar() =>
      setState(() => _futuro = _dao.obtenerPorId(widget.partidaId));

  Future<void> _eliminar() async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Eliminar partida',
      mensaje: 'Esta partida se borrará del historial.',
      textoConfirmar: 'Eliminar',
      destructivo: true,
    );
    if (!ok) return;
    try {
      await _dao.eliminar(widget.partidaId);
      if (!mounted) return;
      Navigator.of(context).pop(true); // devolución de resultado
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final paleta = AjustesScope.of(context).paleta;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de partida'),
        actions: [
          IconButton(
            tooltip: 'Eliminar',
            onPressed: _eliminar,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: AsyncDataView<Partida?>(
        future: _futuro,
        onRetry: _recargar,
        estaVacio: (p) => p == null,
        iconoVacio: Icons.search_off,
        mensajeVacio: 'Esta partida ya no existe',
        builder: (context, partida) {
          final p = partida!;
          final tarjetas = [
            StatCard(
                titulo: 'Jugador', valor: p.usuario, icono: Icons.person),
            StatCard(
                titulo: 'Puntuación',
                valor: '${p.puntuacion}',
                icono: Icons.star),
            StatCard(
                titulo: 'Ficha máxima',
                valor: '${p.fichaMaxima}',
                icono: Icons.grid_view),
            StatCard(
                titulo: 'Movimientos',
                valor: '${p.movimientos}',
                icono: Icons.swipe),
            StatCard(
                titulo: 'Duración',
                valor: Formato.duracion(p.duracionSegundos),
                icono: Icons.timer),
            StatCard(
                titulo: 'Fecha',
                valor: Formato.fecha(p.fecha),
                icono: Icons.calendar_today),
            StatCard(
                titulo: 'Tablero',
                valor: '${p.tamanoTablero} x ${p.tamanoTablero}',
                icono: Icons.border_all),
          ];
          return ListView(
            padding: const EdgeInsets.all(AppConstantes.espacioM),
            children: [
              Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: TileWidget(valor: p.fichaMaxima, paleta: paleta),
                ),
              ),
              const SizedBox(height: AppConstantes.espacioL),
              for (final t in tarjetas) ...[
                t,
                const SizedBox(height: AppConstantes.espacioS),
              ],
              const SizedBox(height: AppConstantes.espacioM),
              OutlinedButton.icon(
                onPressed: _eliminar,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar partida'),
              ),
            ],
          );
        },
      ),
    );
  }
}
