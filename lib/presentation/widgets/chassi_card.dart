import 'package:flutter/material.dart';
import 'package:quadrojonaskanban/presentation/widgets/dialogs/financeiro_dialog.dart';
import 'package:quadrojonaskanban/presentation/widgets/dialogs/op_dialog.dart';
import '../../../data/models/chassi_item_model.dart';

class ChassiCard extends StatelessWidget {
  final ChassiItemModel chassi;

  const ChassiCard({super.key, required this.chassi});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'liberada':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'inadimplencia':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'liberada':
        return Icons.check_circle;
      case 'pendente':
        return Icons.hourglass_bottom;
      case 'inadimplencia':
        return Icons.warning;
      default:
        return Icons.info_outline;
    }
  }

  void _abrirDialogo(BuildContext context, String titulo, String conteudo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F242D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        content: Text(conteudo, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: const Color(0xFF21262D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CHASSI
            Row(
              children: [
                const Icon(
                  Icons.directions_boat,
                  color: Colors.blueAccent,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    chassi.chassi,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // CLIENTE
            Row(
              children: [
                const Icon(Icons.person, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    chassi.cliente,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // STATUS
            Row(
              children: [
                Icon(
                  getStatusIcon(chassi.status),
                  size: 16,
                  color: getStatusColor(chassi.status),
                ),
                const SizedBox(width: 6),
                Text(
                  chassi.status,
                  style: TextStyle(
                    color: getStatusColor(chassi.status),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // BOTÕES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => FinanceiroDialog(
                        parcelas: [
                          ParcelaFinanceira(
                            numero: '001',
                            vencimento: '10/06/2025',
                            valor: 1500.00,
                            status: 'Pago',
                          ),
                          ParcelaFinanceira(
                            numero: '002',
                            vencimento: '10/07/2025',
                            valor: 1500.00,
                            status: 'Aberto',
                          ),
                          ParcelaFinanceira(
                            numero: '003',
                            vencimento: '10/05/2025',
                            valor: 1500.00,
                            status: 'Vencido',
                          ),
                          ParcelaFinanceira(
                            numero: '004',
                            vencimento: '10/08/2025',
                            valor: 2000.00,
                            status: 'Aberto',
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.attach_money, color: Colors.white),
                  label: const Text(
                    'Financeiro',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueGrey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AcompanhamentoDashboardDialog(),
                    );
                  },
                  icon: const Icon(Icons.factory, color: Colors.white),
                  label: const Text(
                    'OP',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
