class Notificacion {
  final String mensaje;
  final String canalEnvio; // Ej: 'email' o 'SMS'
  final DateTime fechaEnvio;

  Notificacion({
    required this.mensaje,
    required this.canalEnvio,
    required this.fechaEnvio,
  });
}
