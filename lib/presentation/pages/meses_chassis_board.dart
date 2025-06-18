import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/chassi_item_model.dart';
import '../controllers/chassi_controller.dart';
import '../widgets/chassi_card.dart';

class MesesChassisBoard extends StatelessWidget {
  const MesesChassisBoard({super.key});

  void _mostrarDetalhesBarco(BuildContext context, ChassiItemModel chassi) {
    final clienteController = TextEditingController(text: chassi.cliente);
    final statusController = TextEditingController(text: chassi.status);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F242D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Editar Barco',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: clienteController,
              decoration: const InputDecoration(labelText: 'Cliente'),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: statusController,
              decoration: const InputDecoration(labelText: 'Status'),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              chassi.cliente = clienteController.text;
              chassi.status = statusController.text;
              Get.back();
              Get.find<ChassiController>().refreshDados();
            },
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChassiController>();

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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'csv') {
                controller.exportarCSV();
              } else if (value == 'pdf') {
                controller
                    .exportarCSV(); // Trocar por exportarPDF() se implementar
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'csv', child: Text('Exportar CSV')),
              PopupMenuItem(value: 'pdf', child: Text('Exportar PDF')),
            ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      const Text('Ano:', style: TextStyle(color: Colors.white)),

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
                    ],
                  ),

                  Wrap(
                    spacing: 8,
                    children: controller.mesesDisponiveisDoAno.map((
                      mesCompleto,
                    ) {
                      final selecionado = controller.mesesSelecionados.contains(
                        mesCompleto,
                      );
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

                  Row(
                    children: [
                      DropdownButton<String>(
                        value: controller.statusSelecionado.value.isEmpty
                            ? null
                            : controller.statusSelecionado.value,
                        hint: const Text('Status'),
                        dropdownColor: const Color(0xFF1F242D),
                        items: controller.statusDisponiveis.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          controller.statusSelecionado.value = value ?? '';
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            controller.filtroCliente.value = value
                                .toLowerCase();
                          },
                          decoration: const InputDecoration(
                            hintText: 'Filtrar por cliente',
                            hintStyle: TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Color(0xFF1F242D),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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
                        final linhas = controller.dadosPorMes[mes] ?? {};
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
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      mes,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      icon: const Icon(Icons.flag, size: 16),
                                      label: const Text('Finalizar'),
                                      onPressed: () async {
                                        final confirmar =
                                            await Get.defaultDialog<bool>(
                                              title: 'Confirmar',
                                              middleText:
                                                  'Finalizar o planejamento do mês "$mes"?',
                                              confirm: ElevatedButton(
                                                onPressed: () =>
                                                    Get.back(result: true),
                                                child: const Text('Sim'),
                                              ),
                                              cancel: ElevatedButton(
                                                onPressed: () =>
                                                    Get.back(result: false),
                                                child: const Text('Cancelar'),
                                              ),
                                            );

                                        if (confirmar == true) {
                                          // controller.finalizarPlanejamentoDoMes(mes);
                                          print('teste de planejamento');
                                        }
                                      },
                                    ),
                                  ],
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
                                          width: 400,
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
                                                  bottom: 10,
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
                                                height: 340,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: lista.map((
                                                      chassi,
                                                    ) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 4,
                                                            ),
                                                        child: Draggable<ChassiItemModel>(
                                                          data: chassi,
                                                          onDragStarted: () =>
                                                              controller
                                                                  .iniciarDrag(
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
                                                                chassi: chassi,
                                                              ),
                                                            ),
                                                          ),
                                                          childWhenDragging:
                                                              Opacity(
                                                                opacity: 0.3,
                                                                child:
                                                                    ChassiCard(
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
                                                            child: ChassiCard(
                                                              chassi: chassi,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
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
