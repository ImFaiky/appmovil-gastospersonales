import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../entities/cuentaModel.dart';
import '../repositories/cuentaRepository.dart';

class AccountFormScreen extends StatefulWidget {
  final int userId;
  final Cuentamodel? account;
  const AccountFormScreen({super.key, required this.userId, this.account});

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _cuentaRepository = CuentaRepository();
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
  void initState() {
    super.initState();
    if (widget.account != null) {
      final acc = widget.account!;
      _nameController.text = acc.nombre;
      _balanceController.text = acc.saldo.toStringAsFixed(2);
      _selectedIcon = _getIconFromTipo(acc.tipo);
      try {
        _selectedColor = Color(int.parse(acc.color));
      } catch (_) {
        _selectedColor = _getColorFromTipo(acc.tipo);
      }
    }
  }

  IconData _getIconFromTipo(String tipo) {
    switch (tipo) {
      case 'Billetera':
      case 'efectivo':
        return Icons.account_balance_wallet_rounded;
      case 'Banco':
      case 'banco':
        return Icons.account_balance_rounded;
      case 'Tarjeta':
      case 'tarjeta':
        return Icons.credit_card_rounded;
      case 'Ahorro':
      case 'ahorro':
      case 'ahorros':
        return Icons.savings_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color _getColorFromTipo(String tipo) {
    switch (tipo) {
      case 'Billetera':
      case 'efectivo':
        return AppColors.walletYellow;
      case 'Banco':
      case 'banco':
        return AppColors.bankBlue;
      case 'Tarjeta':
      case 'tarjeta':
        return AppColors.cardPink;
      case 'Ahorro':
      case 'ahorro':
      case 'ahorros':
        return AppColors.mint;
      default:
        return AppColors.walletYellow;
    }
  }

  String _getTipoFromIcon(IconData icon) {
    if (icon == Icons.account_balance_wallet_rounded) return 'Billetera';
    if (icon == Icons.account_balance_rounded) return 'Banco';
    if (icon == Icons.credit_card_rounded) return 'Tarjeta';
    if (icon == Icons.savings_rounded) return 'Ahorro';
    return 'Billetera';
  }

  Future<void> _saveAccount() async {
    final name = _nameController.text.trim();
    final balanceText = _balanceController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa el nombre de la cuenta'),
          backgroundColor: AppColors.coral,
        ),
      );
      return;
    }

    final saldo = double.tryParse(balanceText) ?? 0.0;
    final tipo = _getTipoFromIcon(_selectedIcon);
    final colorVal = _selectedColor.toARGB32().toString();

    try {
      if (widget.account == null) {
        // Create Mode
        final newAccount = Cuentamodel(
          nombre: name,
          tipo: tipo,
          saldo: saldo,
          color: colorVal,
          usuarioId: widget.userId,
        );
        await _cuentaRepository.insert(newAccount);
      } else {
        // Edit Mode
        final updatedAccount = Cuentamodel(
          id: widget.account!.id,
          nombre: name,
          tipo: tipo,
          saldo: saldo,
          color: colorVal,
          usuarioId: widget.userId,
        );
        await _cuentaRepository.update(updatedAccount);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar la cuenta'),
          backgroundColor: AppColors.coral,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar cuenta' : 'Nueva cuenta',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
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
              Text(
                isEditing ? 'SALDO ACTUAL' : 'SALDO INICIAL',
                style: const TextStyle(
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
                        color: isSelected ? _selectedColor.withAlpha(38) : AppColors.cardBg,
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
                              color: color.withAlpha(102),
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
                  onPressed: _saveAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'Guardar cambios' : 'Guardar cuenta',
                    style: const TextStyle(
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
