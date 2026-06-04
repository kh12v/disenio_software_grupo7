import 'centro_vacunacion.dart';
import 'vacuna.dart';
import 'cita.dart';
import '../data/database_controller.dart';
import 'cita.dart';

class ControlAgendamiento {
  Cita agendarCita(String rutPaciente, String idCentro, String rutEspecialista, DateTime fecha, String hora, DatabaseController db) {
    // Obtener el objeto CentroVacunacion
    CentroVacunacion centro = _obtenerCentro(idCentro, db);
    
    // Llamar al método agregarCita del CentroVacunacion
    return centro.agregarCita(rutPaciente, rutEspecialista, fecha, hora, db);
  }

  CentroVacunacion _obtenerCentro(String idCentro, DatabaseController db) {
    return db.getCentros.firstWhere((c) => c.id == idCentro, orElse: () => throw Exception("Centro no encontrado con el id: $idCentro"));
  }
}
