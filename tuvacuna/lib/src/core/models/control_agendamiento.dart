import 'centro_vacunacion.dart';
import 'cita.dart';
import '../data/database_controller.dart';

/// Clase ControlAgendamiento: Controlador responsable de la lógica y reglas 
/// de negocio necesarias para agendar citas.
class ControlAgendamiento {
  /// Corresponde al mensaje: agendarCita(rutPaciente, idCentro, fecha, hora) del diagrama de comunicación.
  Cita agendarCita(String rutPaciente, String idCentro, String rutEspecialista, DateTime fecha, String hora, DatabaseController db) {
    CentroVacunacion centro = _obtenerCentro(idCentro, db);
    
    return centro.agregarCita(rutPaciente, rutEspecialista, fecha, hora, db);
  }

  CentroVacunacion _obtenerCentro(String idCentro, DatabaseController db) {
    return db.getCentros.firstWhere((c) => c.id == idCentro, orElse: () => throw Exception("Centro no encontrado con el id: $idCentro"));
  }
}
