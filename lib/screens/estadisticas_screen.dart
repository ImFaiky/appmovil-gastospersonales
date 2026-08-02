import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../theme/app_colors.dart';
import '../repositories/movimientoRepository.dart';
import '../repositories/categoriaRepository.dart';

class EstadisticasScreen extends StatefulWidget {
  final int userId;
  final bool isActive;
  const EstadisticasScreen({super.key, required this.userId, this.isActive = false});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> with SingleTickerProviderStateMixin {
  String _activeTab = 'Mensual'; // 'Mensual', 'Categorías', 'Tendencia'
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  // Database repositories
  final _movimientoRepository = MovimientoRepository();
  final _categoriaRepository = CategoriaRepository();

  // Animation controller
  late AnimationController _animationController;

  // Data states
  bool _isLoading = true;
  double _totalIngresos = 0.0;
  double _totalGastos = 0.0;
  double _totalAhorro = 0.0;

  // Last 6 months labels and totals
  List<String> _monthLabels = [];
  double _maxMonthVal = 1.0;

  // Tab 1 & Tab 3 Ratios
  List<double> _incomeRatios = [];
  List<double> _expenseRatios = [];
  List<double> _savingsRatios = [];

  // Tab 2 (Categorias breakdown)
  List<Map<String, dynamic>> _expenseCategoryDataList = [];
  List<DoughnutSection> _expenseDoughnutSections = [];
  List<Map<String, dynamic>> _incomeCategoryDataList = [];
  List<DoughnutSection> _incomeDoughnutSections = [];
  bool _isGastoFilter = true; // true = Gastos/Egresos, false = Ingresos

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadStats();
  }

