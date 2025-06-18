import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AcompanhamentoDashboardDialog extends StatelessWidget {
  const AcompanhamentoDashboardDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1F242D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard de Acompanhamento - OP NX-4512',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildIndicatorCard('Avanço', '79%', '+75%', Colors.green),
                  _buildIndicatorCard(
                    'Retrabalho',
                    '1800',
                    '-19%',
                    Colors.redAccent,
                  ),
                  _buildIndicatorCard(
                    'Falta de Materiais',
                    '18',
                    '-3%',
                    Colors.red,
                  ),
                  _buildIndicatorCard('Qualidade', '79', '12%', Colors.green),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Runtime vs Downtime',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 200, child: _BarChartSection()),
              const SizedBox(height: 24),
              const Text(
                'Indicadores Visuais',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDonut(
                    'Disponibilidade',
                    0.7058,
                    Colors.orange,
                    '-15.38%',
                  ),
                  _buildDonut('Performance', 0.9046, Colors.green, '+3.46%'),
                  _buildDonut('Qualidade', 0.9185, Colors.green, '+1.82%'),
                  _buildDonut(
                    'Eficiência',
                    0.6015,
                    Colors.redAccent,
                    '-25.84%',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorCard(
    String title,
    String value,
    String change,
    Color color,
  ) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                change.startsWith('-')
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: color,
                size: 16,
              ),
              Text(change, style: TextStyle(color: color, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonut(String label, double percent, Color color, String delta) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 50.0,
          lineWidth: 10.0,
          animation: true,
          percent: percent,
          center: Text(
            '${(percent * 100).toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.white),
          ),
          progressColor: color,
          backgroundColor: Colors.white12,
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(delta, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

class _BarChartSection extends StatelessWidget {
  const _BarChartSection();

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        backgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const labels = [
                  'Laminação',
                  'Rebarba',
                  'Acabamento',
                  'Montagem',
                  'Expedição',
                ];
                return Text(
                  labels[value.toInt()],
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                );
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          makeGroupData(0, 3200, 2800),
          makeGroupData(1, 3300, 2600),
          makeGroupData(2, 3500, 1800),
          makeGroupData(3, 3800, 1240),
          makeGroupData(4, 3700, 160),
        ],
        gridData: FlGridData(show: false),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double runTime, double downTime) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: downTime, color: Colors.redAccent, width: 6),
        BarChartRodData(toY: runTime, color: Colors.orange, width: 6),
      ],
      barsSpace: 4,
    );
  }
}
