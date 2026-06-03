import 'centro_vacunacion.dart';

class EspecialistaSalud {
  final String rut;
  final String licencia;
  final String nombres;
  final String apellidos;
  final String especialidad;
  final CentroVacunacion? centroTrabajo;

  EspecialistaSalud({
    required this.rut,
    required this.licencia,
    required this.nombres,
    required this.apellidos,
    required this.especialidad,
    this.centroTrabajo,
  });

  factory EspecialistaSalud.fromJson(Map<String, dynamic> json, List<CentroVacunacion> centros) {
    final centroNombre = json['centro_trabajo'] as String?;
    CentroVacunacion? centro;
    if (centroNombre != null) {
      try {
        centro = centros.firstWhere((c) => c.nombreCentro == centroNombre);
      } catch (_) {
        centro = null;
      }
    }

    return EspecialistaSalud(
      rut: json['rut'] as String,
      licencia: json['licencia'] as String,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      especialidad: json['especialidad'] as String,
      centroTrabajo: centro,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rut': rut,
      'licencia': licencia,
      'nombres': nombres,
      'apellidos': apellidos,
      'especialidad': especialidad,
      if (centroTrabajo != null) 'centro_trabajo': centroTrabajo!.nombreCentro,
    };
  }
}
