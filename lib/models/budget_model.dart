import '../models/transaction_model.dart';

/// Monthly spending limit for a specific transaction category.
/// Supports weekly / bi-weekly / monthly reset cycles.
enum BudgetCycle { weekly, biWeekly, monthly }

class BudgetModel {
  final String id;
  final TransactionCategory category;
  final double limit; // max allowed spending in the cycle
  final BudgetCycle cycle;
  final bool isEnabled;
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    this.cycle = BudgetCycle.monthly,
    this.isEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  BudgetModel copyWith({
    String? id,
    TransactionCategory? category,
    double? limit,
    BudgetCycle? cycle,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      cycle: cycle ?? this.cycle,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'limit': limit,
        'cycle': cycle.name,
        'isEnabled': isEnabled,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      category: TransactionCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TransactionCategory.food,
      ),
      limit: (json['limit'] as num).toDouble(),
      cycle: BudgetCycle.values.firstWhere(
        (c) => c.name == json['cycle'],
        orElse: () => BudgetCycle.monthly,
      ),
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}