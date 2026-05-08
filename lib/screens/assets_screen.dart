import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/asset_model.dart';
import '../providers/asset_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalAssetsCard(provider),
              const SizedBox(height: AppSpacing.md),
              _buildAssetDistributionChart(provider),
              const SizedBox(height: AppSpacing.md),
              _buildAssetsList(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalAssetsCard(AssetProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Tổng tài sản',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: AppTypography.bodyFont,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            Helpers.formatCurrency(provider.totalAssets),
            style: AppTypography.displayLg.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${provider.assets.length} tài khoản/tài sản',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetDistributionChart(AssetProvider provider) {
    final assetsByType = provider.assetsByType;
    final total = provider.totalAssets;
    
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân bổ tài sản',
            style: AppTypography.titleLg.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: PieChartPainter(
                    data: assetsByType.entries.map((e) => e.value).toList(),
                    colors: _getAssetColors(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: assetsByType.entries.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final type = entry.value.key;
                    final value = entry.value.value;
                    final percentage = (value / total * 100).toStringAsFixed(1);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getAssetColors()[index % _getAssetColors().length],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              type.label,
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: AppTypography.labelSm.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _getAssetColors() {
    return [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFF795548),
    ];
  }

  Widget _buildAssetsList(BuildContext context, AssetProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sách tài sản',
              style: AppTypography.titleLg.copyWith(color: AppColors.onSurface),
            ),
            TextButton.icon(
              onPressed: () => _showAddAssetDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm mới'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...provider.assets.map((asset) => _buildAssetItem(context, provider, asset)),
      ],
    );
  }

  Widget _buildAssetItem(BuildContext context, AssetProvider provider, AssetModel asset) {
    return Dismissible(
      key: Key(asset.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.delete, color: AppColors.onErrorContainer),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xóa tài sản'),
            content: Text('Bạn có chắc muốn xóa "${asset.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => provider.deleteAsset(asset.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getAssetTypeColor(asset.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _getAssetIcon(asset.type),
              color: _getAssetTypeColor(asset.type),
            ),
          ),
          title: Text(
            asset.name,
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            asset.type.label,
            style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Helpers.formatCurrency(asset.balance),
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: asset.balance >= 0 ? AppColors.secondary : AppColors.error,
                ),
              ),
              if (asset.note != null && asset.note!.isNotEmpty)
                Text(
                  asset.note!,
                  style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          onTap: () => _showEditAssetDialog(context, asset),
        ),
      ),
    );
  }

  IconData _getAssetIcon(AssetType type) {
    switch (type) {
      case AssetType.bankAccount:
        return Icons.account_balance;
      case AssetType.cash:
        return Icons.wallet;
      case AssetType.creditCard:
        return Icons.credit_card;
      case AssetType.savings:
        return Icons.savings;
      case AssetType.other:
        return Icons.category;
    }
  }

  Color _getAssetTypeColor(AssetType type) {
    switch (type) {
      case AssetType.bankAccount:
        return const Color(0xFF2196F3);
      case AssetType.cash:
        return const Color(0xFF4CAF50);
      case AssetType.creditCard:
        return const Color(0xFFFF9800);
      case AssetType.savings:
        return const Color(0xFF9C27B0);
      case AssetType.other:
        return const Color(0xFF795548);
    }
  }

  void _showAddAssetDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final noteController = TextEditingController();
    AssetType selectedType = AssetType.bankAccount;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm tài sản mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên tài khoản/tài sản',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Số dư',
                    border: OutlineInputBorder(),
                    prefixText: '₫ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<AssetType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Loại tài sản',
                    border: OutlineInputBorder(),
                  ),
                  items: AssetType.values.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type.label));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || balanceController.text.isEmpty) {
                  return;
                }
                final balance = double.tryParse(balanceController.text.replaceAll(',', '')) ?? 0;
                final asset = AssetModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  balance: balance,
                  type: selectedType,
                  note: noteController.text.isEmpty ? null : noteController.text,
                );
                context.read<AssetProvider>().addAsset(asset);
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAssetDialog(BuildContext context, AssetModel asset) {
    final nameController = TextEditingController(text: asset.name);
    final balanceController = TextEditingController(text: asset.balance.toString());
    final noteController = TextEditingController(text: asset.note ?? '');
    AssetType selectedType = asset.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Chỉnh sửa tài sản'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên tài khoản/tài sản',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Số dư',
                    border: OutlineInputBorder(),
                    prefixText: '₫ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<AssetType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Loại tài sản',
                    border: OutlineInputBorder(),
                  ),
                  items: AssetType.values.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type.label));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || balanceController.text.isEmpty) {
                  return;
                }
                final balance = double.tryParse(balanceController.text.replaceAll(',', '')) ?? 0;
                final updatedAsset = asset.copyWith(
                  name: nameController.text,
                  balance: balance,
                  type: selectedType,
                  note: noteController.text.isEmpty ? null : noteController.text,
                  updatedAt: DateTime.now(),
                );
                context.read<AssetProvider>().updateAsset(updatedAsset);
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;

  PieChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final total = data.reduce((a, b) => a + b);
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    double startAngle = -3.14159 / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i] / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}