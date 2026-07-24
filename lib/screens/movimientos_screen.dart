import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'transaction_form_screen.dart';

class MovimientosScreen extends StatefulWidget {
  const MovimientosScreen({super.key});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MockTransaction {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String category;
  final String account;
  final double amount;
  final bool isIncome;
  final DateTime date;

  _MockTransaction({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.category,
    required this.account,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  String _selectedFilter = 'Todo'; // 'Todo', 'Gastos', 'Ingresos'
  String? _seleccionCategoria = 'Todas'; // Categorias que seran visualizadas
  String? _seleccionCuenta = 'Todas'; // Cuentas
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _showFilters = false;

  late final List<String> _listaCategorias;
  late final List<String> _listaCuentas;
  late final List<_MockTransaction> _allTransactions;
  List<_MockTransaction> _filteredTransactions = [];

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _listaCategorias = [
      'Todas',
      'Alimentación',
      'Transporte',
      'Salud',
      'Educación',
      'Entretenimiento',
      'Vivienda',
      'Ropa',
      'Servicios',
      'Salario',
      'Freelance',
      'Inversiones',
      'Otros',
    ];

    _listaCuentas = ['Todas', 'Efectivo', 'Banco BBVA', 'Tarjeta Visa'];

    _allTransactions = [
      _MockTransaction(
        icon: Icons.work_rounded,
        iconBgColor: const Color(0xFF2E2421),
        iconColor: const Color(0xFFFF8C69),
        title: 'Salario julio',
        category: 'Salario',
        account: 'Banco BBVA',
        amount: 18000.0,
        isIncome: true,
        date: DateTime(2026, 7, 18),
      ),
      _MockTransaction(
        icon: Icons.home_rounded,
        iconBgColor: const Color(0xFF2C241E),
        iconColor: const Color(0xFFFFA500),
        title: 'Renta mensual',
        category: 'Vivienda',
        account: 'Banco BBVA',
        amount: -4500.0,
        isIncome: false,
        date: DateTime(2026, 7, 18),
      ),
      _MockTransaction(
        icon: Icons.shopping_cart_rounded,
        iconBgColor: const Color(0xFF1B233A),
        iconColor: const Color(0xFF4D84FF),
        title: 'Supermercado Walmart',
        category: 'Alimentación',
        account: 'Efectivo',
        amount: -850.0,
        isIncome: false,
        date: DateTime(2026, 7, 17),
      ),
      _MockTransaction(
        icon: Icons.directions_bus_rounded,
        iconBgColor: const Color(0xFF1F2B2A),
        iconColor: const Color(0xFF33D1FF),
        title: 'Tarjeta de Metro',
        category: 'Transporte',
        account: 'Efectivo',
        amount: -320.0,
        isIncome: false,
        date: DateTime(2026, 7, 16),
      ),
    ];

    _filteredTransactions = List.from(_allTransactions);
    _searchController.addListener(_applyFilters);
  }

  void _applyFilters() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredTransactions = _allTransactions.where((tx) {
        // 1. Filter by type
        if (_selectedFilter == 'Gastos' && tx.isIncome) return false;
        if (_selectedFilter == 'Ingresos' && !tx.isIncome) return false;

        // 2. Filter by category
        if (_seleccionCategoria != null &&
            _seleccionCategoria != 'Todas' &&
            tx.category != _seleccionCategoria) {
          return false;
        }

        // 3. Filter by account
        if (_seleccionCuenta != null &&
            _seleccionCuenta != 'Todas' &&
            tx.account != _seleccionCuenta) {
          return false;
        }

        // 4. Filter by date range
        if (_fechaInicio != null && _fechaFin != null) {
          final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
          final start = DateTime(
            _fechaInicio!.year,
            _fechaInicio!.month,
            _fechaInicio!.day,
          );
          final end = DateTime(
            _fechaFin!.year,
            _fechaFin!.month,
            _fechaFin!.day,
          );
          if (txDate.isBefore(start) || txDate.isAfter(end)) {
            return false;
          }
        }

        // 5. Filter by search query
        if (query.isNotEmpty) {
          final titleMatch = tx.title.toLowerCase().contains(query);
          final categoryMatch = tx.category.toLowerCase().contains(query);
          final accountMatch = tx.account.toLowerCase().contains(query);
          if (!titleMatch && !categoryMatch && !accountMatch) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

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
                        'Movimientos',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_filteredTransactions.length} registros',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
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
                      icon: const Icon(
                        Icons.add,
                        color: AppColors.background,
                        size: 22,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TransactionFormScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar transacción...',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.cardBg,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filters Row
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterPill('Todo'),
                          const SizedBox(width: 8),
                          _buildFilterPill('Gastos'),
                          const SizedBox(width: 8),
                          _buildFilterPill('Ingresos'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // General Filters Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _showFilters
                            ? AppColors.mint.withAlpha(26)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showFilters
                              ? AppColors.mint
                              : AppColors.border,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: _showFilters
                                ? AppColors.mint
                                : AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Filtros',
                            style: TextStyle(
                              color: _showFilters
                                  ? AppColors.mint
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_showFilters) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        'Categoría',
                        _seleccionCategoria,
                        _listaCategorias,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        'Cuenta',
                        _seleccionCuenta,
                        _listaCuentas,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDateRangePicker()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildApplyFiltersButton()),
                  ],
                ),
              ],

              const SizedBox(height: 28),

              // Grouped Transaction list
              _buildGroupedTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    String? selectedValue,
    List<String> items,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(hint),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: (value) {
        setState(() {
          if (hint == 'Categoría') {
            _seleccionCategoria = value;
          } else if (hint == 'Cuenta') {
            _seleccionCuenta = value;
          }
          _applyFilters();
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        filled: true,
        fillColor: AppColors.cardBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mint, width: 1.0),
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    final hasDates = _fechaInicio != null && _fechaFin != null;
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.mint,
                  onPrimary: AppColors.background,
                  surface: AppColors.cardBg,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _fechaInicio = picked.start;
            _fechaFin = picked.end;
            _applyFilters();
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.mint, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasDates
                    ? '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year} - ${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'
                    : 'Rango de fechas',
                style: TextStyle(
                  color: hasDates
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasDates)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _fechaInicio = null;
                    _fechaFin = null;
                    _applyFilters();
                  });
                },
                child: const Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyFiltersButton() {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _showFilters = false;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Aplicar filtros',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String title) {
    bool isActive = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
          _applyFilters();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.mint.withAlpha(76) : AppColors.border,
            width: 1.0,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedTransactions() {
    if (_filteredTransactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'No hay transacciones registradas',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Group transactions by day
    Map<String, List<_MockTransaction>> grouped = {};
    for (var tx in _filteredTransactions) {
      String dateStr = _formatDateHeader(tx.date);
      grouped.putIfAbsent(dateStr, () => []);
      grouped[dateStr]!.add(tx);
    }

    List<Widget> listItems = [];
    grouped.forEach((dateStr, transactions) {
      listItems.add(_buildDateHeader(dateStr));
      listItems.add(const SizedBox(height: 12));
      for (int i = 0; i < transactions.length; i++) {
        final tx = transactions[i];
        listItems.add(
          _buildTransactionRowItem(
            icon: tx.icon,
            iconBgColor: tx.iconBgColor,
            iconColor: tx.iconColor,
            title: tx.title,
            subtitle: '${tx.category} · ${tx.account}',
            amount: '${tx.amount >= 0 ? '+' : ''}\$${_formatMoney(tx.amount)}',
            isIncome: tx.isIncome,
            onDelete: () => _showDeleteDialog(context, tx),
          ),
        );
        if (i < transactions.length - 1) {
          listItems.add(const SizedBox(height: 12));
        }
      }
      listItems.add(const SizedBox(height: 24));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: listItems,
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'HOY';
    } else if (checkDate == yesterday) {
      return 'AYER';
    } else {
      final months = [
        'ENE',
        'FEB',
        'MAR',
        'ABR',
        'MAY',
        'JUN',
        'JUL',
        'AGO',
        'SEP',
        'OCT',
        'NOV',
        'DIC',
      ];
      final daysMap = {
        1: 'LUNES',
        2: 'MARTES',
        3: 'MIÉRCOLES',
        4: 'JUEVES',
        5: 'VIERNES',
        6: 'SÁBADO',
        7: 'DOMINGO',
      };
      String dayStr = daysMap[date.weekday] ?? '';
      return '$dayStr ${date.day} DE ${months[date.month - 1]}';
    }
  }

  String _formatMoney(double amount) {
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }

  Widget _buildDateHeader(String dateString) {
    return Text(
      dateString,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTransactionRowItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required bool isIncome,
    required VoidCallback onDelete,
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
          // Left Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
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
                  subtitle,
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
          const SizedBox(width: 14),
          // Bin/Delete Icon
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
    );
  }

  void _showDeleteDialog(BuildContext context, _MockTransaction tx) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Eliminar movimiento',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar "${tx.title}"?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _allTransactions.remove(tx);
                  _applyFilters();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Movimiento "${tx.title}" eliminado'),
                    backgroundColor: AppColors.coral,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: AppColors.coral,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
