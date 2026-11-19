import 'package:flutter/material.dart';

import 'history_screen.dart';
import 'home_screen.dart';
import 'ranking_screen.dart';
import 'settings_screen.dart';

/// Navegación principal con BottomNavigationBar.
/// Se ha elegido porque hay 4 secciones del mismo nivel (Inicio, Historial,
/// Ranking y Ajustes) a las que se quiere acceder con un solo toque; las
/// guías de Material recomiendan barra inferior para 3-5 destinos.
/// IndexedStack conserva el estado (filtros, scroll) de cada pestaña.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indice = 0;

  void _irA(int indice) => setState(() => _indice = indice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indice,
        children: [
          HomeScreen(onIrA: _irA),
          const HistoryScreen(),
          const RankingScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        onTap: _irA,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: 'Ranking'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
