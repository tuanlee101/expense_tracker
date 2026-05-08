class UserModel {
  final String name;
  final String email;
  final String? avatarUrl;
  final String membership;
  final double totalAssets;
  final double monthlyFixedCost;
  final double safeBudget;

  UserModel({
    this.name = 'Nguyễn Minh Quân',
    this.email = 'quan.nguyen@email.com',
    this.avatarUrl,
    this.membership = 'Hội viên Pro',
    this.totalAssets = 1250000000,
    this.monthlyFixedCost = 15000000,
    this.safeBudget = 8500000,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? membership,
    double? totalAssets,
    double? monthlyFixedCost,
    double? safeBudget,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      membership: membership ?? this.membership,
      totalAssets: totalAssets ?? this.totalAssets,
      monthlyFixedCost: monthlyFixedCost ?? this.monthlyFixedCost,
      safeBudget: safeBudget ?? this.safeBudget,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'membership': membership,
        'totalAssets': totalAssets,
        'monthlyFixedCost': monthlyFixedCost,
        'safeBudget': safeBudget,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String? ?? 'Nguyễn Minh Quân',
      email: json['email'] as String? ?? 'quan.nguyen@email.com',
      avatarUrl: json['avatarUrl'] as String?,
      membership: json['membership'] as String? ?? 'Hội viên Pro',
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 1250000000,
      monthlyFixedCost:
          (json['monthlyFixedCost'] as num?)?.toDouble() ?? 15000000,
      safeBudget: (json['safeBudget'] as num?)?.toDouble() ?? 8500000,
    );
  }
}
