import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../entities/cuentaModel.dart';
import '../repositories/cuentaRepository.dart';
import '../repositories/movimientoRepository.dart';
import 'account_form_screen.dart';

class CuentasScreen extends StatefulWidget {
  final int userId;
  const CuentasScreen({super.key, required this.userId});

  @override
  State<CuentasScreen> createState() => _CuentasScreenState();
}

class _CuentasScreenState extends State<CuentasScreen> {
  final _cuentaRepository = CuentaRepository();
  final _movimientoRepository = MovimientoRepository();

  List<Cuentamodel> _cuentas = [];
  Map<int, int> _movimientosCount = {};
  double _saldoNeto = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCuentas();
  }

  Future<void> _loadCuentas() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final cuentas = await _cuentaRepository.getAll(widget.userId);
      final saldoNeto = await _cuentaRepository.getSaldoTotal(widget.userId);

      // Load movement count for each account
      Map<int, int> cuentaMovimientosCount = {};
      for (var cuenta in cuentas) {
        if (cuenta.id != null) {
          final movimientos = await _movimientoRepository.getAll(cuenta.id!);
          cuentaMovimientosCount[cuenta.id!] = movimientos.length;
        }
      }

      if (!mounted) return;
      setState(() {
        _cuentas = cuentas;
        _saldoNeto = saldoNeto;
        _movimientosCount = cuentaMovimientosCount;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getAccountIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'billetera':
      case 'efectivo':
        return Icons.account_balance_wallet_rounded;
      case 'banco':
        return Icons.account_balance_rounded;
      case 'tarjeta':
        return Icons.credit_card_rounded;
      case 'ahorro':
      case 'ahorros':
        return Icons.savings_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color _getAccountColor(String colorStr, String tipo) {
    try {
      return Color(int.parse(colorStr));
    } catch (_) {
      switch (tipo.toLowerCase()) {
        case 'billetera':
        case 'efectivo':
          return AppColors.walletYellow;
        case 'banco':
          return AppColors.bankBlue;
        case 'tarjeta':
          return AppColors.cardPink;
        case 'ahorro':
        case 'ahorros':
          return AppColors.mint;
        default:
          return AppColors.walletYellow;
      }
    }
  }

  String _formatMoney(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(parts[i]);
    }
    return '${isNegative ? '-' : ''}\$${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCuentas,
          color: AppColors.mint,
          backgroundColor: AppColors.cardBg,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                          children: [
                            const Text(
                              'Saldo neto: ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _formatMoney(_saldoNeto),
                              style: TextStyle(
                                color: _saldoNeto >= 0 ? AppColors.mint : AppColors.coral,
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
                              builder: (context) => AccountFormScreen(userId: widget.userId),
                            ),
                          ).then((value) {
                            if (value == true) {
                              _loadCuentas();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Accounts Vertical List
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: CircularProgressIndicator(color: AppColors.mint),
                    ),
                  )
                else if (_cuentas.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        'No tienes cuentas registradas',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Column(
                    children: _cuentas.map((cuenta) {
                      final icon = _getAccountIcon(cuenta.tipo);
                      final iconColor = _getAccountColor(cuenta.color, cuenta.tipo);
                      final movCount = _movimientosCount[cuenta.id] ?? 0;
                      final progress = (_saldoNeto > 0 && cuenta.saldo > 0)
                          ? (cuenta.saldo / _saldoNeto)
                          : 0.0;

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AccountFormScreen(
                                    userId: widget.userId,
                                    account: cuenta,
                                  ),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  _loadCuentas();
                                }
                              });
                            },
                            child: _buildAccountDetailsCard(
                              context,
                              icon: icon,
                              iconColor: iconColor,
                              name: cuenta.nombre,
                              subtitle: '${cuenta.tipo} · $movCount mov.',
                              amount: _formatMoney(cuenta.saldo),
                              isNegative: cuenta.saldo < 0,
                              progress: progress,
                              progressColor: iconColor,
                              onDelete: () => _showDeleteAccountDialog(context, cuenta),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                  ),
              ],
            ),
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
    required VoidCallback onDelete,
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
                  color: iconColor.withAlpha(30),
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
                  color: AppColors.textSecondary.withAlpha(128),
                  size: 20,
                ),
                onPressed: onDelete,
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

  void _showDeleteAccountDialog(BuildContext context, Cuentamodel cuenta) {
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
            '¿Estás seguro de que deseas eliminar la cuenta "${cuenta.nombre}"? Se perderá el registro de su saldo actual.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _cuentaRepository.delete(cuenta.id!);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _loadCuentas();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cuenta "${cuenta.nombre}" eliminada'),
                        backgroundColor: AppColors.coral,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al eliminar la cuenta'),
                        backgroundColor: AppColors.coral,
                      ),
                    );
                  }
                }
              },
              child: const Text('Eliminar', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
