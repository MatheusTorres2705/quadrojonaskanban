import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MesesChassisBoard(),
    ),
  );
}

class ChassiItem {
  final String chassi;
  final String cliente;
  final String status;

  ChassiItem({
    required this.chassi,
    required this.cliente,
    required this.status,
  });
}

class MesesChassisBoard extends StatefulWidget {
  const MesesChassisBoard({super.key});

  @override
  State<MesesChassisBoard> createState() => _MesesChassisBoardState();
}

class _MesesChassisBoardState extends State<MesesChassisBoard> {
  Map<String, Map<String, List<ChassiItem>>> dadosPorMes = {
    'Agosto 2025': {
      'NX 280': [
        ChassiItem(
          chassi: 'CHASSI NX 280/001',
          cliente: 'Cliente A',
          status: 'Planejamento ok',
        ),
        ChassiItem(
          chassi: 'CHASSI NX 280/002',
          cliente: 'Cliente B',
          status: 'Em produção',
        ),
      ],
      'NX 290': [
        ChassiItem(
          chassi: 'CHASSI NX 290/001',
          cliente: 'Cliente C',
          status: 'Planejamento pendente',
        ),
        ChassiItem(
          chassi: 'CHASSI NX 290/002',
          cliente: 'Cliente D',
          status: 'Inadimplencia',
        ),
      ],
      'NX 340': [],
      'NX 350': [],
      'NX 410': [],
      'NX 500': [],
    },
    'Setembro 2025': {
      'NX 280': [
        ChassiItem(
          chassi: 'CHASSI NX 280/003',
          cliente: 'Cliente E',
          status: 'Em produção',
        ),
        ChassiItem(
          chassi: 'CHASSI NX 280/004',
          cliente: 'Cliente F',
          status: 'Planejamento ok',
        ),
      ],
      'NX 290': [
        ChassiItem(
          chassi: 'CHASSI NX 290/003',
          cliente: 'Cliente G',
          status: 'Planejamento pendente',
        ),
        ChassiItem(
          chassi: 'CHASSI NX 290/004',
          cliente: 'Cliente H',
          status: 'Inadimplencia',
        ),
      ],
      'NX 340': [],
      'NX 350': [],
      'NX 410': [],
      'NX 500': [],
    },
  };

  ChassiItem? draggingChassi;
  String? draggingLinha;
  String? draggingMes;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Em produção':
        return Colors.orange;
      case 'Planejamento ok':
        return Colors.green;
      case 'Planejamento pendente':
        return Colors.yellow;
      case 'Inadimplencia':
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }

  void _adicionarBarco() {
    // Lógica de adicionar barco (mock)
    setState(() {
      dadosPorMes['Agosto 2025']!['NX 280']!.add(
        ChassiItem(
          chassi: 'NOVO CHASSI',
          cliente: 'Novo Cliente',
          status: 'Planejamento ok',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.api, color: Colors.white),
            tooltip: 'Adicionar novo barco',
            onPressed: () async {
              // final uri = Uri.parse(
              //   'http://localhost:3000/api/itens-pedido?nunota=2898417',
              // );
              // final response = await http.get(uri);
              // if (response.statusCode == 200) {
              //   final bytes = response.bodyBytes;
              //   final utf8Body = utf8.decode(bytes, allowMalformed: true);
              //   debugPrint('Resposta UTF-8 corrigida: $utf8Body');

              final response = await http.get(
                Uri.parse(
                  'http://localhost:3000/api/itens-pedido?nunota=2898417',
                ),
              );

              // Força decodificação ISO-8859-1 (latin1) caso a resposta tenha caracteres errados
              final decodedString = latin1.decode(response.bodyBytes);

              final data = jsonDecode(decodedString);

              print('Produtos recebidos:');
              for (var item in data['itens']) {
                print(
                  '${item['nomeProduto']} - Qtd: ${item['qtd']} - Valor: ${item['vlrUnit']}',
                );
              }

              //       debugPrint('Erro na resposta: \${response.statusCode}');
              //     }
              //   } catch (e) {
              //     debugPrint('Erro ao chamar API: \$e');
              //   }
              // } catch (e) {
              //     debugPrint('Erro ao chamar API: \$e');
              //   }
              // } catch (e) {
              //     debugPrint('Erro ao chamar API: \$e');
              // }
              // }
            },
          ),
        ],
      ),
      body: ListView(
        children: dadosPorMes.entries.map((mesEntry) {
          final String mes = mesEntry.key;
          final Map<String, List<ChassiItem>> linhas = mesEntry.value;
          return DragTarget<ChassiItem>(
            onWillAccept: (data) => mes != draggingMes,
            onAccept: (_) {
              if (draggingChassi != null &&
                  draggingLinha != null &&
                  draggingMes != null) {
                setState(() {
                  dadosPorMes[draggingMes]![draggingLinha]!.remove(
                    draggingChassi,
                  );
                  dadosPorMes[mes]![draggingLinha]!.add(draggingChassi!);
                  draggingChassi = null;
                  draggingLinha = null;
                  draggingMes = null;
                });
              }
            },
            builder: (context, candidateData, rejectedData) => Card(
              color: const Color(0xFF161B22),
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                collapsedIconColor: Colors.white,
                iconColor: Colors.white,
                title: Text(
                  mes,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                children: [
                  SizedBox(
                    height: 300,
                    child: DragAndDropLists(
                      axis: Axis.horizontal,
                      listWidth: 200,
                      listDraggingWidth: 180,
                      listPadding: const EdgeInsets.all(8),
                      listDecoration: BoxDecoration(
                        color: const Color(0xFF1F242D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      itemDecorationWhileDragging: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      children: linhas.entries.map((linhaEntry) {
                        return DragAndDropList(
                          header: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              linhaEntry.key,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          children: linhaEntry.value.map((chassiItem) {
                            return DragAndDropItem(
                              child: LongPressDraggable<ChassiItem>(
                                data: chassiItem,
                                onDragStarted: () {
                                  draggingChassi = chassiItem;
                                  draggingLinha = linhaEntry.key;
                                  draggingMes = mes;
                                },
                                onDraggableCanceled: (_, __) {
                                  draggingChassi = null;
                                  draggingLinha = null;
                                  draggingMes = null;
                                },
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Card(
                                    color: Colors.blueGrey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            chassiItem.chassi,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            chassiItem.cliente,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Text(
                                            chassiItem.status,
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                chassiItem.status,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                child: Card(
                                  color: Colors.grey[900],
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chassiItem.chassi,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          chassiItem.cliente,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          chassiItem.status,
                                          style: TextStyle(
                                            color: _getStatusColor(
                                              chassiItem.status,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                      onItemReorder:
                          (
                            oldItemIndex,
                            oldListIndex,
                            newItemIndex,
                            newListIndex,
                          ) {
                            setState(() {
                              String linhaOrigem = linhas.keys.elementAt(
                                oldListIndex,
                              );
                              String linhaDestino = linhas.keys.elementAt(
                                newListIndex,
                              );

                              var itemMovido = linhas[linhaOrigem]!.removeAt(
                                oldItemIndex,
                              );
                              linhas[linhaDestino]!.insert(
                                newItemIndex,
                                itemMovido,
                              );
                            });
                          },
                      onListReorder: (oldListIndex, newListIndex) {},
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
