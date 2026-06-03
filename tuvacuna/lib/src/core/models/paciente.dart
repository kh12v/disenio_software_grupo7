class Paciente {
  final String rut;
  final String nombres;
  final String apellidos;
  final DateTime? fechaNacimiento;
  final String? telefono;
  final String? correo;

  Paciente({
    required this.rut,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    this.telefono,
    this.correo,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      rut: json['rut'] as String? ?? '',
      nombres: json['nombres'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      fechaNacimiento: json['fecha_nacimiento'] != null 
          ? DateTime.parse(json['fecha_nacimiento'] as String) 
          : null,
      telefono: json['telefono'] as String?,
      correo: json['correo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rut': rut,
      'nombres': nombres,
      'apellidos': apellidos,
      if (fechaNacimiento != null) 'fecha_nacimiento': fechaNacimiento!.toIso8601String(),
      if (telefono != null) 'telefono': telefono,
      if (correo != null) 'correo': correo,
    };
  }
}
