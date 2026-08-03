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
                  Text(
                    'Categorías (${activeCategories.length})',
                    style: const TextStyle(
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
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CategoryFormScreen(),
                          ),
                        );
                        _cargarCategorias();
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
                ? Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.category_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No existen categorías",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Presiona el botón + para crear una.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
              :GridView.builder(
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
                    categoria: item,
                    icon: _obtenerIcono(item.icono),
                    iconColor: _obtenerColor(item.color),
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

  IconData _obtenerIcono(String icono) {
  return IconData(
    int.parse(icono),
    fontFamily: 'MaterialIcons',
  );
}

Color _obtenerColor(String color) {
  return Color(int.parse(color));
}

  Widget _buildCategoryGridItem({
    required CategoriaModel categoria,
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
                categoria.nombre,
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
          left: 8,
          child: GestureDetector(
            onTap: () async {

              bool? actualizado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryFormScreen(
                    categoria: categoria,
                  ),
                ),
              );

              if (actualizado == true) {
                _cargarCategorias();
              }
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.8),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.edit,
                size: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),

        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _showDeleteCategoryDialog(context, categoria),
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

  void _showDeleteCategoryDialog(BuildContext context, CategoriaModel categoria,) {
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
            '¿Estás seguro de que deseas eliminar la categoría "${categoria.nombre}"?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                await _repository.delete(categoria.id!);
                if (!mounted) return;
                Navigator.of(context).pop();
                await _cargarCategorias();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Categoría "${categoria.nombre}" eliminada'),
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
