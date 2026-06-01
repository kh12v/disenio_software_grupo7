import 'dart:convert';
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

class DatabaseController {
  List<Campana> campanas = [];
  List<Paciente> personas = [];
  List<CentroVacunacion> centros = [];
  List<EspecialistaSalud> especialistas = [];
  List<Vacuna> vacunas = [];
  List<Organizador> organizadores = [];
  List<Cita> citas = [];
  List<Notificacion> notificaciones = [];

  bool _isInitialized = false;

  Future<void> initDatabase() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/simulated_db.json');
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
      print('Error al cargar la base de datos simulada: $e');
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
  List<Notificacion> get getNotificaciones => notificaciones;

  void addCita(Cita cita) {
    citas.add(cita);
  }

  void addNotificacion(Notificacion notificacion) {
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
