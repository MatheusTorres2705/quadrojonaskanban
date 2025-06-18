import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/chassi_item_model.dart';
import '../controllers/chassi_controller.dart';
import '../widgets/chassi_card.dart';

class MesesChassisBoard extends StatelessWidget {
  const MesesChassisBoard({super.key});

  void _mostrarDetalhesBarco(BuildContext context, ChassiItemModel chassi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F242D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Detalhes do Barco',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chassi: ${chassi.chassi}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Cliente: ${chassi.cliente}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${chassi.status}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Ano: ${chassi.cliente}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Mês: ${chassi.cliente}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
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
    final controller = Get.put(ChassiController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          'Chassis por Mês',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF161B22),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download, color: Colors.white),
            onPressed: () => controller.carregarChassisAPI(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text('Ano:', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: controller.anoSelecionado.value.isEmpty
                        ? null
                        : controller.anoSelecionado.value,
                    hint: const Text('Selecione o ano'),
                    dropdownColor: const Color(0xFF1F242D),
                    items: controller.anosDisponiveis.map((ano) {
                      return DropdownMenuItem(value: ano, child: Text(ano));
                    }).toList(),
                    onChanged: (value) {
                      controller.anoSelecionado.value = value ?? '';
                      controller.mesesSelecionados.clear();
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: controller.mesesDisponiveisDoAno.map((
                        mesCompleto,
                      ) {
                        final selecionado = controller.mesesSelecionados
                            .contains(mesCompleto);
                        return FilterChip(
                          selected: selecionado,
                          label: Text(mesCompleto.split(' ').first),
                          onSelected: (val) {
                            if (val) {
                              controller.mesesSelecionados.add(mesCompleto);
                            } else {
                              controller.mesesSelecionados.remove(mesCompleto);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.mesesSelecionados.isEmpty
                  ? const Center(
                      child: Text(
                        "Selecione um ou mais meses",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(8),
                      children: controller.mesesSelecionados.map((mes) {
                        final linhas = controller.dadosPorMes[mes]!;
                        return DragTarget<ChassiItemModel>(
                          onWillAccept: (_) => true,
                          onAccept: (_) =>
                              controller.moverChassiParaOutroMes(paraMes: mes),
                          builder: (context, _, __) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              color: const Color(0xFF161B22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                collapsedIconColor: Colors.white,
                                iconColor: Colors.white,
                                title: Text(
                                  mes,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: linhas.entries.map((
                                        linhaEntry,
                                      ) {
                                        final lista = controller.ordenar(
                                          linhaEntry.value
                                              .where(controller.deveExibir)
                                              .toList(),
                                        );
                                        return Container(
                                          width: 280,
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1F242D),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                child: Text(
                                                  linhaEntry.key,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 240,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: lista
                                                        .map(
                                                          (chassi) => Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 4,
                                                                ),
                                                            child: Draggable<ChassiItemModel>(
                                                              data: chassi,
                                                              onDragStarted: () =>
                                                                  controller.iniciarDrag(
                                                                    chassi:
                                                                        chassi,
                                                                    linha:
                                                                        linhaEntry
                                                                            .key,
                                                                    mes: mes,
                                                                  ),
                                                              feedback: Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: SizedBox(
                                                                  width: 250,
                                                                  child: ChassiCard(
                                                                    chassi:
                                                                        chassi,
                                                                  ),
                                                                ),
                                                              ),
                                                              childWhenDragging:
                                                                  Opacity(
                                                                    opacity:
                                                                        0.3,
                                                                    child: ChassiCard(
                                                                      chassi:
                                                                          chassi,
                                                                    ),
                                                                  ),
                                                              child: GestureDetector(
                                                                onTap: () =>
                                                                    _mostrarDetalhesBarco(
                                                                      context,
                                                                      chassi,
                                                                    ),
                                                                child:
                                                                    ChassiCard(
                                                                      chassi:
                                                                          chassi,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
