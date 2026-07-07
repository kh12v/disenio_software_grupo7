import 'vacuna.dart';
import 'especialista_salud.dart';

class Vacunacion {
  final DateTime fechaAplicacion;
  final int numeroDosis;
  final String observacionesReacciones;

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
      'vacuna_id': vacunaAplicada.id,
      'vacuna_nombre': vacunaAplicada.nombre,
      'especialista_rut': especialistaAdministrador.rut,
      'especialista_nombre':
          '${especialistaAdministrador.nombres} ${especialistaAdministrador.apellidos}',
    };
  }
  Vacuna getInfoVacuna() {
  return vacunaAplicada;
}
}