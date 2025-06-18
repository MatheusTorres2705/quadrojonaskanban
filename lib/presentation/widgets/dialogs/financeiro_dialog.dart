import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pie_chart/pie_chart.dart';
import 'package:quadrojonaskanban/models/parcelasFinanceira.dart';

class FinanceiroDialogAPI extends StatefulWidget {
  final String chassi;
  const FinanceiroDialogAPI({super.key, required this.chassi});

  @override
  State<FinanceiroDialogAPI> createState() => _FinanceiroDialogAPIState();
}

class _FinanceiroDialogAPIState extends State<FinanceiroDialogAPI> {
  List<ResumoFinanceiroModel> parcelas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarParcelas();
  }

  Future<void> carregarParcelas() async {
    try {
      final url = Uri.parse(
        "http://localhost:3000/api/chassifinanceiro?nunota=${Uri.encodeQueryComponent(widget.chassi)}",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty ||
            response.body == '{}' ||
            response.body == 'null') {
          setState(() {
            parcelas = [];
            isLoading = false;
          });
          return;
        }

        final json = jsonDecode(response.body);
        final List<dynamic> itens = json['itens'] ?? [];

        setState(() {
          parcelas = itens
              .map((e) => ResumoFinanceiroModel.fromJson(e))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Erro HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao carregar parcelas: $e');
      setState(() {
        parcelas = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPago = parcelas
        .where((p) => p.statusString == 'Pago')
        .length
        .toDouble();
    final totalAberto = parcelas
        .where((p) => p.statusString == 'Aberto')
        .length
        .toDouble();
    final totalVencido = parcelas
        .where((p) => p.statusString == 'Vencido')
        .length
        .toDouble();

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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
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
                            "Parcela ${p.nufin}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          subtitle: Text(
                            "Venc: ${p.diasAtrasos} • R\$ ${p.vlrParcela}",
                            style: const TextStyle(color: Colors.white38),
                          ),
                          trailing: Text(
                            p.statusString,
                            style: TextStyle(
                              color: p.statusString == 'Pago'
                                  ? Colors.green
                                  : p.statusString == 'Aberto'
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
          Text('${valor.toInt()}x', style: TextStyle(color: cor)),
        ],
      ),
    );
  }
}
