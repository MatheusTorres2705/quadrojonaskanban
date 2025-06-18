class ResumoFinanceiroModel {
  final String chassi;
  final String titulo;
  final String vlrPago;
  final String vlrAVencer;
  final String vlrAVencido;
  final String diasAtrasos;
  final String nufin;
  final String nunota;
  final String vlrParcela;
  final String status;

  ResumoFinanceiroModel({
    required this.chassi,
    required this.titulo,
    required this.vlrPago,
    required this.vlrAVencer,
    required this.vlrAVencido,
    required this.diasAtrasos,
    required this.nufin,
    required this.nunota,
    required this.vlrParcela,
    required this.status,
  });

  factory ResumoFinanceiroModel.fromJson(Map<String, dynamic> json) {
    return ResumoFinanceiroModel(
      chassi: json['chassi']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      vlrPago: json['vlrpago']?.toString() ?? '0',
      vlrAVencer: json['vlravencer']?.toString() ?? '0',
      vlrAVencido: json['vlravencido']?.toString() ?? '0',
      diasAtrasos: json['diasatrasos']?.toString() ?? '0',
      nufin: json['nufin']?.toString() ?? '',
      nunota: json['nunota']?.toString() ?? '',
      vlrParcela: json['vlrparcela']?.toString() ?? '0',
      status: json['status']?.toString() ?? '',
    );
  }

  /// Exemplo de cálculo em tempo de uso
  double get valorParcelaDouble => double.tryParse(vlrParcela) ?? 0.0;

  String get statusString {
    final vencido = double.tryParse(vlrAVencido) ?? 0;
    final aberto = double.tryParse(vlrAVencer) ?? 0;
    final pago = double.tryParse(vlrPago) ?? 0;

    if (vencido > 0) return "Vencido";
    if (aberto > 0) return "Aberto";
    if (pago > 0) return "Pago";
    return "Indefinido";
  }
}
