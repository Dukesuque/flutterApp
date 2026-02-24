import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/auth_provider.dart';
import '../../../state/summary_provider.dart';
import '../../widgets/app_bottom_nav_bar.dart';

/// Summary Screen - Resumen mensual
/// Muestra estadísticas y progreso del mes
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
        title: Consumer<SummaryProvider>(
          builder: (context, summaryProvider, child) {
            return Text(summaryProvider.selectedPeriod);
          },
        ),
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
            return const Center(
              child: Text('No hay datos disponibles'),
            );
          }

          final userId = authProvider.currentUser?.id ?? '1';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navegación de mes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        summaryProvider.goToPreviousMonth(userId);
                      },
                    ),
                    Text(
                      summaryProvider.selectedPeriod,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        summaryProvider.goToNextMonth(userId);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Estadísticas principales en grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Horas trabajadas',
                        '${summary.totalHours.toStringAsFixed(1)}h',
                        Icons.access_time,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Horas esperadas',
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
                        '${summary.completionPercentage.toStringAsFixed(1)}%',
                        Icons.trending_up,
                        summary.isComplete ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        summary.extraHours >= 0 ? 'Horas extra' : 'Pendientes',
                        '${summary.extraHours.abs().toStringAsFixed(1)}h',
                        summary.extraHours >= 0 ? Icons.add_circle : Icons.remove_circle,
                        summary.extraHours >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Barra de progreso
                Card(
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
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '${summary.completionPercentage.toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: summary.completionPercentage / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${summary.totalHours.toStringAsFixed(1)}h',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${summary.expectedHours.toStringAsFixed(0)}h',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Promedio diario
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Promedio diario',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${summary.averageHoursPerDay.toStringAsFixed(1)}h por día',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Calendario del mes',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text('🚧 Calendario visual próximamente 🚧'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

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
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}