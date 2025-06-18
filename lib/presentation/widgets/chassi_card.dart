import 'package:flutter/material.dart';
import 'package:quadrojonaskanban/models/parcelasFinanceira.dart';
import 'package:quadrojonaskanban/presentation/widgets/dialogs/op_dialog.dart';
import '../../../data/models/chassi_item_model.dart';
import 'package:get/get.dart';
import '../controllers/chassi_controller.dart';
import 'dialogs/financeiro_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChassiController>();

    return Card(
      elevation: 3,
      color: const Color(0xFF21262D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.arrow_outward_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    chassi.sequencia.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_boat,
                      color: Colors.blueAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      chassi.chassi,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.attach_money,
                        color: Colors.greenAccent,
                        size: 20,
                      ),
                      onPressed: () async {
                        final parcelas = await controller
                            .buscarParcelasFinanceirasPorChassi(chassi.chassi);
                        showDialog(
                          context: context,
                          builder: (_) =>
                              FinanceiroDialogAPI(chassi: chassi.chassi),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.track_changes,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AcompanhamentoDashboardDialog(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    chassi.cliente,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }
}
