import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/models/campana.dart';
import '../data/campanas_provider.dart';

class OrganizadorHomeScreen extends ConsumerWidget {
  const OrganizadorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final campanas = ref.watch(campanasProvider);
    final notifier = ref.read(campanasProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TuVacuna - Portal Organizador'),
        backgroundColor: Colors.blue.shade800,
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
              'Bienvenido Organizador, ${user?.name ?? ""}\nGestión de Campañas',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: campanas.isEmpty
                ? const Center(child: Text('No hay campañas activas.'))
                : ListView.builder(
                    itemCount: campanas.length,
                    itemBuilder: (context, index) {
                      final campana = campanas[index];
                      final count = notifier.countSuccessfulVaccinations(campana);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ExpansionTile(
                          leading: const Icon(Icons.campaign, color: Colors.blue),
                          title: Text(campana.nombreCampana, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Vacunaciones completadas: $count'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Enfermedad: ${campana.enfermedadObjetivo}'),
                                  Text('Población Objetivo: ${campana.poblacionObjetivo}'),
                                  Text('Fechas: ${campana.fechaInicio.day}/${campana.fechaInicio.month}/${campana.fechaInicio.year} - ${campana.fechaFin.day}/${campana.fechaFin.month}/${campana.fechaFin.year}'),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _mostrarDialogoCampana(context, ref, campana: campana),
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        label: const Text('Editar'),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () {
                                          notifier.deleteCampana(campana);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Campaña eliminada (las citas asociadas quedan huérfanas)')),
                                          );
                                        },
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCampana(context, ref),
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _mostrarDialogoCampana(BuildContext context, WidgetRef ref, {Campana? campana}) {
    final isEditing = campana != null;
    
    final nombreController = TextEditingController(text: campana?.nombreCampana ?? '');
    final enfermedadController = TextEditingController(text: campana?.enfermedadObjetivo ?? '');
    final poblacionController = TextEditingController(text: campana?.poblacionObjetivo ?? '');
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Campaña' : 'Nueva Campaña'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre de la Campaña'),
                ),
                TextField(
                  controller: enfermedadController,
                  decoration: const InputDecoration(labelText: 'Enfermedad Objetivo'),
                ),
                TextField(
                  controller: poblacionController,
                  decoration: const InputDecoration(labelText: 'Población Objetivo'),
                ),
                const SizedBox(height: 16),
                const Text('Nota: Para la demo, las fechas por defecto son el mes actual.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
              onPressed: () {
                if (nombreController.text.trim().isEmpty) return;
                
                final now = DateTime.now();
                final newCampana = Campana(
                  nombreCampana: nombreController.text.trim(),
                  enfermedadObjetivo: enfermedadController.text.trim(),
                  poblacionObjetivo: poblacionController.text.trim(),
                  fechaInicio: campana?.fechaInicio ?? now,
                  fechaFin: campana?.fechaFin ?? now.add(const Duration(days: 30)),
                );

                if (isEditing) {
                  ref.read(campanasProvider.notifier).updateCampana(campana, newCampana);
                } else {
                  ref.read(campanasProvider.notifier).addCampana(newCampana);
                }

                Navigator.pop(dialogContext);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
