import 'vacuna.dart';
import 'cita.dart';
import 'paciente.dart';
import 'especialista_salud.dart';
import '../data/database_controller.dart';

class CentroVacunacion {
  final String id;
  final String nombreCentro;
  final String direccion;
  final String tipoFinanciamiento; // Ej: 'público' o 'privado'
  final int capacidadAtencion;
  final String horarioAtencion;
  
  // Stock de vacunas: Cada centro de vacunación posee cierta cantidad de stock de cierta vacuna
  final Map<Vacuna, int> stockVacunas;

  CentroVacunacion({
    required this.id,
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
        orElse: () => Vacuna(id: 0, nombre: key, enfermedades: []),
      );
      stockVacunas[vacuna] = value as int;
    });

    return CentroVacunacion(
      id: json['id'] as String? ?? 'unknown',
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
      'id': id,
      'nombre_centro': nombreCentro,
      'direccion': direccion,
      'tipo_financiamiento': tipoFinanciamiento,
      'capacidad_atencion': capacidadAtencion,
      'horario_atencion': horarioAtencion,
      'stock_vacunas': stockMap,
    };
  }

  Cita agregarCita(String rutPaciente, String rutEspecialista, DateTime fecha, String hora, DatabaseController db) {
    Paciente p = buscarPaciente(rutPaciente, db);
    EspecialistaSalud especialista = buscarEspecialista(rutEspecialista, db);
    return Cita.create(fecha, hora, p, this, especialista);
  }

  Paciente buscarPaciente(String rutPaciente, DatabaseController db) {
    return db.getPersonas.firstWhere((p) => p.rut == rutPaciente, orElse: () => throw Exception("Paciente no encontrado con el RUT: $rutPaciente"));
  }

  EspecialistaSalud buscarEspecialista(String rutEspecialista, DatabaseController db) {
    return db.getEspecialistas.firstWhere((e) => e.rut == rutEspecialista, orElse: () => throw Exception("Especialista no encontrado con el RUT: $rutEspecialista"));
  }
}
