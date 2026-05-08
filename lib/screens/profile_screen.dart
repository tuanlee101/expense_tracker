import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'pin_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, TransactionProvider>(
      builder: (context, appProvider, txProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile,
            0,
            AppSpacing.marginMobile,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              _buildProfileHero(appProvider),
              const SizedBox(height: AppSpacing.md),
              _buildThemeCard(appProvider),
              const SizedBox(height: AppSpacing.lg),
              _buildAssetSection(appProvider, txProvider),
              const SizedBox(height: AppSpacing.lg),
              _buildSettingsSection(context, appProvider),
              const SizedBox(height: AppSpacing.lg),
              _buildLogoutButton(context, appProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHero(AppProvider appProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.3),
                child: Text(
                  appProvider.user.name.isNotEmpty
                      ? appProvider.user.name.substring(0, 1).toUpperCase()
                      : 'N',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 14, color: AppColors.onPrimaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appProvider.user.name,
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 22,
                  ),
                ),
                Text(
                  appProvider.user.email,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        appProvider.user.membership,
                        style: AppTypography.labelSm.copyWith(color: AppColors.onSecondaryContainer),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Cập nhật 2 ngày trước',
                        style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(AppProvider appProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Giao diện', style: AppTypography.titleLg.copyWith(color: AppColors.onSurface)),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    size: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    appProvider.isDarkMode ? 'Tối (Đang dùng)' : 'Sáng (Đang dùng)',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: appProvider.isDarkMode,
            onChanged: (_) => appProvider.toggleDarkMode(),
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetSection(AppProvider appProvider, TransactionProvider txProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.md),
          child: Text(
            'Quản lý Tài sản & Ngân sách',
            style: AppTypography.titleLg.copyWith(color: AppColors.onSurface),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;

            if (isNarrow) {
              return Column(
                children: [
                  _buildAssetCard(
                    label: 'Tổng tài sản hiện tại',
                    value: Helpers.formatCurrency(appProvider.user.totalAssets),
                    trend: '+5.2%',
                    trendUp: true,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildAssetCard(
                    label: 'Chi phí cố định hàng tháng',
                    value: Helpers.formatCurrency(appProvider.user.monthlyFixedCost),
                    safeBudget: Helpers.formatCurrency(appProvider.user.safeBudget),
                    color: AppColors.onSurface,
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildAssetCard(
                    label: 'Tổng tài sản hiện tại',
                    value: Helpers.formatCurrency(appProvider.user.totalAssets),
                    trend: '+5.2%',
                    trendUp: true,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildAssetCard(
                    label: 'Chi phí cố định hàng tháng',
                    value: Helpers.formatCurrency(appProvider.user.monthlyFixedCost),
                    safeBudget: Helpers.formatCurrency(appProvider.user.safeBudget),
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssetCard({
    required String label,
    required String value,
    String? trend,
    bool trendUp = true,
    String? safeBudget,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color == AppColors.primary
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: color == AppColors.primary
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.labelSm.copyWith(
                  color: color == AppColors.primary ? AppColors.primary : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                color == AppColors.primary ? Icons.account_balance : Icons.event_repeat,
                size: 20,
                color: color == AppColors.primary ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.displayLg.copyWith(color: color, fontSize: 28),
          ),
          if (trend != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Row(
                children: [
                  Icon(trendUp ? Icons.trending_up : Icons.trending_down, size: 18, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(trend, style: AppTypography.bodyMd.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Text('so với tháng trước', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          if (safeBudget != null)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ngân sách an toàn', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                      Text('KHUYÊN DÙNG', style: AppTypography.labelSm.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('~ $safeBudget / tháng', style: AppTypography.titleLg.copyWith(color: AppColors.onSurface)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AppProvider appProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: Text('Cài đặt hệ thống', style: AppTypography.titleLg.copyWith(color: AppColors.onSurface)),
          ),
          Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.1)),
          _buildSettingItem(
            icon: Icons.category,
            iconColor: AppColors.tertiary,
            iconBgColor: AppColors.tertiaryContainer.withValues(alpha: 0.2),
            title: 'Quản lý danh mục',
            subtitle: 'Chỉnh sửa biểu tượng và tên phân loại',
          ),
          _buildSettingItem(
            icon: Icons.file_download_outlined,
            iconColor: AppColors.secondary,
            iconBgColor: AppColors.secondaryContainer.withValues(alpha: 0.2),
            title: 'Xuất dữ liệu',
            subtitle: 'Tải báo cáo định dạng Excel, CSV hoặc PDF',
          ),
          _buildSettingItem(
            icon: Icons.security,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.1),
            title: 'Bảo mật & Quyền riêng tư',
            subtitle: 'Mã PIN, vân tay và xác thực 2 lớp',
            onTap: () => _showSecuritySettings(context, appProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(AppRadius.full)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface)),
                  Text(subtitle, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  void _showSecuritySettings(BuildContext context, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bảo mật & Quyền riêng tư', style: AppTypography.titleLg.copyWith(color: AppColors.onSurface)),
              const SizedBox(height: AppSpacing.lg),
              SwitchListTile(
                title: Text(
                  appProvider.isPinSetup ? 'Đổi mã PIN' : 'Đặt mã PIN',
                  style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
                ),
                subtitle: Text(
                  appProvider.isPinSetup ? 'Mã PIN đã được thiết lập' : 'Bảo vệ ứng dụng bằng mã PIN',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                value: appProvider.isPinSetup,
                activeThumbColor: AppColors.primary,
                onChanged: (value) async {
                  Navigator.of(ctx).pop();
                  if (value) {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => const PinScreen(isSetup: true)),
                    );
                    if (result == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mã PIN đã được thiết lập!')),
                      );
                    }
                  }
                },
              ),
              const Divider(),
              if (appProvider.isPinSetup)
                ListTile(
                  leading: const Icon(Icons.lock, color: AppColors.primary),
                  title: Text('Khóa ngay', style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface)),
                  onTap: () async {
                    await appProvider.lock();
                    if (context.mounted) {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PinScreen()));
                    }
                  },
                ),
              if (appProvider.isPinSetup) const Divider(),
              SwitchListTile(
                title: Text('Xác thực vân tay / Face ID', style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface)),
                subtitle: Text('Sử dụng sinh trắc học để mở khóa nhanh', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                value: appProvider.isBiometricEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (value) => appProvider.toggleBiometric(value),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppProvider appProvider) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
              title: const Text('Đăng xuất'),
              content: const Text('Bạn có chắc muốn đăng xuất?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
                TextButton(
                  onPressed: () {
                    appProvider.lock();
                    Navigator.of(ctx).pop();
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: Text('Đăng xuất', style: AppTypography.titleLg.copyWith(color: AppColors.error)),
      ),
    );
  }
}
