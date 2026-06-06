import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campana.dart';
import '../models/paciente.dart';
import '../models/centro_vacunacion.dart';
import '../models/especialista_salud.dart';
import '../models/vacuna.dart';
import '../models/organizador.dart';
import '../models/cita.dart';
import '../models/notificacion.dart';

final databaseControllerProvider = Provider<DatabaseController>((ref) {
  throw UnimplementedError('DatabaseController not initialized');
});

// Clase utilizada para manejar la base de datos simulada.
// Actuá como interface entre la base de datos y el sistema en general
class DatabaseController {
  List<Campana> campanas = [];
  List<Paciente> personas = [];
  List<CentroVacunacion> centros = [];
  List<EspecialistaSalud> especialistas = [];
  List<Vacuna> vacunas = [];
  List<Organizador> organizadores = [];
  List<Cita> citas = [];
  List<INotificacion> notificaciones = [];

  bool _isInitialized = false;

  Future<void> initDatabase() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/simulated_db.json');
      _parseJson(jsonString);
    } catch (e) {
      print('Error al cargar la base de datos simulada: $e');
    }
  }

  void initDatabaseSync() {
    if (_isInitialized) return;

    try {
      final file = File('assets/simulated_db.json');
      if (file.existsSync()) {
        final jsonString = file.readAsStringSync();
        _parseJson(jsonString);
      }
    } catch (e) {
      print('Error al cargar la base de datos de forma síncrona: $e');
    }
  }

  void _parseJson(String jsonString) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);

      if (data['vacunas'] != null) {
        vacunas = (data['vacunas'] as List)
            .map((e) => Vacuna.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data['campanas'] != null) {
        campanas = (data['campanas'] as List)
            .map((e) => Campana.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data['personas'] != null) {
        personas = (data['personas'] as List)
            .map((e) => Paciente.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data['organizadores'] != null) {
        organizadores = (data['organizadores'] as List)
            .map((e) => Organizador.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data['centros'] != null) {
        centros = (data['centros'] as List)
            .map((e) => CentroVacunacion.fromJson(e as Map<String, dynamic>, vacunas))
            .toList();
      }

      if (data['especialistas'] != null) {
        especialistas = (data['especialistas'] as List)
            .map((e) => EspecialistaSalud.fromJson(e as Map<String, dynamic>, centros))
            .toList();
      }

      _isInitialized = true;
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  // Getters
  List<Campana> get getCampanas => campanas;
  List<Paciente> get getPersonas => personas;
  List<CentroVacunacion> get getCentros => centros;
  List<EspecialistaSalud> get getEspecialistas => especialistas;
  List<Vacuna> get getVacunas => vacunas;
  List<Organizador> get getOrganizadores => organizadores;
  List<Cita> get getCitas => citas;
  List<INotificacion> get getNotificaciones => notificaciones;

  bool estaHorarioDisponible(CentroVacunacion centro, DateTime fecha, String hora) {
    return !citas.any((cita) {
      return cita.centroVacunacion.nombreCentro == centro.nombreCentro &&
          cita.fecha.year == fecha.year &&
          cita.fecha.month == fecha.month &&
          cita.fecha.day == fecha.day &&
          cita.hora == hora;
    });
  }

  bool addCita(Cita cita) {
    if (!estaHorarioDisponible(cita.centroVacunacion, cita.fecha, cita.hora)) {
      return false;
    }

    citas.add(cita);
    return true;
  }

  void addNotificacion(INotificacion notificacion) {
    notificaciones.add(notificacion);
  }

  // Simulate save/update by returning the JSON string of the current memory state
  String exportToJson() {
    final data = {
      'campanas': campanas.map((c) => c.toJson()).toList(),
      'personas': personas.map((p) => p.toJson()).toList(),
      'centros': centros.map((c) => c.toJson()).toList(),
      'especialistas': especialistas.map((e) => e.toJson()).toList(),
      'vacunas': vacunas.map((v) => v.toJson()).toList(),
      'organizadores': organizadores.map((o) => o.toJson()).toList(),
    };
    return json.encode(data);
  }
}
