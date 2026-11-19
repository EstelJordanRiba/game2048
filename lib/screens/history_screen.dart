import 'package:flutter/material.dart';

import '../data/cambios_datos.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../routes.dart';
import '../services/ajustes_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/partida_list_item.dart';

/// Historial de partidas terminadas, con filtros por jugador y ficha máxima.
/// Gestos: deslizar para borrar (con Deshacer), pulsación larga (menú),
/// toque (detalle) y arrastrar hacia abajo (recargar).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const List<int?> _opcionesFicha = [null, 128, 256, 512, 1024, 2048];

  final _dao = PartidaDao();
  final _filtroNombre = TextEditingController();
  int? _fichaMinima;
  late Future<List<Partida>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _consultar();
    // Se recarga sola cuando cambian los datos (partida nueva, borrado...).
    CambiosDatos.instancia.addListener(_recargar);
  }

  @override
  void dispose() {
    CambiosDatos.instancia.removeListener(_recargar);
    _filtroNombre.dispose();
    super.dispose();
  }

  Future<List<Partida>> _consultar() => _dao.obtenerHistorial(
        jugador: _filtroNombre.text,
        fichaMinima: _fichaMinima,
      );

  void _recargar() {
    if (mounted) setState(() => _futuro = _consultar());
  }

  void _mensaje(String texto, {SnackBarAction? accion}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(texto), action: accion));
  }

  /// Toque: navega al detalle pasando SOLO el id. Al volver, si el detalle
  /// devuelve true (partida eliminada), se actualiza la lista.
  Future<void> _abrirDetalle(int id) async {
    final eliminada =
        await Navigator.of(context).pushNamed<bool>(Rutas.detalle, arguments: id);
    if (!mounted) return;
    if (eliminada == true) {
      _recargar();
      _mensaje('La partida se ha eliminado');
    }
  }

  Future<bool> _confirmarBorrado() => ConfirmDialog.mostrar(
        context,
        titulo: 'Eliminar partida',
        mensaje: '¿Seguro que quieres eliminar esta partida del historial?',
        textoConfirmar: 'Eliminar',
        destructivo: true,
      );

  /// Borra la partida y ofrece «Deshacer», que la vuelve a insertar.
  Future<void> _eliminar(Partida partida) async {
    try {
      await _dao.eliminar(partida.id!);
      if (!mounted) return;
      _mensaje(
        'Partida eliminada',
        accion: SnackBarAction(
          label: 'Deshacer',
          onPressed: () async {
            try {
              await _dao.restaurar(partida);
            } catch (e) {
              _mensaje('$e');
            }
          },
        ),
      );
    } catch (e) {
      _mensaje('$e');
      _recargar();
    }
  }

  /// Pulsación larga: menú de opciones.
  Future<void> _mostrarMenu(Partida partida) async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Ver detalle'),
              onTap: () => Navigator.of(context).pop('detalle'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Eliminar'),
              onTap: () => Navigator.of(context).pop('eliminar'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (opcion == 'detalle') {
      _abrirDetalle(partida.id!);
    } else if (opcion == 'eliminar' && await _confirmarBorrado()) {
      _eliminar(partida);
    }
  }

  Widget _filtros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstantes.espacioM,
          AppConstantes.espacioS, AppConstantes.espacioM, AppConstantes.espacioS),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _filtroNombre,
              decoration: InputDecoration(
                labelText: 'Jugador',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _filtroNombre.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _filtroNombre.clear();
                          _recargar();
                        },
                      ),
              ),
              onChanged: (_) => _recargar(),
            ),
          ),
          const SizedBox(width: AppConstantes.espacioS),
          DropdownButton<int?>(
            value: _fichaMinima,
            hint: const Text('Ficha'),
            items: [
              for (final f in _opcionesFicha)
                DropdownMenuItem<int?>(
                  value: f,
                  child: Text(f == null ? 'Todas' : '≥ $f'),
                ),
            ],
            onChanged: (valor) {
              _fichaMinima = valor;
              _recargar();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paleta = AjustesScope.of(context).paleta;
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: Column(
        children: [
          _filtros(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _recargar();
                try {
                  await _futuro;
                } catch (_) {
                  // el error ya lo muestra AsyncDataView
                }
              },
              child: AsyncDataView<List<Partida>>(
                future: _futuro,
                onRetry: _recargar,
                estaVacio: (lista) => lista.isEmpty,
                iconoVacio: Icons.history_toggle_off,
                mensajeVacio: 'Todavía no hay partidas en el historial\n'
                    '(o ninguna coincide con los filtros)',
                builder: (context, partidas) => ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: partidas.length,
                  itemBuilder: (context, i) {
                    final partida = partidas[i];
                    return Dismissible(
                      key: ValueKey<int>(partida.id!),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Theme.of(context).colorScheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(
                            right: AppConstantes.espacioL),
                        child: Icon(Icons.delete,
                            color: Theme.of(context).colorScheme.onError),
                      ),
                      confirmDismiss: (_) => _confirmarBorrado(),
                      onDismissed: (_) {
                        // Se quita de la lista al momento y luego se borra en BD
                        setState(() => partidas.removeAt(i));
                        _eliminar(partida);
                      },
                      child: PartidaListItem(
                        partida: partida,
                        paleta: paleta,
                        onTap: () => _abrirDetalle(partida.id!),
                        onLongPress: () => _mostrarMenu(partida),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
