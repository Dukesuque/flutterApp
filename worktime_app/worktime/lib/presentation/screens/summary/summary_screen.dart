import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/auth_provider.dart';
import '../../../state/summary_provider.dart';
import '../../../models/summary_model.dart';
import '../../widgets/app_bottom_nav_bar.dart';

/// Summary Screen - Resumen mensual mejorado
/// Muestra estadísticas y calendario visual del mes
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? '1';
    context.read<SummaryProvider>().loadCurrentSummary(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen Mensual'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Ir a mes actual',
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              final userId = authProvider.currentUser?.id ?? '1';
              context.read<SummaryProvider>().goToCurrentMonth(userId);
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, SummaryProvider>(
        builder: (context, authProvider, summaryProvider, child) {
          // Estado de carga
          if (summaryProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final summary = summaryProvider.currentSummary;
          
          // Sin datos
          if (summary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 80,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay datos disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Comienza a fichar para ver tu resumen',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final userId = authProvider.currentUser?.id ?? '1';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== NAVEGACIÓN DE MES ==========
                _buildMonthNavigation(context, summaryProvider, userId),
                
                const SizedBox(height: 24),
                
                // ========== ESTADÍSTICAS PRINCIPALES ==========
                _buildMainStats(context, summary),
                
                const SizedBox(height: 24),
                
                // ========== BARRA DE PROGRESO ==========
                _buildProgressCard(context, summary),
                
                const SizedBox(height: 24),
                
                // ========== CALENDARIO VISUAL ==========
                _buildCalendar(context, summary),
                
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  /// Navegación de mes (flechas + nombre del mes)
  Widget _buildMonthNavigation(
    BuildContext context,
    SummaryProvider summaryProvider,
    String userId,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => summaryProvider.goToPreviousMonth(userId),
            ),
            Text(
              summaryProvider.selectedPeriod,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => summaryProvider.goToNextMonth(userId),
            ),
          ],
        ),
      ),
    );
  }

  /// Estadísticas principales en grid 2x2
  Widget _buildMainStats(BuildContext context, SummaryModel summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Trabajadas',
                '${summary.totalHours.toStringAsFixed(1)}h',
                Icons.access_time,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Esperadas',
                '${summary.expectedHours.toStringAsFixed(0)}h',
                Icons.schedule,
                Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Progreso',
                '${summary.completionPercentage.toStringAsFixed(0)}%',
                Icons.trending_up,
                summary.isComplete ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                summary.extraHours >= 0 ? 'Extra' : 'Pendientes',
                '${summary.extraHours.abs().toStringAsFixed(1)}h',
                summary.extraHours >= 0 ? Icons.add_circle : Icons.remove_circle,
                summary.extraHours >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Card individual de estadística
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card con barra de progreso del mes
  Widget _buildProgressCard(BuildContext context, SummaryModel summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso del mes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${summary.completionPercentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (summary.completionPercentage / 100).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  summary.isComplete ? Colors.green : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trabajadas: ${summary.totalHours.toStringAsFixed(1)}h',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Objetivo: ${summary.expectedHours.toStringAsFixed(0)}h',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Calendario visual del mes
  Widget _buildCalendar(BuildContext context, SummaryModel summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendario del mes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Headers de días de la semana
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                  .map((day) => SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            day,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            
            const SizedBox(height: 8),
            
            // Días del mes
            _buildCalendarDays(context, summary),
            
            const SizedBox(height: 16),
            
            // Leyenda
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  /// Días del calendario organizados en semanas
  Widget _buildCalendarDays(BuildContext context, SummaryModel summary) {
    final firstDay = DateTime(summary.year, summary.month, 1);
    final lastDay = DateTime(summary.year, summary.month + 1, 0);
    final daysInMonth = lastDay.day;
    
    // Calcular offset inicial (1 = lunes, 7 = domingo)
    int startOffset = firstDay.weekday - 1;
    
    // Crear lista de widgets para los días
    List<Widget> dayWidgets = [];
    
    // Añadir espacios vacíos antes del primer día
    for (int i = 0; i < startOffset; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }
    
    // Añadir los días del mes
    for (int day = 1; day <= daysInMonth; day++) {
      final dailySummary = summary.dailySummaries.firstWhere(
        (ds) => ds.day == day,
        orElse: () => DailySummary(
          date: DateTime(summary.year, summary.month, day),
          hours: 0,
          status: DayStatus.pending,
        ),
      );
      
      dayWidgets.add(_buildDayCell(context, day, dailySummary));
    }
    
    // Organizar en filas de 7 días
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayWidgets.sublist(
              i,
              (i + 7 < dayWidgets.length) ? i + 7 : dayWidgets.length,
            ),
          ),
        ),
      );
    }
    
    return Column(children: rows);
  }

  /// Celda individual de día en el calendario
  Widget _buildDayCell(BuildContext context, int day, DailySummary dailySummary) {
    Color backgroundColor;
    Color textColor;
    
    switch (dailySummary.status) {
      case DayStatus.complete:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
      case DayStatus.incomplete:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        break;
      case DayStatus.absence:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        break;
      case DayStatus.pending:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        break;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (dailySummary.hours > 0)
              Text(
                '${dailySummary.hours.toStringAsFixed(0)}h',
                style: TextStyle(
                  fontSize: 8,
                  color: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Leyenda de colores del calendario
  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(context, Colors.green, 'Completo (≥8h)'),
        _buildLegendItem(context, Colors.orange, 'Incompleto (<8h)'),
        _buildLegendItem(context, Colors.grey, 'Sin fichar'),
      ],
    );
  }

  /// Item individual de la leyenda
  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}