import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../state/activity_provider.dart';
import '../../state/session_provider.dart';
import '../../models/activity_model.dart';

class ClockInButton extends StatelessWidget {
  const ClockInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ActivityProvider, SessionProvider>(
      builder: (context, authProvider, activityProvider, sessionProvider, child) {
        final lastActivity = activityProvider.lastActivity;
        final isRunning = sessionProvider.isRunning;
        final isPaused = sessionProvider.isPaused;

        final nextAction = _getNextAction(lastActivity, isRunning, isPaused);

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleAction(
                  context,
                  authProvider,
                  activityProvider,
                  sessionProvider,
                  nextAction,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(nextAction.colorValue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(nextAction.icon, size: 24),
                label: Text(
                  nextAction.label,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (isRunning && !isPaused) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handlePause(
                    context,
                    authProvider,
                    activityProvider,
                    sessionProvider,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFB300),
                    side: const BorderSide(color: Color(0xFFFFB300)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.pause, size: 20),
                  label: const Text(
                    'Iniciar Pausa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  ActionType _getNextAction(ActivityModel? lastActivity, bool isRunning, bool isPaused) {
    if (isPaused) return ActionType.breakEnd;
    if (isRunning) return ActionType.clockOut;
    if (lastActivity == null) return ActionType.clockIn;

    switch (lastActivity.type) {
      case ActivityType.clockIn:
      case ActivityType.breakEnd:
        return ActionType.clockOut;
      case ActivityType.clockOut:
      case ActivityType.absence:
        return ActionType.clockIn;
      case ActivityType.breakStart:
        return ActionType.breakEnd;
      default:
        return ActionType.clockIn;
    }
  }

  Future<void> _handleAction(
    BuildContext context,
    AuthProvider authProvider,
    ActivityProvider activityProvider,
    SessionProvider sessionProvider,
    ActionType action,
  ) async {
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    try {
      ActivityType activityType;
      String description;

      switch (action) {
        case ActionType.clockIn:
          activityType = ActivityType.clockIn;
          description = 'Entrada registrada';
          await sessionProvider.start();
          break;

        case ActionType.clockOut:
          activityType = ActivityType.clockOut;
          description = 'Salida registrada';
          await sessionProvider.stop();
          break;

        case ActionType.breakEnd:
          activityType = ActivityType.breakEnd;
          description = 'Pausa finalizada';
          await sessionProvider.resume();
          break;

        default:
          return;
      }

      // Crear y guardar actividad
      final activity = ActivityModel(
        id: 'activity_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: activityType,
        timestamp: DateTime.now(),
        description: description,
      );

      final success = await activityProvider.addActivity(activity);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(description),
            backgroundColor: Color(activityType.colorValue),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePause(
    BuildContext context,
    AuthProvider authProvider,
    ActivityProvider activityProvider,
    SessionProvider sessionProvider,
  ) async {
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    try {
      await sessionProvider.pause();

      final activity = ActivityModel(
        id: 'activity_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: ActivityType.breakStart,
        timestamp: DateTime.now(),
        description: 'Pausa iniciada',
      );

      await activityProvider.addActivity(activity);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pausa iniciada'),
            backgroundColor: Color(0xFFFFB300),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

enum ActionType {
  clockIn,
  clockOut,
  breakStart,
  breakEnd,
}

extension ActionTypeExtension on ActionType {
  String get label {
    switch (this) {
      case ActionType.clockIn:
        return 'Fichar Entrada';
      case ActionType.clockOut:
        return 'Fichar Salida';
      case ActionType.breakStart:
        return 'Iniciar Pausa';
      case ActionType.breakEnd:
        return 'Finalizar Pausa';
    }
  }

  IconData get icon {
    switch (this) {
      case ActionType.clockIn:
        return Icons.login;
      case ActionType.clockOut:
        return Icons.logout;
      case ActionType.breakStart:
        return Icons.pause;
      case ActionType.breakEnd:
        return Icons.play_arrow;
    }
  }

  int get colorValue {
    switch (this) {
      case ActionType.clockIn:
        return 0xFF4CAF50; // Verde
      case ActionType.clockOut:
        return 0xFFFF5252; // Rojo
      case ActionType.breakStart:
        return 0xFFFFB300; // Amarillo
      case ActionType.breakEnd:
        return 0xFF4DA3FF; // Azul
    }
  }
}