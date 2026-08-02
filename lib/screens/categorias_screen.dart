import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'category_form_screen.dart';
import '../entities/categoriaModel.dart';
import '../repositories/categoriaRepository.dart';
import '../repositories/movimientoRepository.dart';
import '../entities/movimientoModel.dart';

class CategoriasScreen extends StatefulWidget {
  final int? userId;
  final bool isActive;

  const CategoriasScreen({super.key, this.userId, this.isActive = false});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  bool _isGastosSelected = true; // true = Gastos, false = Ingresos
  bool _isLoading = true;

  final CategoriaRepository _categoriaRepository = CategoriaRepository();
  final MovimientoRepository _movimientoRepository = MovimientoRepository();

  List<CategoriaModel> _categorias = [];
  List<Movimientomodel> _allMovements = [];
  Map<int, int> _categoryUses = {}; // Maps categoryId -> usage count
  Map<int, double> _categoryTotals = {}; // Maps categoryId -> total amount

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant CategoriasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Load all categories from SQLite
      final allCategories = await _categoriaRepository.getAll();

      // 2. Load movements to calculate usage counts
      List<Movimientomodel> movements = [];
      if (widget.userId != null) {
        movements = await _movimientoRepository.getAllForUser(widget.userId!);
      } else {
        final maps = await _movimientoRepository.db.getAll('movimientos');
        movements = maps.map((e) => Movimientomodel.fromMap(e)).toList();
      }

      // Count occurrences and sum amounts of each category
      final Map<int, int> uses = {};
      final Map<int, double> totals = {};
      for (var m in movements) {
        uses[m.categoriaId] = (uses[m.categoriaId] ?? 0) + 1;
        totals[m.categoriaId] = (totals[m.categoriaId] ?? 0.0) + m.monto;
      }

      if (!mounted) return;
      setState(() {
        _categorias = allCategories;
        _allMovements = movements;
        _categoryUses = uses;
        _categoryTotals = totals;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar categorías: $e')),
      );
    }
  }

  IconData _getIconData(String iconName) {
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
        return Icons.help_outline_rounded;
    }
  }

  Color _getColor(String colorStr) {
    try {
      if (colorStr.startsWith('0x') || colorStr.startsWith('0X')) {
        return Color(int.parse(colorStr));
      }
      return Color(int.parse(colorStr));
    } catch (_) {
      return AppColors.mint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCategories = _categorias
        .where((c) => _isGastosSelected ? c.tipo == 'gasto' : c.tipo == 'ingreso')
        .toList();

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.mint),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categorías',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
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
                            onPressed: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CategoryFormScreen(),
                                ),
                              );
                              if (result == true) {
                                _loadData();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Segmented Toggle Bar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          // Gastos Tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isGastosSelected = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isGastosSelected
                                      ? AppColors.cardBg
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.money_off_rounded,
                                      color: _isGastosSelected
                                          ? AppColors.mint
                                          : AppColors.textSecondary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Gastos',
                                      style: TextStyle(
                                        color: _isGastosSelected
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Ingresos Tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isGastosSelected = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_isGastosSelected
                                      ? AppColors.cardBg
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.monetization_on_outlined,
                                      color: !_isGastosSelected
                                          ? AppColors.mint
                                          : AppColors.textSecondary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ingresos',
                                      style: TextStyle(
                                        color: !_isGastosSelected
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Categories 3-column Grid
                    activeCategories.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                              child: Text(
                                'No hay categorías disponibles.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.82,
                            ),
                            itemCount: activeCategories.length,
                            itemBuilder: (context, index) {
                              final item = activeCategories[index];
                              final usesCount = _categoryUses[item.id] ?? 0;
                              final totalAmount = _categoryTotals[item.id] ?? 0.0;
                              final usesText = '$usesCount uso${usesCount == 1 ? '' : 's'}';
                              return _buildCategoryGridItem(
                                category: item,
                                uses: usesText,
                                totalAmount: totalAmount,
                              );
                            },
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryGridItem({
    required CategoriaModel category,
    required String uses,
    required double totalAmount,
  }) {
    final iconColor = _getColor(category.color);
    final icon = _getIconData(category.icono);

    return Stack(
      children: [
        // Grid Item Main Container
        GestureDetector(
          onTap: () => _showCategoryDetailsBottomSheet(category),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Circle Background
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                ),
                const SizedBox(height: 10),
                // Category Name
                Text(
                  category.nombre,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                // Amount total spent/earned
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: category.tipo == 'gasto' ? AppColors.coral : AppColors.mint,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                // Usage count
                Text(
                  uses,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Top Right Delete Circular Cross Badge
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _showDeleteCategoryDialog(context, category),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.background.withAlpha(204),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.0),
              ),
              child: const Center(
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 10,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryDetailsBottomSheet(CategoriaModel category) {
    final categoryMovements = _allMovements.where((m) => m.categoriaId == category.id).toList();
    final iconColor = _getColor(category.color);
    final icon = _getIconData(category.icono);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Category Header Info
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: iconColor.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.nombre,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${category.tipo == 'gasto' ? 'Total Gastado' : 'Total Ingresado'}: \$${(_categoryTotals[category.id] ?? 0.0).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: category.tipo == 'gasto' ? AppColors.coral : AppColors.mint,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Edit Button
                      TextButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close bottom sheet
                          final result = await Navigator.of(this.context).push(
                            MaterialPageRoute(
                              builder: (context) => CategoryFormScreen(category: category),
                            ),
                          );
                          if (result == true) {
                            _loadData();
                          }
                        },
                        icon: const Icon(Icons.edit_rounded, color: AppColors.mint, size: 18),
                        label: const Text(
                          'Editar',
                          style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),
                  
                  // Movements List title
                  const Text(
                    'HISTORIAL DE MOVIMIENTOS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // List of movements
                  Expanded(
                    child: categoryMovements.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay transacciones en esta categoría.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          )
                        : ListView.separated(
                            itemCount: categoryMovements.length,
                            separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                            itemBuilder: (context, index) {
                              final mov = categoryMovements[index];
                              final formattedDate = "${mov.fecha.day}/${mov.fecha.month}/${mov.fecha.year}";
                              final sign = mov.tipo == 'gasto' ? '-' : '+';
                              final color = mov.tipo == 'gasto' ? AppColors.coral : AppColors.mint;
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mov.descripcion,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "$sign\$${mov.monto.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteCategoryDialog(BuildContext parentContext, CategoriaModel category) {
    final usesCount = _categoryUses[category.id] ?? 0;
    if (usesCount > 0) {
      showDialog(
        context: parentContext,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: AppColors.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Categoría en uso',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'No se puede eliminar la categoría "${category.nombre}" porque está siendo utilizada en $usesCount transacciones. Para eliminarla, primero debes eliminar o cambiar la categoría de esos movimientos.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Aceptar', style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Eliminar categoría',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar la categoría "${category.nombre}"?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                // Close dialog FIRST before async work
                Navigator.of(dialogContext).pop();
                final scaffoldMessenger = ScaffoldMessenger.of(parentContext);
                try {
                  if (category.id != null) {
                    await _categoriaRepository.delete(category.id!);
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Categoría "${category.nombre}" eliminada'),
                          backgroundColor: AppColors.coral,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      _loadData();
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error al eliminar la categoría: $e'),
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
