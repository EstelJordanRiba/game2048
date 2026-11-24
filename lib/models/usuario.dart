/// Modelo de la tabla `usuarios`.
class Usuario {
  final int? id;
  final String usuario;
  final String fechaRegistro; // ISO 8601
  final String email;
  final String contrasena; // hash SHA-256, nunca la contraseña en claro

  const Usuario({
    this.id,
    required this.usuario,
    required this.fechaRegistro,
    required this.email,
    required this.contrasena,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'usuario': usuario,
        'fecha_registro': fechaRegistro,
        'email': email,
        'contrasena': contrasena,
      };

  factory Usuario.fromMap(Map<String, Object?> map) => Usuario(
        id: map['id'] as int?,
        usuario: map['usuario'] as String,
        fechaRegistro: map['fecha_registro'] as String,
        email: map['email'] as String,
        contrasena: map['contrasena'] as String,
      );
}
