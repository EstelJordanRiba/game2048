/// Modelo de la tabla `usuarios`.
class Usuario {
  final int? id;
  final String usuario;
  final String fechaRegistro; // ISO 8601
  final String email;
  final String contraseña; // hash SHA-256, nunca la contraseña en claro

  const Usuario({
    this.id,
    required this.usuario,
    required this.fechaRegistro,
    required this.email,
    required this.contraseña,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'usuario': usuario,
        'fecha_registro': fechaRegistro,
        'email': email,
        'contraseña': contraseña,
      };

  factory Usuario.fromMap(Map<String, Object?> map) => Usuario(
        id: map['id'] as int?,
        usuario: map['usuario'] as String,
        fechaRegistro: map['fecha_registro'] as String,
        email: map['email'] as String,
        contraseña: map['contraseña'] as String,
      );
}
