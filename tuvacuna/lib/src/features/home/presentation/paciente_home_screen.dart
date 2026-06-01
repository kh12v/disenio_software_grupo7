import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/data/database_controller.dart';
import '../../../core/models/campana.dart';
import '../../../core/models/centro_vacunacion.dart';
import '../../../core/models/cita.dart';
import '../data/citas_provider.dart';

class PacienteHomeScreen extends ConsumerStatefulWidget {
  const PacienteHomeScreen({super.key});

  @override
  ConsumerState<PacienteHomeScreen> createState() => _PacienteHomeScreenState();
}

class _PacienteHomeScreenState extends ConsumerState<PacienteHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TuVacuna - Portal Paciente'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _currentIndex == 0 ? const _MisCitasView() : const _AgendarCitaView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mis Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Agendar Cita',
          ),
        ],
      ),
    );
  }
}

class _MisCitasView extends ConsumerWidget {
  const _MisCitasView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citas = ref.watch(citasProvider);
    final user = ref.watch(authStateProvider);

    if (citas.isEmpty) {
      return Center(
        child: Text(
          'Bienvenido ${user?.name ?? ""}\n\nNo tienes citas agendadas.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Tienes ${citas.length} cita(s) agendada(s)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: citas.length,
            itemBuilder: (context, index) {
              final cita = citas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.green),
                  title: Text('${cita.fecha.day}/${cita.fecha.month}/${cita.fecha.year} - ${cita.hora}'),
                  subtitle: Text('${cita.centroVacunacion.nombreCentro}\nEstado: ${cita.estadoCita}'),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AgendarCitaView extends ConsumerStatefulWidget {
  const _AgendarCitaView();

  @override
  ConsumerState<_AgendarCitaView> createState() => _AgendarCitaViewState();
}

class _AgendarCitaViewState extends ConsumerState<_AgendarCitaView> {
  Campana? _selectedCampana;
  CentroVacunacion? _selectedCentro;
  String? _selectedHorario;

  // Opciones simuladas
  final List<String> _horariosSimulados = ['10:00 (02/07)', '12:30 (02/07)', '16:00 (02/07)', '09:00 (03/07)'];

  void _confirmarCita() {
    if (_selectedCampana == null || _selectedCentro == null || _selectedHorario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todas las opciones')),
      );
      return;
    }

    final db = ref.read(databaseControllerProvider);
    final user = ref.read(authStateProvider);
    
    // Find the Paciente
    final paciente = db.getPersonas.firstWhere((p) => p.rut == user?.rut);
    
    // Assign a specialist that works in the selected center
    final especialistasEnCentro = db.getEspecialistas.where((e) => e.centroTrabajo?.nombreCentro == _selectedCentro!.nombreCentro).toList();
    if (especialistasEnCentro.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay especialistas disponibles en el centro ${_selectedCentro!.nombreCentro}')),
      );
      return;
    }
    final especialista = especialistasEnCentro.first;

    // Parse the simulated date and time
    final isJuly2 = _selectedHorario!.contains('02/07');
    final fecha = DateTime(2026, 7, isJuly2 ? 2 : 3);
    final hora = _selectedHorario!.substring(0, 5);

    final nuevaCita = Cita(
      fecha: fecha,
      hora: hora,
      estadoCita: 'Pendiente',
      centroVacunacion: _selectedCentro!,
      paciente: paciente,
      especialista: especialista,
      campana: _selectedCampana,
    );

    // Save in Provider (which saves in DB)
    ref.read(citasProvider.notifier).addCita(nuevaCita);

    // Get the latest notification added
    final notificacion = db.getNotificaciones.last;

    // Show Notification Popup
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Cita Confirmada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Se ha creado tu cita exitosamente.', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Notificación Simulada:', style: TextStyle(color: Colors.grey)),
            Text('Canal: ${notificacion.canalEnvio}'),
            const SizedBox(height: 8),
            Text(notificacion.mensaje, style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() {
                _selectedCampana = null;
                _selectedCentro = null;
                _selectedHorario = null;
              });
            },
            child: const Text('Aceptar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseControllerProvider);
    final campanas = db.getCampanas;
    final centros = db.getCentros;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('1. Selecciona una Campaña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
            child: DropdownButton<Campana>(
              value: _selectedCampana,
              isExpanded: true,
              underline: const SizedBox(),
              hint: const Text('Elige una campaña'),
              items: campanas.map((c) => DropdownMenuItem(value: c, child: Text(c.nombreCampana))).toList(),
              onChanged: (val) => setState(() => _selectedCampana = val),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text('2. Selecciona un Centro de Vacunación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
            child: DropdownButton<CentroVacunacion>(
              value: _selectedCentro,
              isExpanded: true,
              underline: const SizedBox(),
              hint: const Text('Elige un centro'),
              items: centros.map((c) => DropdownMenuItem(value: c, child: Text(c.nombreCentro))).toList(),
              onChanged: (val) => setState(() => _selectedCentro = val),
            ),
          ),
          const SizedBox(height: 24),

          const Text('3. Selecciona Horario Disponible', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: _horariosSimulados.map((horario) {
              final isSelected = _selectedHorario == horario;
              return ChoiceChip(
                label: Text(horario),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedHorario = selected ? horario : null);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _confirmarCita,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Confirmar Cita', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
