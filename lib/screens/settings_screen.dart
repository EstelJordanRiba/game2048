import 'package:flutter/material.dart';

import '../data/partida_dao.dart';
import '../routes.dart';
import '../services/ajustes_controller.dart';
import '../services/preferencias_service.dart';
import '../services/sesion.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/tile_widget.dart';

/// Ajustes: modo de tema, colores de las fichas, vibración,
/// borrar historial y cerrar sesión.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<int> _muestra = [2, 8, 32, 128, 512, 2048];

  Future<void> _borrarHistorial(BuildContext context) async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Borrar todo el historial',
      mensaje: 'Se eliminarán todas las partidas. Esta acción no se puede '
          'deshacer.',
      textoConfirmar: 'Borrar todo',
      destructivo: true,
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await PartidaDao().eliminarTodo();
      await PreferenciasService.instancia.reiniciarMejorPuntuacion();
      messenger.showSnackBar(
          SnackBar(content: Text('Se han borrado $n partidas')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _cerrarSesion(BuildContext context) {
    Sesion.cerrar();
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil(Rutas.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final ajustes = AjustesScope.of(context);
    final estiloTitulo = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstantes.espacioM),
        children: [
          Text('Tema', style: estiloTitulo),
          const SizedBox(height: AppConstantes.espacioS),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Claro'),
                  icon: Icon(Icons.light_mode)),
              ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Oscuro'),
                  icon: Icon(Icons.dark_mode)),
              ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Sistema'),
                  icon: Icon(Icons.settings_suggest)),
            ],
            selected: {ajustes.modoTema},
            onSelectionChanged: (s) => ajustes.cambiarModoTema(s.first),
          ),
          const SizedBox(height: AppConstantes.espacioL),
          Text('Colores de las fichas', style: estiloTitulo),
          const SizedBox(height: AppConstantes.espacioS),
          SegmentedButton<PaletaFichas>(
            segments: [
              for (final p in PaletaFichas.values)
                ButtonSegment(value: p, label: Text(p.nombre)),
            ],
            selected: {ajustes.paleta},
            onSelectionChanged: (s) => ajustes.cambiarPaleta(s.first),
          ),
          const SizedBox(height: AppConstantes.espacioS),
          // Vista previa con el mismo widget de ficha del tablero
          Row(
            children: [
              for (final v in _muestra) ...[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: TileWidget(valor: v, paleta: ajustes.paleta),
                  ),
                ),
                if (v != _muestra.last)
                  const SizedBox(width: AppConstantes.espacioXs),
              ],
            ],
          ),
          const SizedBox(height: AppConstantes.espacioL),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vibración al mover'),
            value: ajustes.vibracion,
            onChanged: ajustes.cambiarVibracion,
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_forever,
                color: Theme.of(context).colorScheme.error),
            title: const Text('Borrar todo el historial'),
            onTap: () => _borrarHistorial(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: Text('Cerrar sesión (${Sesion.nombre})'),
            onTap: () => _cerrarSesion(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: '2048',
              applicationVersion: '1.0.0',
              children: const [
                Text('Práctica DAM2: sqflite + shared_preferences.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
