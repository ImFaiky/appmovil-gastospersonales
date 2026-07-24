import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'transaction_form_screen.dart';

class MovimientosScreen extends StatefulWidget {
  const MovimientosScreen({super.key});

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

  @override
  void dispose() {
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
                    children: const [
                      Text(
                        'Movimientos',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '25 registros',
                        style: TextStyle(
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
                    onTap: () => _showFilterBottomSheet(context),
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
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  // Para el widget DateRangePicker, nos permita seleccionar fechas
  Widget _buildDateRangePicker() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _fechaInicio = picked.start;
                _fechaFin = picked.end;
              });
            }
          },
        ),
        Text(
          '${_fechaInicio?.year}/${_fechaInicio?.month}/${_fechaInicio?.day} - ${_fechaFin?.year}/${_fechaFin?.month}/${_fechaFin?.day}',
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
      child: const Text('Aplicar filtros'),
    );
  }

  Widget _buildFilterPill(String title) {
    bool isActive = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
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
    // Basic conditional lists for mock filtering demonstration
    List<Widget> listItems = [];

    // Group 1: SÁBADO 18 DE JUL
    List<Widget> saturdayItems = [];
    if (_selectedFilter == 'Todo' || _selectedFilter == 'Ingresos') {
      saturdayItems.add(
        _buildTransactionRowItem(
          icon: Icons.work_rounded,
          iconBgColor: const Color(0xFF2E2421),
          iconColor: const Color(0xFFFF8C69),
          title: 'Salario julio',
          subtitle: 'Salario · Banco BBVA',
          amount: '+\$18,000',
          isIncome: true,
        ),
      );
    }
    if (_selectedFilter == 'Todo' || _selectedFilter == 'Gastos') {
      if (saturdayItems.isNotEmpty)
        saturdayItems.add(const SizedBox(height: 12));
      saturdayItems.add(
        _buildTransactionRowItem(
          icon: Icons.home_rounded,
          iconBgColor: const Color(0xFF2C241E),
          iconColor: const Color(0xFFFFA500),
          title: 'Renta mensual',
          subtitle: 'Vivienda · Banco BBVA',
          amount: '-\$4,500',
          isIncome: false,
        ),
      );
    }

    if (saturdayItems.isNotEmpty) {
      listItems.add(_buildDateHeader('SÁBADO 18 DE JUL'));
      listItems.add(const SizedBox(height: 12));
      listItems.addAll(saturdayItems);
      listItems.add(const SizedBox(height: 24));
    }

    // Group 2: VIERNES 17 DE JUL
    List<Widget> fridayItems = [];
    if (_selectedFilter == 'Todo' || _selectedFilter == 'Gastos') {
      fridayItems.add(
        _buildTransactionRowItem(
          icon: Icons.shopping_cart_rounded,
          iconBgColor: const Color(0xFF1B233A),
          iconColor: const Color(0xFF4D84FF),
          title: 'Supermercado Walmart',
          subtitle: 'Alimentación · Efectivo',
          amount: '-\$850',
          isIncome: false,
        ),
      );
    }

    if (fridayItems.isNotEmpty) {
      listItems.add(_buildDateHeader('VIERNES 17 DE JUL'));
      listItems.add(const SizedBox(height: 12));
      listItems.addAll(fridayItems);
      listItems.add(const SizedBox(height: 24));
    }

    // Group 3: JUEVES 16 DE JUL
    List<Widget> thursdayItems = [];
    if (_selectedFilter == 'Todo' || _selectedFilter == 'Gastos') {
      thursdayItems.add(
        _buildTransactionRowItem(
          icon: Icons.directions_bus_rounded,
          iconBgColor: const Color(0xFF1F2B2A),
          iconColor: const Color(0xFF33D1FF),
          title: 'Tarjeta de Metro',
          subtitle: 'Transporte · Efectivo',
          amount: '-\$320',
          isIncome: false,
        ),
      );
    }

    if (thursdayItems.isNotEmpty) {
      listItems.add(_buildDateHeader('JUEVES 16 DE JUL'));
      listItems.add(const SizedBox(height: 12));
      listItems.addAll(thursdayItems);
    }

    if (listItems.isEmpty) {
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
            onPressed: () => _showDeleteDialog(context, title),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String title) {
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
            '¿Estás seguro de que deseas eliminar "$title"?',
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
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Movimiento "$title" eliminado'),
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
