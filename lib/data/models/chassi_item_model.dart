class ChassiItemModel {
  final String chassi;
  final String cliente;
  final String status;

  ChassiItemModel({
    required this.chassi,
    required this.cliente,
    required this.status,
  });

  factory ChassiItemModel.fromJson(Map<String, dynamic> json) {
    return ChassiItemModel(
      chassi: json['chassi'] ?? '',
      cliente: json['cliente'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'chassi': chassi, 'cliente': cliente, 'status': status};
  }
}
