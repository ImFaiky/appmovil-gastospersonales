import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AccountFormScreen extends StatefulWidget {
  const AccountFormScreen({super.key});

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.00');

  IconData _selectedIcon = Icons.account_balance_wallet_rounded;
  Color _selectedColor = AppColors.walletYellow;

  final List<Map<String, dynamic>> _iconOptions = [
    {'icon': Icons.account_balance_wallet_rounded, 'name': 'Billetera'},
    {'icon': Icons.account_balance_rounded, 'name': 'Banco'},
    {'icon': Icons.credit_card_rounded, 'name': 'Tarjeta'},
    {'icon': Icons.savings_rounded, 'name': 'Ahorro'},
  ];

  final List<Color> _colorOptions = [
    AppColors.walletYellow,
    AppColors.bankBlue,
    AppColors.cardPink,
    AppColors.mint,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva cuenta',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Account Name Input
              const Text(
                'NOMBRE DE LA CUENTA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Ej. Banco Estado, Billetera Personal...',
                ),
              ),
              const SizedBox(height: 24),

              // Initial Balance Input
              const Text(
                'SALDO INICIAL',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(color: AppColors.mint, fontSize: 16, fontWeight: FontWeight.bold),
                  hintText: '0.00',
                ),
              ),
              const SizedBox(height: 24),

              // Icon Picker Section
              const Text(
                'SELECCIONAR ICONO',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _iconOptions.map((option) {
                  bool isSelected = _selectedIcon == option['icon'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = option['icon'] as IconData;
                      });
                    },
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedColor.withOpacity(0.15) : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? _selectedColor : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option['icon'] as IconData,
                            color: isSelected ? _selectedColor : AppColors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option['name'] as String,
                            style: TextStyle(
                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Color Picker Section
              const Text(
                'SELECCIONAR COLOR',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _colorOptions.map((color) {
                  bool isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 18),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.textPrimary : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: AppColors.background,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cuenta guardada exitosamente'),
                        backgroundColor: AppColors.mint,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Guardar cuenta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
