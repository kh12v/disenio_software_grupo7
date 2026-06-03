import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database_controller.dart';
import '../../../core/models/campana.dart';

class CampanasNotifier extends Notifier<List<Campana>> {
  @override
  List<Campana> build() {
    final db = ref.watch(databaseControllerProvider);
    return db.getCampanas;
  }

  void addCampana(Campana campana) {
    final db = ref.read(databaseControllerProvider);
    db.campanas.add(campana);
    state = [...db.campanas];
  }

  void updateCampana(Campana oldCampana, Campana newCampana) {
    final db = ref.read(databaseControllerProvider);
    final index = db.campanas.indexOf(oldCampana);
    if (index != -1) {
      db.campanas[index] = newCampana;
      state = [...db.campanas];
    }
  }

  void deleteCampana(Campana campana) {
    final db = ref.read(databaseControllerProvider);
    db.campanas.remove(campana);
    state = [...db.campanas];
  }

  int countSuccessfulVaccinations(Campana campana) {
    final db = ref.read(databaseControllerProvider);
    return db.citas.where((cita) {
      return cita.estadoCita == 'Completa' && 
             cita.campana?.nombreCampana == campana.nombreCampana;
    }).length;
  }
}

final campanasProvider = NotifierProvider<CampanasNotifier, List<Campana>>(() {
  return CampanasNotifier();
});
