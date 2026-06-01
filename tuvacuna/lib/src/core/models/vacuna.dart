class Vacuna {
  final String nombre; // Agregado para identificar la vacuna (ej. "Covid19")
  final List<String> enfermedades; // Lista de enfermedades que cura

  Vacuna({
    required this.nombre,
    required this.enfermedades,
  });

  factory Vacuna.fromJson(Map<String, dynamic> json) {
    return Vacuna(
      nombre: json['nombre'] as String,
      enfermedades: List<String>.from(json['enfermedades']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'enfermedades': enfermedades,
    };
  }
}
