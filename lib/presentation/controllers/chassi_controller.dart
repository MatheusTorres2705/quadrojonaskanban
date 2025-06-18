import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/../data/models/chassi_item_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChassiController extends GetxController {
  final isLoading = false.obs;
  final dadosPorMes = <String, Map<String, List<ChassiItemModel>>>{}.obs;
  final filtroCliente = ''.obs;
  final filtroStatus = ''.obs;
  final ordenarPorChassi = false.obs;
  final anoSelecionado = ''.obs;
  final mesesSelecionados = <String>[].obs;

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

  bool deveExibir(ChassiItemModel item) {
    final clienteMatch =
        filtroCliente.value.isEmpty ||
        item.cliente.toLowerCase().contains(filtroCliente.value.toLowerCase());
    final statusMatch =
        filtroStatus.value.isEmpty ||
        item.status.toLowerCase() == filtroStatus.value.toLowerCase();
    return clienteMatch && statusMatch;
  }

  List<ChassiItemModel> ordenar(List<ChassiItemModel> lista) {
    if (ordenarPorChassi.value) {
      lista.sort((a, b) => a.chassi.compareTo(b.chassi));
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

          for (var grupo in linhas.keys) {
            final listaChassis = (linhas[grupo] as List).map((item) {
              return ChassiItemModel.fromJson(item);
            }).toList();

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
}
