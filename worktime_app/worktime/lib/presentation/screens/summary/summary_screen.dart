import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock/mock_data.dart';
import '../../../models/summary_model.dart';

/// Pantalla de Resumen
/// Muestra el resumen mensual de horas trabajadas con gráficas
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int _selectedIndex = 2;
  late SummaryModel _summary;

  @override
  void initState() {
    super.initState();
    _summary = MockData.getMockMonthlySummary();
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
        context.go('/activity');
        break;
      case 2:
        // Ya estamos en Summary
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Resumen'),
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
            // Selector de mes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      // TODO: Cambiar mes anterior
                    },
                  ),
                  Text(
                    '${_summary.monthName} ${_summary.year}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      // TODO: Cambiar mes siguiente
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cards de resumen
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    label: 'Horas trabajadas',
                    value: '${_summary.totalHours.toStringAsFixed(1)}h',
                    icon: Icons.schedule,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    label: 'Horas esperadas',
                    value: '${_summary.expectedHours.toStringAsFixed(1)}h',
                    icon: Icons.calendar_today,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    label: 'Horas extra',
                    value: '${_summary.extraHours.toStringAsFixed(1)}h',
                    icon: Icons.trending_up,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    label: 'Horas pendientes',
                    value: '${_summary.pendingHours.toStringAsFixed(1)}h',
                    icon: Icons.trending_down,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Progreso
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progreso del mes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _summary.expectedHours > 0 ? _summary.completionPercentage / 100 : 0.0,
                      minHeight: 12,
                      backgroundColor: AppColors.backgroundSecondary,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _summary.completionPercentage >= 100 && _summary.expectedHours > 0
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_summary.completionPercentage.toStringAsFixed(1)}% completado',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Gráfica semanal
            Text(
              'Horas por semana',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            Container(
              height: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: _summary.totalHours > 0 ? _buildWeeklyChart() : _buildEmptyChart(),
            ),

            const SizedBox(height: 24),

            // Calendario mensual simplificado
            Text(
              'Calendario del mes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            _buildMonthCalendar(),

            const SizedBox(height: 24),

            // Resumen económico (placeholder)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen económico',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildEconomicRow('Salario base', '0,00 €'),
                  const SizedBox(height: 8),
                  _buildEconomicRow('Horas extra', '+ 0,00 €'),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildEconomicRow(
                    'Total estimado',
                    '0,00 €',
                    isBold: true,
                  ),
                ],
              ),
            ),
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

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return const Center(
      child: Text(
        'No hay datos para mostrar en la gráfica',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 50,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const weeks = ['S1', 'S2', 'S3', 'S4'];
                if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                  return Text(
                    weeks[value.toInt()],
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
              toY: 0,
              color: AppColors.primary,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
              toY: 0,
              color: AppColors.primary,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(
              toY: 0,
              color: AppColors.primary,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]),
          BarChartGroupData(x: 3, barRods: [
            BarChartRodData(
              toY: 0,
              color: AppColors.warning,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                .map((day) => SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          
          if (_summary.dailySummaries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No hay registros para este mes',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(
                _summary.dailySummaries.length,
                (index) {
                  final day = _summary.dailySummaries[index];
                  Color color;
                  
                  switch (day.status) {
                    case DayStatus.complete:
                      color = AppColors.success;
                      break;
                    case DayStatus.incomplete:
                      color = AppColors.warning;
                      break;
                    case DayStatus.absence:
                      color = AppColors.textTertiary;
                      break;
                    case DayStatus.pending:
                      color = AppColors.backgroundSecondary;
                      break;
                  }

                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: color.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          // Leyenda
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('Completo', AppColors.success),
              _buildLegendItem('Incompleto', AppColors.warning),
              _buildLegendItem('Ausencia', AppColors.textTertiary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEconomicRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
