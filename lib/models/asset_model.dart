enum AssetType {
  bankAccount('Tài khoản ngân hàng', 'account_balance'),
  cash('Ví tiền mặt', 'wallet'),
  creditCard('Thẻ tín dụng', 'credit_card'),
  savings('Sổ tiết kiệm', 'savings'),
  other('Tài sản khác', 'category');

  final String label;
  final String icon;
  const AssetType(this.label, this.icon);
}

class AssetModel {
  final String id;
  final String name;
  final double balance;
  final AssetType type;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssetModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  AssetModel copyWith({
    String? id,
    String? name,
    double? balance,
    AssetType? type,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'balance': balance,
        'type': type.name,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      type: AssetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AssetType.other,
      ),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}