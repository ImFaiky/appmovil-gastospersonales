import 'package:flutter/material.dart';
import 'package:gastosmart/entities/cuentaModel.dart';
import 'package:gastosmart/entities/movimientoModel.dart';
import 'package:gastosmart/repositories/cuentaRepository.dart';
import 'package:gastosmart/repositories/movimientoRepository.dart';
import 'package:gastosmart/repositories/usuarioRepository.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'transaction_form_screen.dart';

class InicioScreen extends StatefulWidget {
  final int userId;
  final Function(int)? onTabSelected;
  final bool isActive;
  const InicioScreen({
    super.key,
    required this.userId,
    this.onTabSelected,
    this.isActive = false,
  });

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _usuarioRepository = Usuariorepository();
  final _cuentaRepository = CuentaRepository();
  final _movimientoRepository = MovimientoRepository();

  String _nombre = '';
  double _saldoTotal = 0;
  double _ingresos = 0;
  double _gastos = 0;
  double _ahorro = 0;
  List<Cuentamodel> _cuentas = [];
  List<Movimientomodel> _movimientosRecientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant InicioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      // 1. Cargar datos del usuario
      final usuario = await _usuarioRepository.getById(widget.userId);
      final nombre = usuario?.nombre ?? 'Usuario';

      // 2. Cargar cuentas del usuario
      final cuentas = await _cuentaRepository.getAll(widget.userId);

      // 3. Calcular saldo total
      final saldoTotal = await _cuentaRepository.getSaldoTotal(widget.userId);

      // 4. Calcular ingresos y gastos totales sumando de todas las cuentas
      double ingresos = 0;
      double gastos = 0;
      for (var cuenta in cuentas) {
        if (cuenta.id != null) {
          ingresos += await _movimientoRepository.getIngresos(cuenta.id!);
          gastos += await _movimientoRepository.getGastos(cuenta.id!);
        }
      }

      // 5. Calcular ahorro
      final ahorro = ingresos - gastos;

      // 6. Cargar movimientos recientes
      final movimientos = await _movimientoRepository.getLast(widget.userId);

      if (!mounted) return;

      setState(() {
        _nombre = nombre;
        _saldoTotal = saldoTotal;
        _ingresos = ingresos;
        _gastos = gastos;
        _ahorro = ahorro;
        _cuentas = cuentas;
        _movimientosRecientes = movimientos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatMoney(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    // Formatear con separadores de miles
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

  // Obtener icono según el tipo de cuenta
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

  // Obtener color del icono según el tipo de cuenta
  Color _getAccountIconColor(String colorStr, String tipo) {
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

  // Obtener icono según el tipo de movimiento
  IconData _getMovimientoIcon(String tipo) {
    if (tipo == 'ingreso') {
      return Icons.trending_up_rounded;
    } else {
      return Icons.trending_down_rounded;
    }
  }

  // Obtener mes actual en español
  String _getMesActual() {
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final now = DateTime.now();
    return '${meses[now.month - 1]} De ${now.year}';
  }

  // Formatear fecha corta
  String _formatFechaCorta(DateTime fecha) {
    final meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${fecha.day}-${meses[fecha.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.mint),
        ),
      );
    }

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
                        'HOLA,',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_nombre 👋',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // Logout back to LoginScreen
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border, width: 1.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Balance Card (SALDO TOTAL)
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.balanceCardStart,
                      AppColors.balanceCardEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.mint.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SALDO TOTAL',
                      style: TextStyle(
                        color: AppColors.mint,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatMoney(_saldoTotal),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Ingresos
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    color: AppColors.mint,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Ingresos',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatMoney(_ingresos),
                                style: const TextStyle(
                                  color: AppColors.mint,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Divider Line
                        Container(
                          width: 1,
                          height: 35,
                          color: AppColors.border,
                        ),
                        const SizedBox(width: 16),
                        // Gastos
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.trending_down_rounded,
                                    color: AppColors.coral,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Gastos',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatMoney(_gastos),
                                style: const TextStyle(
                                  color: AppColors.coral,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getMesActual(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Register Transaction Button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TransactionFormScreen(userId: widget.userId),
                      ),
                    );
                    // Recargar datos al regresar del formulario
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, size: 20, fontWeight: FontWeight.bold),
                      SizedBox(width: 8),
                      Text(
                        'Registrar transacción',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Mis Cuentas Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis cuentas',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onTabSelected?.call(2); // Cuentas tab
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'Ver todas',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Accounts Horizontal List (datos reales)
              SizedBox(
                height: 125,
                child: _cuentas.isEmpty
                    ? Center(
                        child: Text(
                          'No tienes cuentas registradas',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _cuentas.length,
                        itemBuilder: (context, index) {
                          final cuenta = _cuentas[index];
                          return _buildAccountCard(
                            icon: _getAccountIcon(cuenta.tipo),
                            iconColor: _getAccountIconColor(cuenta.color, cuenta.tipo),
                            title: cuenta.nombre,
                            amount: _formatMoney(cuenta.saldo),
                            isNegative: cuenta.saldo < 0,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),

              // Savings Month Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBg.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ahorro este mes',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_ahorro >= 0 ? '+' : ''}${_formatMoney(_ahorro)}',
                      style: TextStyle(
                        color: _ahorro >= 0 ? AppColors.mint : AppColors.coral,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Recientes Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recientes',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onTabSelected?.call(1); // Movimientos tab
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'Ver todo',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recent Transactions List (datos reales)
              _movimientosRecientes.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'No hay movimientos recientes',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: _movimientosRecientes.map((movimiento) {
                        final isIngreso = movimiento.tipo == 'ingreso';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildTransactionItem(
                            icon: _getMovimientoIcon(movimiento.tipo),
                            iconBgColor: isIngreso
                                ? const Color(0xFF1B2E2A)
                                : const Color(0xFF2E2421),
                            iconColor: isIngreso
                                ? AppColors.mint
                                : AppColors.coral,
                            title: movimiento.descripcion,
                            category: movimiento.tipo == 'ingreso'
                                ? 'Ingreso'
                                : 'Gasto',
                            date: _formatFechaCorta(movimiento.fecha),
                            amount:
                                '${isIngreso ? '+' : '-'}${_formatMoney(movimiento.monto)}',
                            isIncome: isIngreso,
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
    required bool isNegative,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon Box
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 20)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  color: isNegative ? AppColors.coral : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String category,
    required String date,
    required String amount,
    required bool isIncome,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 22)),
          ),
          const SizedBox(width: 14),
          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date · $category',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            amount,
            style: TextStyle(
              color: isIncome ? AppColors.mint : AppColors.coral,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
