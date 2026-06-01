import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../data/citas_provider.dart';
import '../../../core/models/cita.dart';
import '../../../core/models/vacunacion.dart';
import '../../../core/data/database_controller.dart';

class EspecialistaHomeScreen extends ConsumerWidget {
  const EspecialistaHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final citas = ref.watch(citasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TuVacuna - Portal Especialista'),
        backgroundColor: Colors.teal.shade700,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Bienvenido Especialista, ${user?.name ?? ""}\nCitas Asignadas: ${citas.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: citas.isEmpty
                ? const Center(child: Text('No hay citas asignadas.'))
                : ListView.builder(
                    itemCount: citas.length,
                    itemBuilder: (context, index) {
                      final cita = citas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            cita.estadoCita == 'Pendiente' ? Icons.schedule :
                            cita.estadoCita == 'Completa' ? Icons.check_circle : Icons.cancel,
                            color: cita.estadoCita == 'Pendiente' ? Colors.orange :
                                   cita.estadoCita == 'Completa' ? Colors.green : Colors.red,
                          ),
                          title: Text('Paciente: ${cita.paciente.nombres} ${cita.paciente.apellidos}'),
                          subtitle: Text('Fecha: ${cita.fecha.day}/${cita.fecha.month}/${cita.fecha.year} - ${cita.hora}\nEstado: ${cita.estadoCita}'),
                          isThreeLine: true,
                          onTap: cita.estadoCita == 'Pendiente' ? () {
                            _mostrarDialogoGestionCita(context, ref, cita);
                          } : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoGestionCita(BuildContext parentContext, WidgetRef ref, Cita cita) {
    bool dosisAdministrada = true;
    final dosisController = TextEditingController(text: '1');
    final obsController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Gestionar Cita'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('¿Dosis administrada?'),
                      value: dosisAdministrada,
                      onChanged: (val) {
                        setState(() => dosisAdministrada = val);
                      },
                    ),
                    if (dosisAdministrada) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: dosisController,
                        decoration: const InputDecoration(
                          labelText: 'Número de dosis',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: obsController,
                      decoration: InputDecoration(
                        labelText: dosisAdministrada ? 'Observaciones/Reacciones' : 'Motivo de Cancelación (Requerido)',
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    if (!dosisAdministrada) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Al confirmar, esta cita será marcada como Cancelada.',
                        style: TextStyle(color: Colors.red),
                      )
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Volver'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final db = ref.read(databaseControllerProvider);
                    
                    Cita nuevaCita;
                    if (dosisAdministrada) {
                      final vacunacion = Vacunacion(
                        fechaAplicacion: DateTime.now(),
                        numeroDosis: int.tryParse(dosisController.text) ?? 1,
                        observacionesReacciones: obsController.text,
                        vacunaAplicada: db.getVacunas.first,
                        especialistaAdministrador: cita.especialista,
                      );
                      nuevaCita = cita.copyWith(
                        estadoCita: 'Completa',
                        vacunacion: vacunacion,
                        observaciones: obsController.text,
                      );
                    } else {
                      nuevaCita = cita.copyWith(
                        estadoCita: 'Cancelada',
                        observaciones: obsController.text,
                      );
                    }

                    ref.read(citasProvider.notifier).updateCita(cita, nuevaCita);
                    
                    Navigator.pop(dialogContext); // Pops the first dialog safely
                    
                    // Show Notification popup
                    final notificacion = db.getNotificaciones.last;
                    showDialog(
                      context: parentContext, // Uses parentContext safely
                      builder: (popupContext) => AlertDialog(
                        title: const Text('Notificación Simulada'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Canal: email', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(notificacion.mensaje, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(popupContext), // Pops the notification dialog
                            child: const Text('Aceptar'),
                          )
                        ],
                      )
                    );
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
