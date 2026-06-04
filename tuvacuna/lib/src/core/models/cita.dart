import 'package:tuvacuna/src/core/models/estado_cita.dart';
import 'package:tuvacuna/src/core/models/estado_agendada.dart';
import 'centro_vacunacion.dart';
import 'paciente.dart';
import 'especialista_salud.dart';
import 'vacunacion.dart';
import 'campana.dart';
import 'vacuna.dart';

class Cita {
  final DateTime fecha;
  final String hora;
  late EstadoCita estadoCita; // mutable para patrón State

  // Referencias obligatorias por requerimiento
  final CentroVacunacion centroVacunacion;
  final Paciente paciente;
  final EspecialistaSalud especialista;

  // Puede ser opcional si la cita aún no se ha realizado
  Vacunacion? vacunacion;
  String? observaciones;
  Campana? campana; // Referencia a la campaña a la que pertenece esta cita

  Cita({
    required this.fecha,
    required this.hora,
    EstadoCita? estadoCita,
    required this.centroVacunacion,
    required this.paciente,
    required this.especialista,
    this.vacunacion,
    this.observaciones,
    this.campana,
  }) {
    this.estadoCita = estadoCita ?? EstadoAgendada(this);
  }

  Cita copyWith({
    DateTime? fecha,
    String? hora,
    EstadoCita? estadoCita,
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

  Vacuna? getInfoVacuna() {
    return vacunacion?.vacunaAplicada;
  }

  List<String> getDetalleVacunacion() {
    final vacuna = getInfoVacuna();
    if (vacuna != null) {
      return vacuna.getEnfermedades();
    }
    return [];
  }

  static Cita create(
    DateTime fecha,
    String hora,
    Paciente p,
    CentroVacunacion centro,
    EspecialistaSalud especialista,
  ) {
    return Cita(
      fecha: fecha,
      hora: hora,
      // estado por defecto será `EstadoAgendada`
      centroVacunacion: centro,
      paciente: p,
      especialista: especialista,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'estado': estadoCita.name(),
      'centro_id': centroVacunacion.id,
      'paciente_rut': paciente.rut,
      'especialista_rut': especialista.rut,
      if (vacunacion != null) 'vacunacion': vacunacion!.toJson(),
      if (observaciones != null) 'observaciones': observaciones,
      if (campana != null) 'campana': campana!.nombreCampana,
    };
  }
}

