import 'vacuna.dart';
import 'especialista_salud.dart';

class Vacunacion {
  final DateTime fechaAplicacion;
  final int numeroDosis;
  final String observacionesReacciones;
  
  // Registra cuál es la vacuna aplicada y quién la administró
  final Vacuna vacunaAplicada;
  final EspecialistaSalud especialistaAdministrador;

  Vacunacion({
    required this.fechaAplicacion,
    required this.numeroDosis,
    required this.observacionesReacciones,
    required this.vacunaAplicada,
    required this.especialistaAdministrador,
  });

  Map<String, dynamic> toJson() {
    return {
      'fecha_aplicacion': fechaAplicacion.toIso8601String(),
      'numero_dosis': numeroDosis,
      'observaciones_reacciones': observacionesReacciones,
      'vacuna_aplicada': vacunaAplicada.nombre,
      'especialista_administrador': especialistaAdministrador.rut,
    };
  }
}
