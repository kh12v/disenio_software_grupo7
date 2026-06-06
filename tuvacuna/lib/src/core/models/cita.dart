import 'centro_vacunacion.dart';
import 'paciente.dart';
import 'especialista_salud.dart';
import 'vacunacion.dart';
import 'campana.dart';
import 'vacuna.dart';
import 'estado_cita.dart';

/// Clase Cita: Entidad que representa una cita médica.
/// PATRÓN DE DISEÑO: State.
class Cita {
  final DateTime fecha;
  final String hora;
  /// PATRÓN DE DISEÑO: State. Referencia al estado actual (-estadoActual: Estado)
  EstadoCita estadoActual;
  
  String get estadoCita => estadoActual.nombre;
  
  // Referencias obligatorias por requerimiento
  final CentroVacunacion centroVacunacion;
  final Paciente paciente;
  final EspecialistaSalud especialista;

  // Puede ser opcional si la cita aún no se ha realizado
  Vacunacion? vacunacion;
  final String? observaciones;
  final Campana? campana;

  Cita._internal({
    required this.fecha,
    required this.hora,
    required this.estadoActual,
    required this.centroVacunacion,
    required this.paciente,
    required this.especialista,
    this.vacunacion,
    this.observaciones,
    this.campana,
  });

  /// Corresponde al mensaje: create(fecha, hora, p) del diagrama de comunicación.
  /// Crea una nueva instancia de Cita delegando sus parámetros.
  factory Cita({
    required DateTime fecha,
    required String hora,
    required String estadoCita,
    required CentroVacunacion centroVacunacion,
    required Paciente paciente,
    required EspecialistaSalud especialista,
    Vacunacion? vacunacion,
    String? observaciones,
    Campana? campana,
  }) {
    EstadoCita estado;
    if (estadoCita == 'Completa' || estadoCita == 'Realizada') {
      estado = EstadoRealizada();
    } else if (estadoCita == 'Cancelada') {
      estado = EstadoCancelada();
    } else {
      estado = EstadoAgendada();
    }
    
    return Cita._internal(
      fecha: fecha,
      hora: hora,
      estadoActual: estado,
      centroVacunacion: centroVacunacion,
      paciente: paciente,
      especialista: especialista,
      vacunacion: vacunacion,
      observaciones: observaciones,
      campana: campana,
    );
  }

  /// PATRÓN DE DISEÑO: State. Corresponde al mensaje: +confirmar()
  /// Delega la acción de confirmar al estado actual de la cita.
  void confirmar() {
    estadoActual.confirmar(this);
  }

  /// PATRÓN DE DISEÑO: State Corresponde al mensaje: +registrarVacunacion()
  /// Delega la acción de registro y el cambio de estado de la Cita a su estado actual.
  void registrarVacunacion(Vacunacion v) {
    estadoActual.registrarVacunacion(this, v);
  }

  /// PATRÓN DE DISEÑO: State Corresponde al mensaje: +cancelar()
  /// Delega la cancelación al estado actual.
  void cancelar() {
    estadoActual.cancelar(this);
  }

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

  /// Corresponde al mensaje: getInfoVacuna() del diagrama de comunicación.
  /// Responsabilidad: Entregar la información de la vacuna contenida en la vacunación aplicada.
  Vacuna? getInfoVacuna() {
    return vacunacion?.vacunaAplicada;
  }

  /// Corresponde al mensaje: getDetalleVacunacion() del diagrama de comunicación.
  /// Responsabilidad: Obtener la lista de enfermedades desde la vacuna asociada a esta cita.
  List<String> getDetalleVacunacion() {
    final vacuna = getInfoVacuna();
    if (vacuna != null) {
      return vacuna.getEnfermedades();
    }
    return [];
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
