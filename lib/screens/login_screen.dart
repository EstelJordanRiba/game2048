import 'package:flutter/material.dart';

import '../data/usuario_dao.dart';
import '../routes.dart';
import '../services/preferencias_service.dart';
import '../services/sesion.dart';
import '../theme/app_theme.dart';

/// Pantalla de login y de registro de usuarios.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _Modo { entrar, registrarse }

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  final _usuarioDao = UsuarioDao();

  _Modo _modo = _Modo.entrar;
  bool _cargando = false;
  bool _ocultarContrasena = true;

  @override
  void initState() {
    super.initState();
    _rellenarUltimoJugador();
  }

  Future<void> _rellenarUltimoJugador() async {
    final ultimo = await PreferenciasService.instancia.leerUltimoJugador();
    if (ultimo != null && mounted && _usuarioCtrl.text.isEmpty) {
      _usuarioCtrl.text = ultimo;
    }
  }

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _emailCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    final resultado = _modo == _Modo.entrar
        ? await _usuarioDao.login(_usuarioCtrl.text, _contrasenaCtrl.text)
        : await _usuarioDao.registrar(
            usuario: _usuarioCtrl.text,
            email: _emailCtrl.text,
            contrasena: _contrasenaCtrl.text,
          );

    if (!mounted) return;
    setState(() => _cargando = false);

    if (!resultado.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado.error ?? 'Error desconocido')),
      );
      return;
    }

    Sesion.usuarioActual = resultado.usuario;
    await PreferenciasService.instancia
        .guardarUltimoJugador(resultado.usuario!.usuario);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(Rutas.principal);
  }

  @override
  Widget build(BuildContext context) {
    final registro = _modo == _Modo.registrarse;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstantes.espacioL),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('2048',
                        textAlign: TextAlign.center,
                        style: AppTextos.tituloJuego),
                    const SizedBox(height: AppConstantes.espacioL),
                    SegmentedButton<_Modo>(
                      segments: const [
                        ButtonSegment(
                          value: _Modo.entrar,
                          label: Text('Entrar'),
                          icon: Icon(Icons.login),
                        ),
                        ButtonSegment(
                          value: _Modo.registrarse,
                          label: Text('Registrarse'),
                          icon: Icon(Icons.person_add),
                        ),
                      ],
                      selected: {_modo},
                      onSelectionChanged: (s) =>
                          setState(() => _modo = s.first),
                    ),
                    const SizedBox(height: AppConstantes.espacioL),
                    TextFormField(
                      controller: _usuarioCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        prefixIcon: Icon(Icons.person),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Escribe tu nombre de usuario'
                          : null,
                    ),
                    if (registro) ...[
                      const SizedBox(height: AppConstantes.espacioM),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) => UsuarioDao.emailValido(v ?? '')
                            ? null
                            : 'Email no válido (debe contener @)',
                      ),
                    ],
                    const SizedBox(height: AppConstantes.espacioM),
                    TextFormField(
                      controller: _contrasenaCtrl,
                      obscureText: _ocultarContrasena,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_ocultarContrasena
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(
                              () => _ocultarContrasena = !_ocultarContrasena),
                        ),
                      ),
                      onFieldSubmitted: (_) => _enviar(),
                      validator: (v) => (v == null || v.length < 4)
                          ? 'Mínimo 4 caracteres'
                          : null,
                    ),
                    const SizedBox(height: AppConstantes.espacioL),
                    FilledButton(
                      onPressed: _cargando ? null : _enviar,
                      child: _cargando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(registro ? 'Crear cuenta' : 'Entrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
