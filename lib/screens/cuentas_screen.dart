import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'account_form_screen.dart';

class CuentasScreen extends StatelessWidget {
  const CuentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cuentas',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Text(
                            'Saldo neto: ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '\$62,950',
                            style: TextStyle(
                              color: AppColors.mint,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Plus Button
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: AppColors.background, size: 22),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AccountFormScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Accounts Vertical List
              Column(
                children: [
                  _buildAccountDetailsCard(
                    context,
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.walletYellow,
                    name: 'Efectivo',
                    subtitle: 'Efectivo · 7 mov.',
                    amount: '\$2,400',
                    isNegative: false,
                    progress: 0.12, // 12% progress representation
                    progressColor: AppColors.walletYellow,
                  ),
                  const SizedBox(height: 16),
                  _buildAccountDetailsCard(
                    context,
                    icon: Icons.account_balance_rounded,
                    iconColor: AppColors.bankBlue,
                    name: 'Banco BBVA',
                    subtitle: 'Banco · 12 mov.',
                    amount: '\$18,750',
                    isNegative: false,
                    progress: 0.38, // 38% progress representation
                    progressColor: AppColors.bankBlue,
                  ),
                  const SizedBox(height: 16),
                  _buildAccountDetailsCard(
                    context,
                    icon: Icons.credit_card_rounded,
                    iconColor: AppColors.cardPink,
                    name: 'Tarjeta Visa',
                    subtitle: 'Tarjeta · 6 mov.',
                    amount: '-\$3,200',
                    isNegative: true,
                    progress: 0.0, // No progress bar or flat
                    progressColor: AppColors.cardPink,
                  ),
                  const SizedBox(height: 16),
                  _buildAccountDetailsCard(
                    context,
                    icon: Icons.savings_rounded,
                    iconColor: AppColors.mint,
                    name: 'Ahorros',
                    subtitle: 'Ahorros · 0 mov.',
                    amount: '\$0',
                    isNegative: false,
                    progress: 0.0, // No progress bar or flat
                    progressColor: AppColors.mint,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDetailsCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String name,
    required String subtitle,
    required String amount,
    required bool isNegative,
    required double progress,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Icon, Name/Subtitle, Trash
          Row(
            children: [
              // Icon Box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              // Titles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Trash Icon
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textSecondary.withOpacity(0.5),
                  size: 20,
                ),
                onPressed: () => _showDeleteAccountDialog(context, name),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Row 2: Balance Amount
          Text(
            amount,
            style: TextStyle(
              color: isNegative ? AppColors.coral : AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          // Row 3: Custom Progress Bar (if progress > 0)
          if (progress > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, String accountName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Eliminar cuenta',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar la cuenta "$accountName"?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cuenta "$accountName" eliminada'),
                    backgroundColor: AppColors.coral,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Eliminar', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
