class Notificacion {
  final String mensaje;
  final String canalEnvio; // Ej: 'email' o 'SMS'
  final DateTime fechaEnvio;

  Notificacion({
    required this.mensaje,
    required this.canalEnvio,
    required this.fechaEnvio,
  });

  Map<String, dynamic> toJson() {
    return {
      'mensaje': mensaje,
      'canal_envio': canalEnvio,
      'fecha_envio': fechaEnvio.toIso8601String(),
    };
  }
}
