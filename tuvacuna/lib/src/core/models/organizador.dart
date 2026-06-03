class Organizador {
  final String rut;
  final String nombres;
  final String apellidos;
  final String cargo;

  Organizador({
    required this.rut,
    required this.nombres,
    required this.apellidos,
    required this.cargo,
  });

  factory Organizador.fromJson(Map<String, dynamic> json) {
    return Organizador(
      rut: json['rut'] as String,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      cargo: json['cargo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rut': rut,
      'nombres': nombres,
      'apellidos': apellidos,
      'cargo': cargo,
    };
  }
}
