import '../data/database_controller.dart';

/// Clase ControladorConsulta: Responsable de la obtención de datos
/// correspondientes a los historiales de vacunación de un paciente.
class ControladorConsulta {
  /// Corresponde al mensaje: obtenerHistorialVacunacion(rutPaciente) del diagrama de comunicación.
  List<String> obtenerHistorialVacunacion(
    String rutPaciente,
    DatabaseController db,
  ) {
    final p = db.getPersonas.firstWhere(
      (p) => p.rut == rutPaciente,
      orElse: () => throw Exception("Paciente no encontrado"),
    );

    final historial = p.getHistorial(db);

    final List<String> enfermedades = [];

    for (final cita in historial) {
      enfermedades.addAll(cita.getDetalleVacunacion());
    }

    return enfermedades;
  }

  /// Método antiguo mantenido por compatibilidad.
  /// Puedes eliminarlo después de actualizar todas las llamadas.
  @Deprecated('Usa obtenerHistorialVacunacion')
  List<String> obtenerHistorialVanucacion(
    String rutPaciente,
    DatabaseController db,
  ) {
    return obtenerHistorialVacunacion(rutPaciente, db);
  }
}