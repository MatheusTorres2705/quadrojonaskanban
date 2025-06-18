class ChassiItemModel {
  String chassi;
  String cliente;
  String status;
  String ano;
  String mes;
  int sequencia;

  ChassiItemModel({
    required this.chassi,
    required this.cliente,
    required this.status,
    required this.ano,
    required this.mes,
    required this.sequencia,
  });

  factory ChassiItemModel.fromJson(Map<String, dynamic> json) {
    return ChassiItemModel(
      chassi: json['chassi'] ?? '',
      cliente: json['cliente'] ?? '',
      status: json['status'] ?? '',
      ano: json['ano'] ?? '',
      mes: json['mes'] ?? '',
      sequencia: json['sequencia'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chassi': chassi,
      'cliente': cliente,
      'status': status,
      'ano': ano,
      'mes': mes,
      'sequencia': sequencia,
    };
  }
}
