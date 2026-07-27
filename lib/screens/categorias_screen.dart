import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../entities/categoriaModel.dart';
import '../repositories/categoriaRepository.dart';
import 'category_form_screen.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final CategoriaRepository _repository = CategoriaRepository();
  bool _isGastosSelected = true; // true = Gastos, false = Ingresos
  List<CategoriaModel> _categorias = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _gastosCategories = [
    {
      'name': 'Alimentación',
      'icon': Icons.shopping_cart_rounded,
      'iconColor': const Color(0xFF60A5FA),
      'uses': '4 usos',
    },
    {
      'name': 'Transporte',
      'icon': Icons.directions_bus_rounded,
      'iconColor': const Color(0xFFFBBF24),
      'uses': '3 usos',
    },
    {
      'name': 'Salud',
      'icon': Icons.medical_services_rounded,
      'iconColor': const Color(0xFFF87171),
      'uses': '2 usos',
    },
    {
      'name': 'Educación',
      'icon': Icons.menu_book_rounded,
      'iconColor': const Color(0xFF22D3EE),
      'uses': '1 usos',
    },
    {
      'name': 'Entretenimiento',
      'icon': Icons.movie_creation_rounded,
      'iconColor': const Color(0xFFC084FC),
      'uses': '2 usos',
    },
    {
      'name': 'Vivienda',
      'icon': Icons.home_rounded,
      'iconColor': const Color(0xFFFB923C),
      'uses': '2 usos',
    },
    {
      'name': 'Ropa',
      'icon': Icons.checkroom_rounded,
      'iconColor': const Color(0xFF34D399),
      'uses': '2 usos',
    },
    {
      'name': 'Servicios',
      'icon': Icons.lightbulb_rounded,
      'iconColor': const Color(0xFFF59E0B),
      'uses': '3 usos',
    },
    {
      'name': 'Otros',
      'icon': Icons.inventory_2_rounded,
      'iconColor': const Color(0xFFA78BFA),
      'uses': '0 usos',
    },
  ];

  final List<Map<String, dynamic>> _ingresosCategories = [
    {
      'name': 'Salario',
      'icon': Icons.work_rounded,
      'iconColor': const Color(0xFFC084FC),
      'uses': '2 usos',
    },
    {
      'name': 'Freelance',
      'icon': Icons.laptop_chromebook_rounded,
      'iconColor': const Color(0xFF60A5FA),
      'uses': '2 usos',
    },
    {
      'name': 'Inversiones',
      'icon': Icons.trending_up_rounded,
      'iconColor': const Color(0xFF34D399),
      'uses': '2 usos',
    },
    {
      'name': 'Otros',
      'icon': Icons.inventory_2_rounded,
      'iconColor': const Color(0xFFFB923C),
      'uses': '0 usos',
    },
  ];

  @override
  void initState(){
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async{
    final categorias = await _repository.getAll();

    setState((){
      _categorias = categorias;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<CategoriaModel> activeCategories = _categorias.where((categoria){
      return categoria.tipo == (_isGastosSelected ? "gasto" : "ingreso");
    }).toList();

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
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CategoryFormScreen(),
                          ),
                        );
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85, // Adjust for square aspect ratios
                ),
                itemCount: activeCategories.length,
                itemBuilder: (context, index) {
                  final item = activeCategories[index];
                  return _buildCategoryGridItem(
                    name: item.nombre,
                    icon: Icons.category,
                    iconColor: Colors.blue,
                    uses: '',
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
    required String name,
    required IconData icon,
    required Color iconColor,
    required String uses,
  }) {
    return Stack(
      children: [
        // Grid Item Main Container
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Circle Background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 24),
                ),
              ),
              const SizedBox(height: 12),
              // Category Name
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Usage count
              Text(
                uses,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        // Top Right Delete Circular Cross Badge
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _showDeleteCategoryDialog(context, name),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.8),
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

  void _showDeleteCategoryDialog(BuildContext context, String categoryName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Eliminar categoría',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar la categoría "$categoryName"?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Categoría "$categoryName" eliminada'),
                    backgroundColor: AppColors.coral,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Eliminar', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
