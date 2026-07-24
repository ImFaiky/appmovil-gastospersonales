import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'transaction_form_screen.dart';
import '../entities/movimientoModel.dart';
import '../repositories/movimientoRepository.dart';
import '../repositories/cuentaRepository.dart';
import '../entities/cuentaModel.dart';
import '../settings/db_conection.dart';

class MovimientosScreen extends StatefulWidget {
  final int userId;
  const MovimientosScreen({super.key, required this.userId});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  String _selectedFilter = 'Todo'; // 'Todo', 'Gastos', 'Ingresos'
  String? _seleccionCategoria = 'Todas'; // Categorias que seran visualizadas
  String? _seleccionCuenta = 'Todas'; // Cuentas
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _showFilters = false;

  final _searchController = TextEditingController();

  // Database variables
  final _movimientoRepository = MovimientoRepository();
  final _cuentaRepository = CuentaRepository();
  final _db = DbConnection();

  List<Movimientomodel> _allMovimientos = [];
  List<Movimientomodel> _filteredMovimientos = [];
  Map<int, Cuentamodel> _cuentasMap = {};
  Map<int, Map<String, dynamic>> _categoriasMap = {};

  List<String> _listaCategorias = [];
  List<String> _listaCuentas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiltersAndData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> _loadFiltersAndData() async {
    try {
      final accounts = await _cuentaRepository.getAll(widget.userId);
      final categoriesResult = await _db.getAll('categorias');
      final movements = await _movimientoRepository.getAllForUser(widget.userId);

      if (mounted) {
        setState(() {
          _cuentasMap = { for (var acc in accounts) acc.id!: acc };
          _categoriasMap = { for (var cat in categoriesResult) cat['id'] as int: cat };

          _listaCuentas = ['Todas', ...accounts.map((acc) => acc.nombre)];
          _listaCategorias = ['Todas', ...categoriesResult.map((cat) => cat['nombre'] as String).toSet()];

          _allMovimientos = movements;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<Movimientomodel> temp = List.from(_allMovimientos);

    // 1. Filter by Search Query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      temp = temp.where((mov) {
        final category = _categoriasMap[mov.categoriaId];
        final categoryName = category?['nombre'] as String? ?? '';
        final account = _cuentasMap[mov.cuentaId];
        final accountName = account?.nombre ?? '';
        return mov.descripcion.toLowerCase().contains(query) ||
               categoryName.toLowerCase().contains(query) ||
               accountName.toLowerCase().contains(query);
      }).toList();
    }

    // 2. Filter by Type (Todo, Gastos, Ingresos)
    if (_selectedFilter == 'Gastos') {
      temp = temp.where((mov) => mov.tipo == 'gasto').toList();
    } else if (_selectedFilter == 'Ingresos') {
      temp = temp.where((mov) => mov.tipo == 'ingreso').toList();
    }

    // 3. Filter by Category
    if (_seleccionCategoria != null && _seleccionCategoria != 'Todas') {
      temp = temp.where((mov) {
        final cat = _categoriasMap[mov.categoriaId];
        return cat != null && cat['nombre'] == _seleccionCategoria;
      }).toList();
    }

    // 4. Filter by Account
    if (_seleccionCuenta != null && _seleccionCuenta != 'Todas') {
      temp = temp.where((mov) {
        final acc = _cuentasMap[mov.cuentaId];
        return acc != null && acc.nombre == _seleccionCuenta;
      }).toList();
    }

    // 5. Filter by Date Range
    if (_fechaInicio != null && _fechaFin != null) {
      final start = DateTime(_fechaInicio!.year, _fechaInicio!.month, _fechaInicio!.day);
      final end = DateTime(_fechaFin!.year, _fechaFin!.month, _fechaFin!.day, 23, 59, 59);
      temp = temp.where((mov) {
        final txDate = DateTime(mov.fecha.year, mov.fecha.month, mov.fecha.day);
        return (txDate.isAfter(start) || txDate.isAtSameMomentAs(start)) &&
               (txDate.isBefore(end) || txDate.isAtSameMomentAs(end));
      }).toList();
    }

    setState(() {
      _filteredMovimientos = temp;
    });
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
      final List<String> months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
      final Map<int, String> daysMap = {
        1: 'LUNES',
        2: 'MARTES',
        3: 'MIÉRCOLES',
        4: 'JUEVES',
        5: 'VIERNES',
        6: 'SÁBADO',
        7: 'DOMINGO',
      };
      final dayStr = daysMap[date.weekday] ?? '';
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shopping_cart_rounded':
        return Icons.shopping_cart_rounded;
      case 'directions_bus_rounded':
        return Icons.directions_bus_rounded;
      case 'medical_services_rounded':
        return Icons.medical_services_rounded;
      case 'menu_book_rounded':
        return Icons.menu_book_rounded;
      case 'movie_creation_rounded':
        return Icons.movie_creation_rounded;
      case 'home_rounded':
        return Icons.home_rounded;
      case 'checkroom_rounded':
        return Icons.checkroom_rounded;
      case 'lightbulb_rounded':
        return Icons.lightbulb_rounded;
      case 'inventory_2_rounded':
        return Icons.inventory_2_rounded;
      case 'work_rounded':
        return Icons.work_rounded;
      case 'laptop_chromebook_rounded':
        return Icons.laptop_chromebook_rounded;
      case 'trending_up_rounded':
        return Icons.trending_up_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getColor(String colorStr) {
    final intColor = int.tryParse(colorStr) ?? 0xFFFFFFFF;
    return Color(intColor);
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
                        'Movimientos',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_filteredMovimientos.length} registros',
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
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TransactionFormScreen(userId: widget.userId),
                          ),
                        );
                        _loadFiltersAndData();
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
                          color: _showFilters ? AppColors.mint : AppColors.border,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: _showFilters ? AppColors.mint : AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Filtros',
                            style: TextStyle(
                              color: _showFilters ? AppColors.mint : AppColors.textSecondary,
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

              // Grouped Transactions list
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
      hint: Text(hint, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      dropdownColor: AppColors.cardBg,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          if (hint == 'Categoría') {
            _seleccionCategoria = value;
          } else if (hint == 'Cuenta') {
            _seleccionCuenta = value;
          }
        });
        _applyFilters();
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    final startText = _fechaInicio != null ? '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}' : 'Inicio';
    final endText = _fechaFin != null ? '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}' : 'Fin';
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
          });
          _applyFilters();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          color: AppColors.cardBg,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.mint, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$startText - $endText',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyFiltersButton() {
    return ElevatedButton(
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
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: const Text('Aplicar', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFilterPill(String title) {
    bool isActive = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
        _applyFilters();
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
    if (_filteredMovimientos.isEmpty) {
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

    // Grouping movements by date header (HOY, AYER, or formatted)
    final Map<String, List<Movimientomodel>> grouped = {};
    for (var mov in _filteredMovimientos) {
      final dateStr = _formatDateHeader(mov.fecha);
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(mov);
    }

    List<Widget> listItems = [];

    grouped.forEach((dateStr, movements) {
      listItems.add(_buildDateHeader(dateStr));
      listItems.add(const SizedBox(height: 12));

      for (int i = 0; i < movements.length; i++) {
        final mov = movements[i];
        final isIncome = mov.tipo == 'ingreso';
        final account = _cuentasMap[mov.cuentaId];
        final category = _categoriasMap[mov.categoriaId];

        final accountName = account?.nombre ?? 'Cuenta';
        final categoryName = category?.containsKey('nombre') == true ? category!['nombre'] : 'Otros';
        final categoryColorStr = category?.containsKey('color') == true ? category!['color'] : '0xFFFFFFFF';
        final categoryIconStr = category?.containsKey('icono') == true ? category!['icono'] : 'help_outline_rounded';

        listItems.add(
          _buildTransactionRowItem(
            icon: _getIconData(categoryIconStr),
            iconBgColor: _getColor(categoryColorStr).withAlpha(30),
            iconColor: _getColor(categoryColorStr),
            title: mov.descripcion,
            subtitle: '$categoryName · $accountName',
            amount: '${isIncome ? '+' : '-'}\$${_formatMoney(mov.monto)}',
            isIncome: isIncome,
            movement: mov,
          ),
        );

        if (i < movements.length - 1) {
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
    required Movimientomodel movement,
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
            onPressed: () => _showDeleteDialog(context, movement),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Movimientomodel mov) {
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
            '¿Estás seguro de que deseas eliminar "${mov.descripcion}"?',
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
              onPressed: () async {
                try {
                  // 1. Get the account to update its balance
                  final account = _cuentasMap[mov.cuentaId];
                  if (account != null) {
                    final isIncome = mov.tipo == 'ingreso';
                    final newBalance = isIncome ? (account.saldo - mov.monto) : (account.saldo + mov.monto);
                    account.saldo = newBalance;
                    await _cuentaRepository.update(account);
                  }
                  
                  // 2. Delete the movement
                  await _movimientoRepository.delete(mov.id!);
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Movimiento "${mov.descripcion}" eliminado'),
                        backgroundColor: AppColors.coral,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    _loadFiltersAndData();
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al eliminar: $e')),
                    );
                  }
                }
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
