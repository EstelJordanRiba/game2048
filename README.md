# 2048 en Flutter

Práctica final de **DAM2** (Accés a dades + Desenvolupament d'interfícies).
Autores: **Unai Martín Rivas** y **Estel Jordan Riba**.

Juego 2048 en Flutter/Dart con persistencia de datos:

- **sqflite** (`game2048.db`): usuarios, historial de partidas, estadísticas y partida en curso.
- **shared_preferences**: modo de tema (claro / oscuro / sistema), paleta de colores de las fichas, vibración, último jugador y mejor puntuación.

## Cómo ejecutarlo

```bash
flutter pub get
flutter run          # emulador o dispositivo Android / iOS
flutter test         # tests de la lógica del juego
```

> sqflite no funciona en web sin configuración adicional: usar Android, iOS o escritorio.

## Estructura del proyecto

```
lib/
├── main.dart                  # carga las preferencias ANTES de runApp y abre la BD
├── app.dart                   # MaterialApp (theme, darkTheme, themeMode, rutas)
├── routes.dart                # sistema de rutas centralizado (onGenerateRoute)
├── data/                      # capa de acceso a datos (único sitio con SQL)
│   ├── database_helper.dart   # singleton, openDatabase, onCreate, onUpgrade (v1 → v2)
│   ├── usuario_dao.dart       # registro y login (contraseña con SHA-256)
│   ├── partida_dao.dart       # CRUD, transacción, ranking y agregaciones
│   ├── partida_guardada_dao.dart
│   ├── cambios_datos.dart     # aviso global para refrescar las pantallas
│   └── datos_exception.dart
├── models/                    # Usuario, Partida, PartidaGuardada, estadísticas (toMap/fromMap)
├── logic/game_logic.dart      # lógica pura del 2048 (sin widgets ni BD)
├── services/                  # PreferenciasService, AjustesController, Sesion
├── theme/app_theme.dart       # constantes, estilos, temas claro/oscuro y paletas
├── utils/formato.dart
├── screens/                   # login, inicio, juego, historial, detalle, ranking, ajustes
└── widgets/                   # widgets reutilizables (una clase por archivo)
```

## Parte A: acceso a datos

| Requisito | Dónde está |
|---|---|
| `game2048.db` con tablas `usuarios`, `partidas`, `partida_guardada` | `database_helper.dart` |
| Clase auxiliar singleton con versión y `onCreate` | `DatabaseHelper` |
| Modelos con `toMap()` / `fromMap()` | `models/` |
| DAO / repositorio (ninguna pantalla contiene SQL) | `data/*_dao.dart` |
| Consultas parametrizadas (`whereArgs`, `?`) | todos los DAO |
| Operaciones asíncronas con `try/catch` | todos los DAO (`DatosException`) |
| Transacción | `PartidaDao.finalizarPartida` (inserta la partida y borra la guardada) |
| Migración con `onUpgrade` (v1 → v2, columna `tamano_tablero` por defecto 4) | `DatabaseHelper._migrarAV2` |
| Modelo normalizado con claves foráneas (`PRAGMA foreign_keys = ON`) | `partidas.usuario_id → usuarios.id` |
| CRUD, ranking (`ORDER BY` + `LIMIT`), `COUNT/MAX/AVG/SUM`, `GROUP BY`, filtros | `PartidaDao` |
| Guardado automático al salir o pasar a segundo plano | `GameScreen` (`WidgetsBindingObserver`) |

## Parte B: preferencias con shared_preferences

- `PreferenciasService` encapsula el acceso; las claves son constantes.
- `guardarModoTema` / `leerModoTema` (por defecto `ThemeMode.system`).
- Se cargan **antes de `runApp`** (`WidgetsFlutterBinding.ensureInitialized()` + `await`) para evitar el parpadeo del tema.
- `AjustesController` (`ChangeNotifier`) + `AjustesScope` (`InheritedNotifier`): el cambio se refleja en tiempo real en toda la app.
- Pantalla de Ajustes con `SegmentedButton` (tres modos) y selección de paleta de fichas.
- Temas claro y oscuro coherentes, incluidos los colores de las fichas.
- Ampliaciones: último jugador, mejor puntuación y vibración.

## Interfaz, navegación, gestos y widgets

- **Navegación**: rutas con nombre centralizadas en `routes.dart` y `BottomNavigationBar` con `IndexedStack` (Inicio, Historial, Ranking, Ajustes). Al abrir el detalle solo se pasa el `id`; al borrar, `Navigator.pop(context, true)` devuelve el resultado y la lista se actualiza. `PopScope` pide confirmación (guardar y salir / salir sin guardar / cancelar) al pulsar «atrás» en una partida en curso.
- **Gestos**: swipe en el tablero (`GestureDetector` con umbral mínimo y dirección dominante), `Dismissible` + `SnackBar` «Deshacer» en el historial, `onLongPress` (menú), `onTap` (detalle), `RefreshIndicator` y doble toque en los marcadores. Alternativas accesibles: botones en pantalla y flechas del teclado.
- **Widgets reutilizables** (`lib/widgets/`): `TileWidget`, `BoardWidget`, `ScoreCard`, `StatCard`, `PartidaListItem`, `ConfirmDialog`, `EmptyStateView`, `AsyncDataView`.
- **Animaciones**: `AnimatedSwitcher`/`ScaleTransition` y `AnimatedContainer` en las fichas; `AnimatedSize` en los marcadores.
- **Estados asíncronos**: `AsyncDataView` gestiona carga, error (con reintento), vacío y contenido.

## Documentación

La documentación de entrega (modelo de datos, arquitectura, migración, diagrama de navegación, tablas de gestos y de reutilización de widgets, justificación de diseño) está en el PDF de entrega de la actividad (`documentacion.pdf`).
