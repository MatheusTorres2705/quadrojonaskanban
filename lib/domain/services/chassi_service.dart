import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../data/models/chassi_item_model.dart';

class ChassiService {
  Future<List<ChassiItemModel>> fetchChassisFromApi(int nunota) async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/chassi?nunota=$nunota'),
    );
    print(response);
    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;
      final decoded = latin1.decode(bytes);
      final data = jsonDecode(decoded);

      return (data['itens'] as List).map((item) {
        return ChassiItemModel(
          chassi: item['CHASSI'].toString(),
          cliente: item['CLIENTE'].toString(),
          status: item['STATUS'].toString(),
          mes: item['MES'].toString(),
          ano: item['ANO'].toString(),
        );
      }).toList();
    } else {
      throw Exception('Erro ao buscar dados do pedido');
    }
  }
}
