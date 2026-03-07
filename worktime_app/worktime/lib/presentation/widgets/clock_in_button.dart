import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../state/activity_provider.dart';
import '../../state/session_provider.dart';
import '../../models/activity_model.dart';

/// Botón inteligente de fichaje
/// Detecta el estado y muestra la acción correcta
/// Integrado con el contador de tiempo
class ClockInButton extends StatelessWidget {
  const ClockInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ActivityProvider, SessionProvider>(
      builder: (context, authProvider, activityProvider, sessionProvider, child) {
        final lastActivity = activityProvider.lastActivity;
        final isCounterRunning = sessionProvider.isRunning;
        
        // Determinar siguiente acción
        final nextAction = _getNextAction(lastActivity, isCounterRunning);
        
        return SizedBox(
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
        );
      },
    );
  }

  ActionType _getNextAction(ActivityModel? lastActivity, bool isCounterRunning) {
    // Si el contador está corriendo → Salida
    if (isCounterRunning) {
      return ActionType.clockOut;
    }
    
    // Si no hay actividad → Entrada
    if (lastActivity == null) {
      return ActionType.clockIn;
    }
    
    // Basarse en la última actividad
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
          // ENTRADA: Iniciar contador + Guardar actividad
          activityType = ActivityType.clockIn;
          description = 'Entrada registrada';
          
          // Iniciar contador
          await sessionProvider.start();
          break;

        case ActionType.clockOut:
          // SALIDA: Detener contador + Guardar actividad
          activityType = ActivityType.clockOut;
          description = 'Salida registrada';
          
          // Detener contador
          await sessionProvider.stop();
          break;

        case ActionType.breakStart:
          // PAUSA: Pausar contador temporalmente
          activityType = ActivityType.breakStart;
          description = 'Pausa iniciada';
          // TODO: Implementar pausa del contador
          break;

        case ActionType.breakEnd:
          // FIN PAUSA: Reanudar contador
          activityType = ActivityType.breakEnd;
          description = 'Pausa finalizada';
          // TODO: Implementar reanudación del contador
          break;
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
}

/// Tipos de acciones disponibles
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