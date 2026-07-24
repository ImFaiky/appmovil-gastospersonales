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
  String? _seleccionCategoria; //Categorias que seran visualizadas
  String? _seleccionCuenta; //Cuentas
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _showFilters = false;

  //Para almacenar los datos
  List<String> _listaCategorias = [];
  List<String> _listaCuentas = [];

  final _searchController = TextEditingController();

  // Database variables
  final _movimientoRepository = MovimientoRepository();
  final _cuentaRepository = CuentaRepository();
  final _db = DbConnection();

  List<Movimientomodel> _allMovimientos = [];
  List<Movimientomodel> _filteredMovimientos = [];
  Map<int, Cuentamodel> _cuentasMap = {};
  Map<int, Map<String, dynamic>> _categoriasMap = {};
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

          _listaCuentas = accounts.map((acc) => acc.nombre).toList();
          _listaCategorias = categoriesResult.map((cat) => cat['nombre'] as String).toSet().toList();

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
      temp = temp.where((mov) => mov.descripcion.toLowerCase().contains(query)).toList();
    }

    // 2. Filter by Type (Todo, Gastos, Ingresos)
    if (_selectedFilter == 'Gastos') {
      temp = temp.where((mov) => mov.tipo == 'gasto').toList();
    } else if (_selectedFilter == 'Ingresos') {
      temp = temp.where((mov) => mov.tipo == 'ingreso').toList();
    }

    // 3. Filter by Category
    if (_seleccionCategoria != null) {
      temp = temp.where((mov) {
        final cat = _categoriasMap[mov.categoriaId];
        return cat != null && cat['nombre'] == _seleccionCategoria;
      }).toList();
    }

    // 4. Filter by Account
    if (_seleccionCuenta != null) {
      temp = temp.where((mov) {
        final acc = _cuentasMap[mov.cuentaId];
        return acc != null && acc.nombre == _seleccionCuenta;
      }).toList();
    }

    // 5. Filter by Date Range
    if (_fechaInicio != null) {
      final start = DateTime(_fechaInicio!.year, _fechaInicio!.month, _fechaInicio!.day);
      temp = temp.where((mov) => mov.fecha.isAfter(start) || mov.fecha.isAtSameMomentAs(start)).toList();
    }
    if (_fechaFin != null) {
      final end = DateTime(_fechaFin!.year, _fechaFin!.month, _fechaFin!.day, 23, 59, 59);
      temp = temp.where((mov) => mov.fecha.isBefore(end) || mov.fecha.isAtSameMomentAs(end)).toList();
    }

    setState(() {
      _filteredMovimientos = temp;
    });
  }

  String _formatHeaderDate(DateTime date) {
    final List<String> days = ['DOMINGO', 'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO'];
    final List<String> months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    final dayName = days[date.weekday % 7];
    final monthName = months[date.month - 1];
    return '$dayName ${date.day} DE $monthName';
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
          child: CircularProgressIndicator(
            color: AppColors.mint,
          ),
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
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1.0),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.tune_rounded,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Filtros',
                            style: TextStyle(
                              color: AppColors.textSecondary,
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
              if (_showFilters)
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        'Categoría',
                        _seleccionCategoria,
                        _listaCategorias,
                      ),
                    ),
                    Expanded(
                      child: _buildDropdown(
                        'Cuenta',
                        _seleccionCuenta,
                        _listaCuentas,
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  Expanded(child: _buildDateRangePicker()),
                  Expanded(child: _buildApplyFiltersButton()),
                ],
              ),

              const SizedBox(height: 28),

              // Grouped Transaction list
              _buildGroupedTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  //Para la seleccion de los filtros muestre el listado
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  // Para el widget DateRangePicker, nos permita seleccionar fechas
  Widget _buildDateRangePicker() {
    final startText = _fechaInicio != null ? '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}' : 'Inicio';
    final endText = _fechaFin != null ? '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}' : 'Fin';
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.calendar_today, color: AppColors.mint, size: 20),
          onPressed: () async {
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
        ),
        Expanded(
          child: Text(
            '$startText - $endText',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  //Para el boton de aplicar filtros
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
            color: isActive
                ? AppColors.mint.withOpacity(0.3)
                : AppColors.border,
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

    // Grouping movements by date (year-month-day)
    final Map<String, List<Movimientomodel>> grouped = {};
    for (var mov in _filteredMovimientos) {
      final dateKey = '${mov.fecha.year}-${mov.fecha.month}-${mov.fecha.day}';
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(mov);
    }

    // Convert grouped Map to Sorted List of dates
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aParts = a.split('-').map(int.parse).toList();
        final bParts = b.split('-').map(int.parse).toList();
        final aDate = DateTime(aParts[0], aParts[1], aParts[2]);
        final bDate = DateTime(bParts[0], bParts[1], bParts[2]);
        return bDate.compareTo(aDate); // Descending (most recent first)
      });

    List<Widget> listItems = [];

    for (var dateKey in sortedKeys) {
      final movementsInDate = grouped[dateKey]!;
      final dateParts = dateKey.split('-').map(int.parse).toList();
      final dateObj = DateTime(dateParts[0], dateParts[1], dateParts[2]);

      listItems.add(_buildDateHeader(_formatHeaderDate(dateObj)));
      listItems.add(const SizedBox(height: 12));

      for (int i = 0; i < movementsInDate.length; i++) {
        final mov = movementsInDate[i];
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
            iconBgColor: _getColor(categoryColorStr).withOpacity(0.12),
            iconColor: _getColor(categoryColorStr),
            title: mov.descripcion,
            subtitle: '$categoryName · $accountName',
            amount: '${isIncome ? '+' : '-'}\$${mov.monto.toStringAsFixed(2)}',
            isIncome: isIncome,
            movement: mov,
          ),
        );

        if (i < movementsInDate.length - 1) {
          listItems.add(const SizedBox(height: 12));
        }
      }
      listItems.add(const SizedBox(height: 24));
    }

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
              color: AppColors.textSecondary.withOpacity(0.5),
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtros avanzados',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'CUENTA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['Todas', 'Efectivo', 'Banco BBVA', 'Tarjeta Visa']
                    .map((account) {
                      return Chip(
                        backgroundColor: AppColors.background,
                        label: Text(
                          account,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      );
                    })
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Filtros aplicados'),
                        backgroundColor: AppColors.mint,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Aplicar filtros',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
