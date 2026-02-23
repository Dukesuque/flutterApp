import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock/mock_data.dart';
import '../../../models/activity_model.dart';

/// Pantalla de Actividad
/// Muestra las actividades del día, reuniones y notificaciones
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _selectedIndex = 1;
  late List<ActivityModel> _activities;
  late List<Map<String, dynamic>> _meetings;
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _activities = MockData.getMockActivities();
    _meetings = MockData.getMockMeetings();
    _notifications = MockData.getMockNotifications();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        // Ya estamos en Activity
        break;
      case 2:
        context.go('/summary');
        break;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.clockIn:
        return AppColors.success;
      case ActivityType.clockOut:
        return AppColors.error;
      case ActivityType.breakStart:
      case ActivityType.breakEnd:
        return AppColors.warning;
      case ActivityType.meeting:
        return AppColors.info;
      case ActivityType.absence:
        return AppColors.textSecondary;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.clockIn:
        return Icons.login_rounded;
      case ActivityType.clockOut:
        return Icons.logout_rounded;
      case ActivityType.breakStart:
        return Icons.pause_circle_outline;
      case ActivityType.breakEnd:
        return Icons.play_circle_outline;
      case ActivityType.meeting:
        return Icons.groups_outlined;
      case ActivityType.absence:
        return Icons.event_busy_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Tu Actividad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de actividades del día
            Text(
              'Actividades de hoy',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            if (_activities.isEmpty)
              _buildEmptyState('No hay actividades registradas hoy')
            else
              ..._activities.map((activity) => _buildActivityCard(activity)),

            const SizedBox(height: 24),

            // Sección de reuniones
            Text(
              'Reuniones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            if (_meetings.isEmpty)
              _buildEmptyState('No tienes reuniones programadas')
            else
              ..._meetings.map((meeting) => _buildMeetingCard(meeting)),

            const SizedBox(height: 24),

            // Sección de notificaciones
            Text(
              'Notificaciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            if (_notifications.isEmpty)
              _buildEmptyState('No tienes notificaciones nuevas')
            else
              ..._notifications.map((notification) => 
                  _buildNotificationCard(notification)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Actividad',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Resumen',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    final color = _getActivityColor(activity.type);
    final icon = _getActivityIcon(activity.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  activity.formattedTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (activity.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.iconSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.location!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(Map<String, dynamic> meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting['title'],
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${meeting['time']} • ${meeting['duration']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.iconSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                meeting['location'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.people_outline,
                size: 16,
                color: AppColors.iconSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${meeting['attendees']} personas',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isUnread = !(notification['read'] as bool);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread 
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? AppColors.primary.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isUnread ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['time'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
