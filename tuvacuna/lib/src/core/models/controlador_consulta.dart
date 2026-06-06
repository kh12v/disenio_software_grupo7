import '../data/database_controller.dart';
import 'paciente.dart';

/// Clase ControladorConsulta: Responsable de la obtención de datos
/// correspondientes a los historiales de vacunación de un paciente.
class ControladorConsulta {
  /// Corresponde al mensaje: obtenerHistorialVanucacion(rutPaciente) del diagrama de comunicación.
  List<String> obtenerHistorialVanucacion(String rutPaciente, DatabaseController db) {
    final p = db.getPersonas.firstWhere((p) => p.rut == rutPaciente, orElse: () => throw Exception("Paciente no encontrado"));
    
    final historial = p.getHistorial(db);
    
    List<String> enfermedades = [];
    
    for (var cita in historial) {
      enfermedades.addAll(cita.getDetalleVacunacion());
    }
    
    return enfermedades;
  }
}
