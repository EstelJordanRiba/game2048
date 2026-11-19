import 'package:flutter/material.dart';

import '../models/partida.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';

/// Elemento de lista con los datos resumidos de una partida.
/// Reutilizado en: Historial y Ranking.
class PartidaListItem extends StatelessWidget {
  final Partida partida;
  final PaletaFichas paleta;
  final int? posicion; // posición en el ranking (opcional)
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PartidaListItem({
    super.key,
    required this.partida,
    required this.paleta,
    this.posicion,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final ficha = partida.fichaMaxima;
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: CircleAvatar(
        backgroundColor: paleta.colorFicha(ficha),
        foregroundColor: paleta.colorTexto(ficha),
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(AppConstantes.espacioXs),
            child: Text(
              posicion != null ? '#$posicion' : '$ficha',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
      title: Text('${partida.puntuacion} puntos · ${partida.usuario}'),
      subtitle: Text(
        'Ficha $ficha · ${partida.movimientos} movs · '
        '${Formato.duracion(partida.duracionSegundos)}\n'
        '${Formato.fecha(partida.fecha)}',
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
