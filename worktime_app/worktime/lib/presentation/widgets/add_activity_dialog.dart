import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../state/activity_provider.dart';
import '../../models/activity_model.dart';

/// Diálogo para añadir una actividad manualmente
class AddActivityDialog extends StatefulWidget {
  const AddActivityDialog({super.key});

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  ActivityType _selectedType = ActivityType.clockIn;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descriptionController.text = _getDefaultDescription(_selectedType);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Nueva Actividad',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Selector de tipo
                Text(
                  'Tipo de actividad',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ActivityType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return ChoiceChip(
                      label: Text(type.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedType = type;
                            _descriptionController.text = _getDefaultDescription(type);
                          });
                        }
                      },
                      selectedColor: Color(type.colorValue).withOpacity(0.3),
                      avatar: isSelected
                          ? Icon(
                              _getIconForType(type),
                              size: 18,
                              color: Color(type.colorValue),
                            )
                          : null,
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Fecha y hora
                Text(
                  'Fecha y hora',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_formatDate(_selectedDate)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Descripción
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Ej: Entrada al trabajo',
                    prefixIcon: Icon(Icons.description),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                
                const SizedBox(height: 16),
                
                // Ubicación
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación (opcional)',
                    hintText: 'Ej: Oficina Central',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                
                const SizedBox(height: 16),
                
                // Notas
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Información adicional',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                
                const SizedBox(height: 24),
                
                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _saveActivity,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveActivity() async {
    final description = _descriptionController.text.trim();
    
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa una descripción'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final activityProvider = context.read<ActivityProvider>();
    final userId = authProvider.currentUser?.id ?? '1';

    final timestamp = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final activity = ActivityModel(
      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: _selectedType,
      timestamp: timestamp,
      description: description,
      location: _locationController.text.trim().isEmpty 
          ? null 
          : _locationController.text.trim(),
      notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
    );

    final success = await activityProvider.addActivity(activity);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_getIconForType(_selectedType), color: Colors.white),
              const SizedBox(width: 12),
              const Text('Actividad añadida correctamente'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(activityProvider.errorMessage ?? 'Error al guardar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getDefaultDescription(ActivityType type) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == yesterday) {
      return 'Ayer';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getIconForType(ActivityType type) {
    switch (type.iconName) {
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