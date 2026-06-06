// Clase utilizada como modelo de datos para registrar las campañas de vacunación
class Campana {
  final String nombreCampana;
  final String enfermedadObjetivo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String poblacionObjetivo;

  Campana({
    required this.nombreCampana,
    required this.enfermedadObjetivo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.poblacionObjetivo,
  });

  Campana copyWith({
    String? nombreCampana,
    String? enfermedadObjetivo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? poblacionObjetivo,
  }) {
    return Campana(
      nombreCampana: nombreCampana ?? this.nombreCampana,
      enfermedadObjetivo: enfermedadObjetivo ?? this.enfermedadObjetivo,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      poblacionObjetivo: poblacionObjetivo ?? this.poblacionObjetivo,
    );
  }

  factory Campana.fromJson(Map<String, dynamic> json) {
    return Campana(
      nombreCampana: json['nombre_campaña'] as String,
      enfermedadObjetivo: json['enfermedad_objetivo'] as String,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: DateTime.parse(json['fecha_fin'] as String),
      poblacionObjetivo: json['poblacion_objetivo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_campaña': nombreCampana,
      'enfermedad_objetivo': enfermedadObjetivo,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'poblacion_objetivo': poblacionObjetivo,
    };
  }
}
