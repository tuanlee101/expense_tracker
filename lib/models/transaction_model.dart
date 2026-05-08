enum TransactionType { income, expense }

enum TransactionCategory {
  food('Ăn uống', 'restaurant'),
  shopping('Mua sắm', 'shopping_cart'),
  transport('Di chuyển', 'directions_car'),
  housing('Nhà cửa', 'home'),
  bills('Hóa đơn', 'receipt'),
  health('Sức khỏe', 'favorite'),
  education('Giáo dục', 'school'),
  salary('Lương', 'payments'),
  entertainment('Giải trí', 'movie'),
  other('Khác', 'more_horiz');

  final String label;
  final String icon;
  const TransactionCategory(this.label, this.icon);
}

class TransactionModel {
  final String id;
  final String title;
  final String? note;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String wallet;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.title,
    this.note,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.wallet = 'Ví Tiền mặt',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TransactionModel copyWith({
    String? id,
    String? title,
    String? note,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? wallet,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      wallet: wallet ?? this.wallet,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'amount': amount,
        'type': type.name,
        'category': category.name,
        'date': date.toIso8601String(),
        'wallet': wallet,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      note: json['note'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      category: TransactionCategory.values.firstWhere(
          (e) => e.name == json['category']),
      date: DateTime.parse(json['date'] as String),
      wallet: json['wallet'] as String? ?? 'Ví Tiền mặt',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
