import 'vacuna.dart';

class CentroVacunacion {
  final String nombreCentro;
  final String direccion;
  final String tipoFinanciamiento; // Ej: 'público' o 'privado'
  final int capacidadAtencion;
  final String horarioAtencion;
  
  // Stock de vacunas: Cada centro de vacunación posee cierta cantidad de stock de cierta vacuna
  final Map<Vacuna, int> stockVacunas;

  CentroVacunacion({
    required this.nombreCentro,
    required this.direccion,
    required this.tipoFinanciamiento,
    required this.capacidadAtencion,
    required this.horarioAtencion,
    this.stockVacunas = const {},
  });

  factory CentroVacunacion.fromJson(Map<String, dynamic> json, List<Vacuna> todasLasVacunas) {
    final stockMap = json['stock_vacunas'] as Map<String, dynamic>? ?? {};
    final stockVacunas = <Vacuna, int>{};
    
    stockMap.forEach((key, value) {
      final vacuna = todasLasVacunas.firstWhere(
        (v) => v.nombre == key, 
        orElse: () => Vacuna(nombre: key, enfermedades: []),
      );
      stockVacunas[vacuna] = value as int;
    });

    return CentroVacunacion(
      nombreCentro: json['nombre_centro'] as String,
      direccion: json['direccion'] as String,
      tipoFinanciamiento: json['tipo_financiamiento'] as String,
      capacidadAtencion: json['capacidad_atencion'] as int,
      horarioAtencion: json['horario_atencion'] as String,
      stockVacunas: stockVacunas,
    );
  }

  Map<String, dynamic> toJson() {
    final stockMap = <String, int>{};
    stockVacunas.forEach((vacuna, cantidad) {
      stockMap[vacuna.nombre] = cantidad;
    });

    return {
      'nombre_centro': nombreCentro,
      'direccion': direccion,
      'tipo_financiamiento': tipoFinanciamiento,
      'capacidad_atencion': capacidadAtencion,
      'horario_atencion': horarioAtencion,
      'stock_vacunas': stockMap,
    };
  }
}
