import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/activity_provider.dart';
import '../../../models/activity_model.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/add_activity_dialog.dart';

/// Activity Screen - Historial de actividades
/// Muestra todas las actividades del usuario con filtros
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividad'),
        actions: [
          // Botón de filtro
          PopupMenuButton<ActivityType?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar por tipo',
            onSelected: (type) {
              context.read<ActivityProvider>().setFilter(type);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todas'),
              ),
              ...ActivityType.values.map((type) {
                return PopupMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getIconForType(type.iconName),
                        size: 20,
                        color: Color(type.colorValue),
                      ),
                      const SizedBox(width: 12),
                      Text(type.displayName),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, activityProvider, child) {
          // Estado de carga
          if (activityProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final activities = activityProvider.filteredActivities;

          // Sin actividades
          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No hay actividades',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activityProvider.filterType != null
                        ? 'No hay actividades de este tipo'
                        : 'Comienza fichando tu entrada',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (activityProvider.filterType != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        activityProvider.clearFilter();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpiar filtro'),
                    ),
                  ],
                ],
              ),
            );
          }

          // Lista de actividades
          return Column(
            children: [
              // Indicador de filtro activo
              if (activityProvider.filterType != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Filtrado por: ${activityProvider.filterType!.displayName}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => activityProvider.clearFilter(),
                        child: const Text('Limpiar'),
                      ),
                    ],
                  ),
                ),
              
              // Lista
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    final isToday = _isToday(activity.timestamp);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Color(activity.type.colorValue),
                          child: Icon(
                            _getIconForType(activity.type.iconName),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          activity.type.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(activity.description),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${activity.formattedTime} • ${activity.formattedDate}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            if (activity.location != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    activity.location!,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: isToday
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'HOY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddActivityDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  IconData _getIconForType(String iconName) {
    switch (iconName) {
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'pause':
        return Icons.pause;
      case 'play':
        return Icons.play_arrow;
      case 'meeting':
        return Icons.groups;
      case 'cancel':
        return Icons.cancel;
      default:
        return Icons.access_time;
    }
  }
}