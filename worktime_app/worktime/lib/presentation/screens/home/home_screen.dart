import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/auth_provider.dart';
import '../../../state/activity_provider.dart';
import '../../../models/activity_model.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/clock_in_button.dart';
import '../../widgets/add_activity_dialog.dart';

/// Home Screen - Pantalla principal / Dashboard
/// Muestra el estado actual, botón de fichaje y resumen del día
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? '1';
    context.read<ActivityProvider>().loadActivities(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkTime'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer2<AuthProvider, ActivityProvider>(
        builder: (context, authProvider, activityProvider, child) {
          final userName = authProvider.userName;
          final todayActivities = activityProvider.todayActivities;
          final lastActivity = activityProvider.lastActivity;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $userName!',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Hoy es ${_getFormattedDate()}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _getStatusColor(lastActivity).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getStatusIcon(lastActivity),
                            size: 48,
                            color: _getStatusColor(lastActivity),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          _getStatusText(lastActivity),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        
                        if (lastActivity != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Última actividad: ${lastActivity.formattedTime}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastActivity.type.displayName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Color(lastActivity.type.colorValue),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        const ClockInButton(),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Resumen de hoy',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const AddActivityDialog(),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.checklist,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${todayActivities.length} actividades',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'registradas hoy',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (todayActivities.isNotEmpty)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                if (todayActivities.isNotEmpty) ...[
                  Text(
                    'Últimas actividades',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...todayActivities.take(3).map((activity) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(activity.type.colorValue).withOpacity(0.2),
                          child: Icon(
                            _getIconForType(activity.type.iconName),
                            color: Color(activity.type.colorValue),
                            size: 20,
                          ),
                        ),
                        title: Text(activity.type.displayName),
                        subtitle: Text(activity.description),
                        trailing: Text(
                          activity.formattedTime,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    );
                  }),
                ],
                
                const SizedBox(height: 32),
                
                Text(
                  'Acciones rápidas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                _buildActionButton(
                  context,
                  'Ver Historial Completo',
                  Icons.history,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ve a la pestaña "Actividad" para ver todo'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  context,
                  'Solicitar Ausencia',
                  Icons.event_busy,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(label),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 
                   'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    
    return '${days[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
  }

  IconData _getStatusIcon(ActivityModel? lastActivity) {
    if (lastActivity == null) return Icons.login;
    
    switch (lastActivity.type) {
      case ActivityType.clockIn:
      case ActivityType.breakEnd:
        return Icons.work;
      case ActivityType.clockOut:
        return Icons.home;
      case ActivityType.breakStart:
        return Icons.pause_circle;
      default:
        return Icons.access_time;
    }
  }

  Color _getStatusColor(ActivityModel? lastActivity) {
    if (lastActivity == null) return const Color(0xFF4CAF50);
    
    switch (lastActivity.type) {
      case ActivityType.clockIn:
      case ActivityType.breakEnd:
        return const Color(0xFF4CAF50);
      case ActivityType.clockOut:
        return const Color(0xFFFF5252);
      case ActivityType.breakStart:
        return const Color(0xFFFFB300);
      default:
        return const Color(0xFF4DA3FF);
    }
  }

  String _getStatusText(ActivityModel? lastActivity) {
    if (lastActivity == null) return 'Listo para fichar';
    
    switch (lastActivity.type) {
      case ActivityType.clockIn:
      case ActivityType.breakEnd:
        return 'En el trabajo';
      case ActivityType.clockOut:
        return 'Fuera del trabajo';
      case ActivityType.breakStart:
        return 'En pausa';
      default:
        return 'Estado desconocido';
    }
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