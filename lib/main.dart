import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/app_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/asset_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/budget_provider.dart';
import 'screens/overview_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/assets_screen.dart';
import 'screens/bills_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AssetProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: MaterialApp(
        title: 'Quản lý Tài chính',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            primaryContainer: AppColors.primaryContainer,
            onPrimaryContainer: AppColors.onPrimaryContainer,
            secondary: AppColors.secondary,
            onSecondary: AppColors.onSecondary,
            secondaryContainer: AppColors.secondaryContainer,
            onSecondaryContainer: AppColors.onSecondaryContainer,
            tertiary: AppColors.tertiary,
            error: AppColors.error,
            onError: AppColors.onError,
            errorContainer: AppColors.errorContainer,
            onErrorContainer: AppColors.onErrorContainer,
            surface: AppColors.surface,
            onSurface: AppColors.onSurface,
            onSurfaceVariant: AppColors.onSurfaceVariant,
            outline: AppColors.outline,
            outlineVariant: AppColors.outlineVariant,
          ),
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: AppTypography.bodyFont,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surfaceContainerLow,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontFamily: AppTypography.headlineFont,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.surfaceContainer,
            selectedItemColor: AppColors.onSecondaryContainer,
            unselectedItemColor: AppColors.onSurfaceVariant,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              elevation: 4,
            ),
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isInitialized = false;
  bool _needsPinSetup = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final appProvider = context.read<AppProvider>();
    final txProvider = context.read<TransactionProvider>();
    final assetProvider = context.read<AssetProvider>();
    final billProvider = context.read<BillProvider>();
    
    await appProvider.initialize();
    txProvider.setUser(appProvider.user);
    await txProvider.loadTransactions();
    await assetProvider.loadAssets();
    await billProvider.loadBills();

    // Sync budget provider with current transactions
    final budgetProvider = context.read<BudgetProvider>();
    await budgetProvider.loadBudgets();
    budgetProvider.syncTransactions(txProvider.transactions);

    final isPinSet = appProvider.isPinSetup;
    final isLocked = await appProvider.securityService.isLocked();

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _needsPinSetup = !isPinSet || isLocked;
      });

      if (!isPinSet) {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => const PinScreen(isSetup: true),
          ),
        );
        if (result == true && mounted) {
          setState(() => _needsPinSetup = false);
        }
      } else if (isLocked) {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => const PinScreen(),
          ),
        );
        if (result == true && mounted) {
          setState(() => _needsPinSetup = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_needsPinSetup) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return const MainShell();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToScreen(int index) {
    _pageController.jumpToPage(index);
    context.read<AppProvider>().setTabIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceContainerLow,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Quản lý Tài chính',
                  style: TextStyle(
                    fontFamily: AppTypography.headlineFont,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => appProvider.setTabIndex(index),
            children: const [
              OverviewScreen(),
              TransactionHistoryScreen(),
              AssetsScreen(),
              BillsScreen(),
              ProfileScreen(),
            ],
          ),
          floatingActionButton: appProvider.currentTabIndex != 4
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddTransactionScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: const Icon(Icons.add, size: 28),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xs,
                  AppSpacing.xs,
                  AppSpacing.xs,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.dashboard,
                      label: 'Tổng quan',
                      index: 0,
                      currentIndex: appProvider.currentTabIndex,
                      onTap: () => _navigateToScreen(0),
                    ),
                    _buildNavItem(
                      icon: Icons.receipt_long,
                      label: 'Giao dịch',
                      index: 1,
                      currentIndex: appProvider.currentTabIndex,
                      onTap: () => _navigateToScreen(1),
                    ),
                    _buildNavItem(
                      icon: Icons.account_balance,
                      label: 'Tài sản',
                      index: 2,
                      currentIndex: appProvider.currentTabIndex,
                      onTap: () => _navigateToScreen(2),
                    ),
                    _buildNavItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'Hóa đơn',
                      index: 3,
                      currentIndex: appProvider.currentTabIndex,
                      onTap: () => _navigateToScreen(3),
                    ),
                    _buildNavItem(
                      icon: Icons.person,
                      label: 'Cá nhân',
                      index: 4,
                      currentIndex: appProvider.currentTabIndex,
                      onTap: () => _navigateToScreen(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.onSecondaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}