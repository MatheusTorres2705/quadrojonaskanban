import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quadrojonaskanban/models/parcelasFinanceira.dart';
import '/../data/models/chassi_item_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ChassiController extends GetxController {
  final isLoading = false.obs;
  final dadosPorMes = <String, Map<String, List<ChassiItemModel>>>{}.obs;
  final filtroCliente = ''.obs;
  final filtroStatus = ''.obs;
  final ordenarPorChassi = false.obs;
  final anoSelecionado = ''.obs;
  final mesesSelecionados = <String>[].obs;
  final statusSelecionado = ''.obs;

  final List<String> statusDisponiveis = [
    'Em produção',
    'Finalizado',
    'Entregue',
    'Cancelado',
  ];

  Future<void> carregarStatusDisponiveis() async {
    //TODO Exemplo de carregamento dinâmico
    statusDisponiveis.clear();
    //  final response = await suaAPI(); // precisa implementar
    //statusDisponiveis.addAll(response);
  }

  ChassiItemModel? draggingChassi;
  String? draggingLinha;
  String? draggingMes;

  List<String> get anosDisponiveis =>
      dadosPorMes.keys.map((mes) => mes.split(' ').last).toSet().toList()
        ..sort();

  List<String> get mesesDisponiveisDoAno =>
      dadosPorMes.keys
          .where((mes) => mes.endsWith(anoSelecionado.value))
          .toList()
        ..sort((a, b) => _mesIndex(a).compareTo(_mesIndex(b)));

  int _mesIndex(String mesCompleto) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    final mes = mesCompleto.split(' ').first;
    return meses.indexOf(mes);
  }

  bool deveExibir(ChassiItemModel chassi) {
    final clienteFiltro = filtroCliente.value.toLowerCase();
    final statusFiltro = statusSelecionado.value;

    return (clienteFiltro.isEmpty ||
            chassi.cliente.toLowerCase().contains(clienteFiltro)) &&
        (statusFiltro.isEmpty || chassi.status == statusFiltro);
  }

  void exportarCSV() async {
    if (kIsWeb) {
      Get.snackbar(
        'Exportação indisponível',
        'Esta funcionalidade não está disponível no navegador.',
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('Chassi,Cliente,Status,Mês,Ano');

    dadosPorMes.forEach((mes, linhas) {
      linhas.forEach((linha, lista) {
        for (final chassi in lista) {
          buffer.writeln(
            '${chassi.chassi},${chassi.cliente},${chassi.status},$mes,${chassi.ano}',
          );
        }
      });
    });

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/exportacao.csv');
    await file.writeAsString(buffer.toString());
    Share.shareXFiles([XFile(file.path)], text: 'Exportação de Chassis');
  }

  void refreshDados() {
    dadosPorMes.refresh(); // isso força atualização na tela
  }

  List<ChassiItemModel> ordenar(List<ChassiItemModel> lista) {
    if (ordenarPorChassi.value) {
      lista.sort((a, b) => a.chassi.compareTo(b.chassi));
    } else {
      lista.sort((a, b) => a.sequencia.compareTo(b.sequencia));
    }
    return lista;
  }

  Future<void> carregarChassisAPI() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/chassi'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final rawMap = json['dadosPorMes'] as Map<String, dynamic>;

        final Map<String, Map<String, List<ChassiItemModel>>> parsedMap = {};

        for (var mes in rawMap.keys) {
          final linhas = rawMap[mes] as Map<String, dynamic>;
          parsedMap[mes] = {};

          // Ordena os grupos por nome (alfabético)
          final gruposOrdenados = linhas.keys.toList()..sort();

          for (var grupo in gruposOrdenados) {
            final listaChassis = (linhas[grupo] as List).map((item) {
              return ChassiItemModel.fromJson(item);
            }).toList();

            // Ordena os chassis por número do chassi
            listaChassis.sort((a, b) => a.chassi.compareTo(b.chassi));

            parsedMap[mes]![grupo] = listaChassis;
          }
        }

        dadosPorMes.value = parsedMap;

        if (parsedMap.isNotEmpty) {
          final primeiroMes = parsedMap.keys.first;
          final ano = primeiroMes.split(' ').last;
          anoSelecionado.value = ano;
          mesesSelecionados.value = parsedMap.keys
              .where((k) => k.endsWith(ano))
              .toList();
        }
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao carregar chassis: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF161B22),
        colorText: const Color(0xFFFF6B6B),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void iniciarDrag({
    required ChassiItemModel chassi,
    required String linha,
    required String mes,
  }) {
    draggingChassi = chassi;
    draggingLinha = linha;
    draggingMes = mes;
  }

  void moverChassiParaOutroMes({required String paraMes}) {
    if (draggingChassi == null || draggingLinha == null || draggingMes == null)
      return;
    if (draggingMes == paraMes) return;

    final chassi = draggingChassi!;
    final linha = draggingLinha!;
    final deMes = draggingMes!;

    final listaOrigem = dadosPorMes[deMes]?[linha];
    if (listaOrigem == null || !listaOrigem.contains(chassi)) return;

    dadosPorMes[paraMes] ??= {};
    dadosPorMes[paraMes]![linha] ??= [];
    dadosPorMes[paraMes]![linha]!.add(chassi);
    listaOrigem.remove(chassi);
    if (listaOrigem.isEmpty) {
      dadosPorMes[deMes]?.remove(linha);
    }

    dadosPorMes.refresh();

    draggingChassi = null;
    draggingLinha = null;
    draggingMes = null;

    Get.snackbar(
      'Movido com sucesso',
      '${chassi.chassi} transferido de $deMes para $paraMes',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2E7D32),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
    );
  }

  Future<void> finalizarPlanejamento() async {
    try {
      // Aqui você faz a chamada real para o backend
      // Exemplo:
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/finalizar-planejamento'),
        body: jsonEncode({
          'ano': anoSelecionado.value,
          'meses': mesesSelecionados,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Sucesso',
          'Planejamento finalizado com sucesso!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Erro: ${response.body}');
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao finalizar planejamento: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<List<ResumoFinanceiroModel>> buscarParcelasFinanceirasPorChassi(
    String chassi,
  ) async {
    final url = Uri.parse(
      "http://localhost:3000/api/chassifinanceiro?nunota=$chassi",
    );

    try {
      final response = await http.get(url);

      print("🔎 Chamando URL: $url");
      print("📦 Status: ${response.statusCode}");
      print("📦 Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty ||
            response.body == '{}' ||
            response.body == 'null') {
          return [];
        }

        final json = jsonDecode(response.body);

        // Proteção contra estrutura incompleta
        if (json['chassi'] == null || json['vlrparcela'] == null) {
          return [];
        }

        final model = ResumoFinanceiroModel.fromJson(json);
        return [model];
      }

      throw Exception('Erro HTTP: ${response.statusCode}');
    } catch (e) {
      print('❌ Erro ao buscar parcelas do chassi $chassi: $e');
      throw Exception('Erro ao carregar parcelas: $e');
    }
  }
}
