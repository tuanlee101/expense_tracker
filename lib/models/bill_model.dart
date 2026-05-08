enum BillCategory {
  electricity('Tiền điện'),
  water('Tiền nước'),
  rent('Tiền nhà'),
  internet('Internet'),
  subscription('Netflix/Spotify'),
  installment('Trả góp/Thẻ tín dụng'),
  other('Khác');

  final String label;
  const BillCategory(this.label);
}

class BillModel {
  final String id;
  final String name;
  final double amount;
  final int dueDay;
  final BillCategory category;
  final bool isPaid;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDay,
    required this.category,
    this.isPaid = false,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  BillModel copyWith({
    String? id,
    String? name,
    double? amount,
    int? dueDay,
    BillCategory? category,
    bool? isPaid,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      category: category ?? this.category,
      isPaid: isPaid ?? this.isPaid,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'dueDay': dueDay,
        'category': category.name,
        'isPaid': isPaid,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDay: json['dueDay'] as int,
      category: BillCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => BillCategory.other,
      ),
      isPaid: json['isPaid'] as bool? ?? false,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}