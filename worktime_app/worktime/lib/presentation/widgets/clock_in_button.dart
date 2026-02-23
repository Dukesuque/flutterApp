import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../state/activity_provider.dart';
import '../../models/activity_model.dart';

/// Botón inteligente de fichaje
/// Detecta el estado actual y muestra la acción apropiada
class ClockInButton extends StatelessWidget {
  const ClockInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ActivityProvider>(
      builder: (context, authProvider, activityProvider, child) {
        final lastActivity = activityProvider.lastActivity;
        final userId = authProvider.currentUser?.id ?? '1';

        final nextActivityType = _getNextActivityType(lastActivity);
        final buttonInfo = _getButtonInfo(nextActivityType);

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: activityProvider.isLoading
                ? null
                : () => _handleClockAction(
                      context,
                      userId,
                      nextActivityType,
                      activityProvider,
                    ),
            icon: Icon(buttonInfo.icon),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonInfo.color,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            label: activityProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    buttonInfo.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  ActivityType _getNextActivityType(ActivityModel? lastActivity) {
    if (lastActivity == null) return ActivityType.clockIn;

    switch (lastActivity.type) {
      case ActivityType.clockIn:
      case ActivityType.breakEnd:
        return ActivityType.clockOut;
      case ActivityType.clockOut:
      case ActivityType.absence:
        return ActivityType.clockIn;
      case ActivityType.breakStart:
        return ActivityType.breakEnd;
      case ActivityType.meeting:
        return ActivityType.clockOut;
    }
  }

  _ButtonInfo _getButtonInfo(ActivityType type) {
    switch (type) {
      case ActivityType.clockIn:
        return _ButtonInfo(
          label: 'Fichar Entrada',
          icon: Icons.login,
          color: const Color(0xFF4CAF50),
        );
      case ActivityType.clockOut:
        return _ButtonInfo(
          label: 'Fichar Salida',
          icon: Icons.logout,
          color: const Color(0xFFFF5252),
        );
      case ActivityType.breakStart:
        return _ButtonInfo(
          label: 'Iniciar Pausa',
          icon: Icons.pause_circle,
          color: const Color(0xFFFFB300),
        );
      case ActivityType.breakEnd:
        return _ButtonInfo(
          label: 'Terminar Pausa',
          icon: Icons.play_circle,
          color: const Color(0xFF4DA3FF),
        );
      case ActivityType.meeting:
        return _ButtonInfo(
          label: 'Iniciar Reunión',
          icon: Icons.groups,
          color: const Color(0xFF42A5F5),
        );
      case ActivityType.absence:
        return _ButtonInfo(
          label: 'Marcar Ausencia',
          icon: Icons.cancel,
          color: const Color(0xFF7C7F85),
        );
    }
  }

  Future<void> _handleClockAction(
    BuildContext context,
    String userId,
    ActivityType type,
    ActivityProvider activityProvider,
  ) async {
    final newActivity = ActivityModel(
      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: type,
      timestamp: DateTime.now(),
      description: _getDescription(type),
      location: 'Oficina Central',
    );

    final success = await activityProvider.addActivity(newActivity);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_getButtonInfo(type).icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      type.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatTime(DateTime.now()),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: _getButtonInfo(type).color,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getDescription(ActivityType type) {
    switch (type) {
      case ActivityType.clockIn:
        return 'Entrada al trabajo';
      case ActivityType.clockOut:
        return 'Salida del trabajo';
      case ActivityType.breakStart:
        return 'Inicio de pausa';
      case ActivityType.breakEnd:
        return 'Fin de pausa';
      case ActivityType.meeting:
        return 'Reunión';
      case ActivityType.absence:
        return 'Ausencia';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _ButtonInfo {
  final String label;
  final IconData icon;
  final Color color;

  _ButtonInfo({
    required this.label,
    required this.icon,
    required this.color,
  });
}