  @override
  void didUpdateWidget(covariant EstadisticasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadStats();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      var movimientos = await _movimientoRepository.getAllForUser(widget.userId);

      // Filter by Date Range if selected
      if (_fechaInicio != null && _fechaFin != null) {
        final start = DateTime(_fechaInicio!.year, _fechaInicio!.month, _fechaInicio!.day);
        final end = DateTime(_fechaFin!.year, _fechaFin!.month, _fechaFin!.day, 23, 59, 59);
        movimientos = movimientos.where((mov) {
          final txDate = DateTime(mov.fecha.year, mov.fecha.month, mov.fecha.day);
          return (txDate.isAfter(start) || txDate.isAtSameMomentAs(start)) &&
                 (txDate.isBefore(end) || txDate.isAtSameMomentAs(end));
        }).toList();
      }

      final categorias = await _categoriaRepository.getAll();
      final categoriasMap = {for (var cat in categorias) cat.id!: cat};

      // 1. Calculate top totals (KPI cards)
      double totalIngresos = 0.0;
      double totalGastos = 0.0;
      for (var mov in movimientos) {
        if (mov.tipo == 'ingreso') {
          totalIngresos += mov.monto;
        } else {
          totalGastos += mov.monto;
        }
      }
      double totalAhorro = totalIngresos - totalGastos;

      // 2. Generate last 6 months dynamically
      final now = DateTime.now();
      final List<DateTime> months = List.generate(6, (i) {
        return DateTime(now.year, now.month - (5 - i), 1);
      });

      final mesesNombres = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      final List<String> monthLabels = [];
      final Map<String, double> monthlyIngresos = {};
      final Map<String, double> monthlyGastos = {};

      for (var m in months) {
        final label = mesesNombres[m.month - 1];
        monthLabels.add(label);
        monthlyIngresos[label] = 0.0;
        monthlyGastos[label] = 0.0;
      }

      for (var mov in movimientos) {
        final date = mov.fecha;
        for (var m in months) {
          if (date.year == m.year && date.month == m.month) {
            final label = mesesNombres[m.month - 1];
            if (mov.tipo == 'ingreso') {
              monthlyIngresos[label] = (monthlyIngresos[label] ?? 0.0) + mov.monto;
            } else {
              monthlyGastos[label] = (monthlyGastos[label] ?? 0.0) + mov.monto;
            }
            break;
          }
        }
      }

      // Find max monthly value to scale graphs correctly
      double maxMonthVal = 1.0;
      for (var label in monthLabels) {
        final inc = monthlyIngresos[label] ?? 0.0;
        final exp = monthlyGastos[label] ?? 0.0;
        if (inc > maxMonthVal) maxMonthVal = inc;
        if (exp > maxMonthVal) maxMonthVal = exp;
      }

      // Generate ratio lists for Tab 1 and Tab 3
      final List<double> incomeRatios = [];
      final List<double> expenseRatios = [];
      final List<double> savingsRatios = [];

      for (var label in monthLabels) {
        final inc = monthlyIngresos[label] ?? 0.0;
        final exp = monthlyGastos[label] ?? 0.0;
        final sav = inc - exp;
        incomeRatios.add(inc / maxMonthVal);
        expenseRatios.add(exp / maxMonthVal);
        savingsRatios.add((sav / maxMonthVal).clamp(0.0, 1.0));
      }

      // 3. Group expenses and incomes by category
      final Map<int, double> expensesByCategory = {};
      double totalExpenses = 0.0;
      final Map<int, double> incomesByCategory = {};
      double totalIncomes = 0.0;

      for (var mov in movimientos) {
        if (mov.tipo == 'gasto') {
          expensesByCategory[mov.categoriaId] = (expensesByCategory[mov.categoriaId] ?? 0.0) + mov.monto;
          totalExpenses += mov.monto;
        } else if (mov.tipo == 'ingreso') {
          incomesByCategory[mov.categoriaId] = (incomesByCategory[mov.categoriaId] ?? 0.0) + mov.monto;
          totalIncomes += mov.monto;
        }
      }

      // Process expenses
      final List<Map<String, dynamic>> expenseCategoryDataList = [];
      expensesByCategory.forEach((catId, total) {
        final cat = categoriasMap[catId];
        if (cat != null) {
          expenseCategoryDataList.add({
            'id': catId,
            'nombre': cat.nombre,
            'icono': cat.icono,
            'color': cat.color,
            'total': total,
            'percentage': totalExpenses > 0 ? total / totalExpenses : 0.0,
          });
        }
      });
      expenseCategoryDataList.sort((a, b) => b['total'].compareTo(a['total']));

      final List<DoughnutSection> expenseDoughnutSections = expenseCategoryDataList.map((c) {
        return DoughnutSection(
          percentage: c['percentage'] as double,
          color: _parseCategoryColor(c['color'] as String),
        );
      }).toList();

      // Process incomes
      final List<Map<String, dynamic>> incomeCategoryDataList = [];
      incomesByCategory.forEach((catId, total) {
        final cat = categoriasMap[catId];
        if (cat != null) {
          incomeCategoryDataList.add({
            'id': catId,
            'nombre': cat.nombre,
            'icono': cat.icono,
            'color': cat.color,
            'total': total,
            'percentage': totalIncomes > 0 ? total / totalIncomes : 0.0,
          });
        }
      });
      incomeCategoryDataList.sort((a, b) => b['total'].compareTo(a['total']));

      final List<DoughnutSection> incomeDoughnutSections = incomeCategoryDataList.map((c) {
        return DoughnutSection(
          percentage: c['percentage'] as double,
          color: _parseCategoryColor(c['color'] as String),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _totalIngresos = totalIngresos;
        _totalGastos = totalGastos;
        _totalAhorro = totalAhorro;
        _monthLabels = monthLabels;
        _maxMonthVal = maxMonthVal;
        _incomeRatios = incomeRatios;
        _expenseRatios = expenseRatios;
        _savingsRatios = savingsRatios;
        _expenseCategoryDataList = expenseCategoryDataList;
        _expenseDoughnutSections = expenseDoughnutSections;
        _incomeCategoryDataList = incomeCategoryDataList;
        _incomeDoughnutSections = incomeDoughnutSections;
        _isLoading = false;
      });

      // Start entering animations
      _animationController.forward(from: 0.0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _parseCategoryColor(String colorStr) {
    try {
      if (colorStr.startsWith('0x') || colorStr.startsWith('0X')) {
        return Color(int.parse(colorStr));
      }
      return Color(int.parse(colorStr));
    } catch (_) {
      return AppColors.mint;
    }
  }

  IconData _getCategoryIcon(String iconName) {
    final codePoint = int.tryParse(iconName);
    if (codePoint != null) {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
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
        return Icons.category_rounded;
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

  String _formatAxisLabel(double value) {
    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}k';
    }
    return '\$${value.toStringAsFixed(0)}';
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
              // Header
              const Text(
                'Estadísticas',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Análisis financiero personal',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),

              // Date Range Picker Row
              Row(
                children: [
                  Expanded(
                    child: _buildDateRangePicker(),
                  ),
                  if (_fechaInicio != null || _fechaFin != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.coral, size: 18),
                        onPressed: () {
                          setState(() {
                            _fechaInicio = null;
                            _fechaFin = null;
                          });
                          _loadStats();
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // KPI Row: Ingresos, Gastos, Ahorro
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      label: 'Ingresos',
                      value: _formatMoney(_totalIngresos),
                      valueColor: AppColors.mint,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiCard(
                      label: 'Gastos',
                      value: _formatMoney(_totalGastos),
                      valueColor: AppColors.coral,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiCard(
                      label: 'Ahorro',
                      value: _formatMoney(_totalAhorro),
                      valueColor: AppColors.bankBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tabs Segmented Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Mensual'),
                    _buildTabButton('Categorías'),
                    _buildTabButton('Tendencia'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Active View Container
              _buildActiveView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker() {
    final startText = _fechaInicio != null ? '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}' : 'Inicio';
    final endText = _fechaFin != null ? '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}' : 'Fin';
    final hasRange = _fechaInicio != null && _fechaFin != null;

    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: hasRange
              ? DateTimeRange(start: _fechaInicio!, end: _fechaFin!)
              : null,
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
          _loadStats();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          color: AppColors.cardBg,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppColors.mint, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasRange ? '$startText - $endText' : 'Filtrar por rango de fechas',
                style: TextStyle(
                  color: hasRange ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: hasRange ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabName) {
    bool isActive = _activeTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = tabName;
          });
          _animationController.forward(from: 0.0);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              tabName,
              style: TextStyle(
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveView() {
    switch (_activeTab) {
      case 'Mensual':
        return _buildMensualView();
      case 'Categorías':
        return _buildCategoriasView();
      case 'Tendencia':
        return _buildTendenciaView();
      default:
        return _buildMensualView();
    }
  }

  // --- TAB 1: MENSUAL ---
  Widget _buildMensualView() {
    final yMax = _maxMonthVal;
    final yLabels = [
      _formatAxisLabel(yMax),
      _formatAxisLabel(yMax * 0.75),
      _formatAxisLabel(yMax * 0.5),
      _formatAxisLabel(yMax * 0.25),
      '\$0',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingresos vs Gastos · 6 meses',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Chart Layout
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: yLabels.map((lbl) => Text(lbl, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10))).toList(),
                ),
                const SizedBox(width: 14),
                // Chart Bars Area
                Expanded(
                  child: Stack(
                    children: [
                      // Horizontal Grid Lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          return Container(
                            height: 1,
                            color: AppColors.border.withOpacity(0.3),
                          );
                        }),
                      ),
                      // Bars Row
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final animValue = _animationController.value;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(_monthLabels.length, (index) {
                              final label = _monthLabels[index];
                              final incRatio = _incomeRatios[index] * animValue;
                              final expRatio = _expenseRatios[index] * animValue;
                              return _buildMonthDoubleBar(label, incRatio, expRatio);
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppColors.mint, 'Ingresos'),
              const SizedBox(width: 24),
              _buildLegendItem(AppColors.coral, 'Gastos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDoubleBar(String month, double ingresoRatio, double gastoRatio) {
    const double maxBarHeight = 160.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Bars
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Ingreso (Mint)
            Container(
              width: 8,
              height: math.max(4.0, ingresoRatio * maxBarHeight),
              decoration: const BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(width: 4),
            // Gasto (Coral)
            Container(
              width: 8,
              height: math.max(4.0, gastoRatio * maxBarHeight),
              decoration: const BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // X label
        Text(
          month,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildGastoIngresoToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (!_isGastoFilter) {
                setState(() {
                  _isGastoFilter = true;
                });
                _animationController.forward(from: 0.0);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isGastoFilter ? AppColors.cardBg : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Egresos',
                style: TextStyle(
                  color: _isGastoFilter ? AppColors.coral : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_isGastoFilter) {
                setState(() {
                  _isGastoFilter = false;
                });
                _animationController.forward(from: 0.0);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: !_isGastoFilter ? AppColors.cardBg : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ingresos',
                style: TextStyle(
                  color: !_isGastoFilter ? AppColors.mint : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: CATEGORÍAS ---
  Widget _buildCategoriasView() {
    final categoryDataList = _isGastoFilter ? _expenseCategoryDataList : _incomeCategoryDataList;
    final doughnutSections = _isGastoFilter ? _expenseDoughnutSections : _incomeDoughnutSections;

    if (categoryDataList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isGastoFilter ? 'Egresos por categoría' : 'Ingresos por categoría',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildGastoIngresoToggle(),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                _isGastoFilter
                    ? 'No hay egresos registrados en este período'
                    : 'No hay ingresos registrados en este período',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isGastoFilter ? 'Egresos por categoría' : 'Ingresos por categoría',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildGastoIngresoToggle(),
            ],
          ),
          const SizedBox(height: 24),

          // Doughnut Ring Chart Center Render
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final animVal = _animationController.value;
              final animatedSections = doughnutSections.map((sec) {
                return DoughnutSection(
                  percentage: sec.percentage * animVal,
                  color: sec.color,
                );
              }).toList();

              return Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: DoughnutChartPainter(
                      sections: animatedSections,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // Detailed breakdown Category List
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final animVal = _animationController.value;
              return Column(
                children: categoryDataList.map((c) {
                  final iconName = c['icono'] as String;
                  final icon = _getCategoryIcon(iconName);
                  final colorStr = c['color'] as String;
                  final iconColor = _parseCategoryColor(colorStr);
                  final double percentageVal = c['percentage'] as double;
                  final percentText = '${(percentageVal * 100).toStringAsFixed(0)}%';

                  return _buildCategoryBreakdownRow(
                    icon: icon,
                    iconColor: iconColor,
                    name: c['nombre'] as String,
                    percent: percentText,
                    amount: _formatMoney(c['total'] as double),
                    animProgress: animVal,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownRow({
    required IconData icon,
    required Color iconColor,
    required String name,
    required String percent,
    required String amount,
    required double animProgress,
  }) {
    double barRatio = double.parse(percent.replaceAll('%', '')) / 100.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
              Text(
                percent,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(width: 14),
              Text(
                amount,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Percentage line indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              height: 3,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              color: AppColors.border.withOpacity(0.3),
              child: FractionallySizedBox(
                widthFactor: barRatio * animProgress,
                child: Container(color: iconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: TENDENCIA ---
  Widget _buildTendenciaView() {
    final yMax = _maxMonthVal;
    final yLabels = [
      _formatAxisLabel(yMax),
      _formatAxisLabel(yMax * 0.75),
      _formatAxisLabel(yMax * 0.5),
      _formatAxisLabel(yMax * 0.25),
      '\$0',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendencia · 6 meses',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Line Chart Area
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Y labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: yLabels.map((lbl) => Text(lbl, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10))).toList(),
                ),
                const SizedBox(width: 14),
                // Custom Canvas Area
                Expanded(
                  child: Stack(
                    children: [
                      // Grid lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          return Container(
                            height: 1,
                            color: AppColors.border.withOpacity(0.3),
                          );
                        }),
                      ),
                      // Custom Paint Lines
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final val = _animationController.value;
                          final animatedIngresos = _incomeRatios.map((r) => r * val).toList();
                          final animatedGastos = _expenseRatios.map((r) => r * val).toList();
                          final animatedAhorro = _savingsRatios.map((r) => r * val).toList();

                          return Positioned.fill(
                            child: CustomPaint(
                              painter: TrendLinePainter(
                                ingresosPoints: animatedIngresos.isEmpty ? List.generate(6, (_) => 0.0) : animatedIngresos,
                                gastosPoints: animatedGastos.isEmpty ? List.generate(6, (_) => 0.0) : animatedGastos,
                                ahorroPoints: animatedAhorro.isEmpty ? List.generate(6, (_) => 0.0) : animatedAhorro,
                              ),
                            ),
                          );
                        },
                      ),
                      // Bottom X labels positioned overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _monthLabels.map((lbl) => Text(lbl, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10))).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppColors.mint, 'Ingresos'),
              const SizedBox(width: 16),
              _buildLegendItem(AppColors.coral, 'Gastos'),
              const SizedBox(width: 16),
              _buildLegendItem(AppColors.bankBlue, 'Ahorro', isDashed: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isDashed = false}) {
    return Row(
      children: [
        if (isDashed)
          Row(
            children: [
              Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 2),
              Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ],
          )
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// --- DOUGHNUT CHART PAINTER ---
class DoughnutSection {
  final double percentage;
  final Color color;
  DoughnutSection({required this.percentage, required this.color});
}

class DoughnutChartPainter extends CustomPainter {
  final List<DoughnutSection> sections;
  DoughnutChartPainter({required this.sections});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Rect rect = Rect.fromCircle(center: Offset(radius, radius), radius: radius - 12);

    double startAngle = -math.pi / 2; // Start from top
    const double gapAngle = 0.04;      // Micro gap spacing between arcs

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.square;

    for (var section in sections) {
      if (section.percentage == 0) continue;

      final sweepAngle = (section.percentage * 2 * math.pi) - gapAngle;
      paint.color = section.color;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- TREND LINE PAINTER ---
class TrendLinePainter extends CustomPainter {
  final List<double> ingresosPoints;
  final List<double> gastosPoints;
  final List<double> ahorroPoints;

  TrendLinePainter({
    required this.ingresosPoints,
    required this.gastosPoints,
    required this.ahorroPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Bottom padding for X labels
    final double chartHeight = height - 20;

    // Draw lines
    _drawLine(canvas, width, chartHeight, ingresosPoints, AppColors.mint, false);
    _drawLine(canvas, width, chartHeight, gastosPoints, AppColors.coral, false);
    _drawLine(canvas, width, chartHeight, ahorroPoints, AppColors.bankBlue, true);
  }

  void _drawLine(
    Canvas canvas,
    double width,
    double height,
    List<double> ratios,
    Color color,
    bool isDashed,
  ) {
    final int count = ratios.length;
    if (count < 2) return;
    final double step = width / (count - 1);

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint outerDotPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;

    // Compute pixel points
    final List<Offset> points = [];
    for (int i = 0; i < count; i++) {
      final double x = i * step;
      final double ratioVal = i < ratios.length ? ratios[i] : 0.0;
      final double y = height - (ratioVal * (height - 10)) - 5;
      points.add(Offset(x, y));
    }

    // Draw smooth bezier line or segment path
    final Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < count - 1; i++) {
      final double x1 = points[i].dx;
      final double y1 = points[i].dy;
      final double x2 = points[i + 1].dx;
      final double y2 = points[i + 1].dy;

      final double cx1 = x1 + (x2 - x1) / 2.0;
      final double cy1 = y1;
      final double cx2 = x1 + (x2 - x1) / 2.0;
      final double cy2 = y2;

      path.cubicTo(cx1, cy1, cx2, cy2, x2, y2);
    }

    if (isDashed) {
      final Path dashedPath = Path();
      const double dashWidth = 5.0;
      const double dashSpace = 4.0;
      double distance = 0.0;

      for (final PathMetric metric in path.computeMetrics()) {
        while (distance < metric.length) {
          dashedPath.addPath(
            metric.extractPath(distance, distance + dashWidth),
            Offset.zero,
          );
          distance += dashWidth + dashSpace;
        }
      }
      canvas.drawPath(dashedPath, linePaint);
    } else {
      canvas.drawPath(path, linePaint);
    }

    // Draw dots at each month data point
    for (var point in points) {
      canvas.drawCircle(point, 5, dotPaint);
      canvas.drawCircle(point, 2.5, outerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
