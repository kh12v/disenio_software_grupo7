import 'centro_vacunacion.dart';
import 'paciente.dart';
import 'especialista_salud.dart';
import 'vacunacion.dart';
import 'campana.dart';

class Cita {
  final DateTime fecha;
  final String hora;
  final String estadoCita; // Ej: 'pendiente', 'realizada', 'cancelada'
  
  // Referencias obligatorias por requerimiento
  final CentroVacunacion centroVacunacion;
  final Paciente paciente;
  final EspecialistaSalud especialista;
  
  // Puede ser opcional si la cita aún no se ha realizado
  final Vacunacion? vacunacion;
  final String? observaciones;
  final Campana? campana; // Referencia a la campaña a la que pertenece esta cita

  Cita({
    required this.fecha,
    required this.hora,
    required this.estadoCita,
    required this.centroVacunacion,
    required this.paciente,
    required this.especialista,
    this.vacunacion,
    this.observaciones,
    this.campana,
  });

  Cita copyWith({
    DateTime? fecha,
    String? hora,
    String? estadoCita,
    CentroVacunacion? centroVacunacion,
    Paciente? paciente,
    EspecialistaSalud? especialista,
    Vacunacion? vacunacion,
    String? observaciones,
    Campana? campana,
  }) {
    return Cita(
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      estadoCita: estadoCita ?? this.estadoCita,
      centroVacunacion: centroVacunacion ?? this.centroVacunacion,
      paciente: paciente ?? this.paciente,
      especialista: especialista ?? this.especialista,
      vacunacion: vacunacion ?? this.vacunacion,
      observaciones: observaciones ?? this.observaciones,
      campana: campana ?? this.campana,
    );
  }

  static Cita create(DateTime fecha, String hora, Paciente p, CentroVacunacion centro, EspecialistaSalud especialista) {
    return Cita(
      fecha: fecha,
      hora: hora,
      estadoCita: 'Pendiente',
      centroVacunacion: centro,
      paciente: p,
      especialista: especialista,
    );
  }
}
