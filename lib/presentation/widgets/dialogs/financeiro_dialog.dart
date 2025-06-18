import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class ParcelaFinanceira {
  final String numero;
  final String vencimento;
  final double valor;
  final String status;

  ParcelaFinanceira({
    required this.numero,
    required this.vencimento,
    required this.valor,
    required this.status,
  });
}

class FinanceiroDialog extends StatelessWidget {
  final List<ParcelaFinanceira> parcelas;

  const FinanceiroDialog({super.key, required this.parcelas});

  @override
  Widget build(BuildContext context) {
    final totalPago = parcelas
        .where((p) => p.status == 'Pago')
        .fold(0.0, (a, b) => a + b.valor);
    final totalAberto = parcelas
        .where((p) => p.status == 'Aberto')
        .fold(0.0, (a, b) => a + b.valor);
    final totalVencido = parcelas
        .where((p) => p.status == 'Vencido')
        .fold(0.0, (a, b) => a + b.valor);

    final dataMap = {
      "Pago": totalPago,
      "Em Aberto": totalAberto,
      "Vencido": totalVencido,
    };

    return Dialog(
      backgroundColor: const Color(0xFF1F242D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumo Financeiro',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard("Pago", totalPago, Colors.green),
                  _infoCard("Aberto", totalAberto, Colors.orange),
                  _infoCard("Vencido", totalVencido, Colors.redAccent),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Parcelas',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: parcelas.map((p) {
                    return ListTile(
                      dense: true,
                      title: Text(
                        "Parcela ${p.numero}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      subtitle: Text(
                        "Venc: ${p.vencimento} • R\$ ${p.valor.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white38),
                      ),
                      trailing: Text(
                        p.status,
                        style: TextStyle(
                          color: p.status == 'Pago'
                              ? Colors.green
                              : p.status == 'Aberto'
                              ? Colors.orange
                              : Colors.redAccent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Distribuição por Status',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 12),
              PieChart(
                dataMap: dataMap,
                animationDuration: const Duration(milliseconds: 800),
                chartRadius: 180,
                chartType: ChartType.disc,
                chartValuesOptions: const ChartValuesOptions(
                  showChartValuesInPercentage: true,
                  showChartValueBackground: false,
                  chartValueStyle: TextStyle(color: Colors.white),
                ),
                colorList: const [
                  Colors.green,
                  Colors.orange,
                  Colors.redAccent,
                ],
              ),
              const SizedBox(height: 16),
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

  Widget _infoCard(String label, double valor, Color cor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: cor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('R\$ ${valor.toStringAsFixed(2)}', style: TextStyle(color: cor)),
        ],
      ),
    );
  }
}
