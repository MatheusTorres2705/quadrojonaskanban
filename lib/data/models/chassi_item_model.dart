class ChassiItemModel {
  String chassi;
  String cliente;
  String status;
  String ano;
  String mes;

  ChassiItemModel({
    required this.chassi,
    required this.cliente,
    required this.status,
    required this.ano,
    required this.mes,
  });

  factory ChassiItemModel.fromJson(Map<String, dynamic> json) {
    return ChassiItemModel(
      chassi: json['chassi'] ?? '',
      cliente: json['cliente'] ?? '',
      status: json['status'] ?? '',
      ano: json['ano'] ?? '',
      mes: json['mes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chassi': chassi,
      'cliente': cliente,
      'status': status,
      'ano': ano,
      'mes': mes,
    };
  }
}
