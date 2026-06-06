/// Clase Vacuna: Entidad base que almacena los detalles de una vacuna.
class Vacuna {
  final int id; // Added ID starting from 0 or as provided
  final String nombre; // Agregado para identificar la vacuna (ej. "Covid19")
  final List<String> enfermedades; // Lista de enfermedades que cura

  Vacuna({
    required this.id,
    required this.nombre,
    required this.enfermedades,
  });

  factory Vacuna.fromJson(Map<String, dynamic> json) {
    return Vacuna(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String,
      enfermedades: List<String>.from(json['enfermedades']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'enfermedades': enfermedades,
    };
  }

  /// Corresponde al mensaje: getEnfermedades() del diagrama de comunicación.
  List<String> getEnfermedades() {
    return enfermedades;
  }
}
