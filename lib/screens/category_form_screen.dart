import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _nameController = TextEditingController();
  bool _isGasto = true;

  IconData _selectedIcon = Icons.shopping_cart_rounded;
  Color _selectedColor = const Color(0xFF60A5FA);

  final List<IconData> _iconOptions = [
    Icons.shopping_cart_rounded,
    Icons.directions_bus_rounded,
    Icons.medical_services_rounded,
    Icons.menu_book_rounded,
    Icons.movie_creation_rounded,
    Icons.home_rounded,
    Icons.checkroom_rounded,
    Icons.lightbulb_rounded,
    Icons.inventory_2_rounded,
    Icons.work_rounded,
    Icons.laptop_chromebook_rounded,
    Icons.trending_up_rounded,
  ];

  final List<Color> _colorOptions = [
    const Color(0xFF60A5FA), // Blue
    const Color(0xFFFBBF24), // Yellow
    const Color(0xFFF87171), // Red
    const Color(0xFF22D3EE), // Cyan
    const Color(0xFFC084FC), // Purple
    const Color(0xFFFB923C), // Orange
    const Color(0xFF34D399), // Green
    AppColors.mint,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva categoría',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Name Input
              const Text(
                'NOMBRE DE LA CATEGORÍA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Ej. Gimnasio, Mascotas, Regalos...',
                ),
              ),
              const SizedBox(height: 24),

              // Segmented Toggle (Gasto / Ingreso)
              const Text(
                'TIPO',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isGasto = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isGasto ? AppColors.cardBg : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Gasto',
                              style: TextStyle(
                                color: _isGasto ? AppColors.coral : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isGasto = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isGasto ? AppColors.cardBg : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Ingreso',
                              style: TextStyle(
                                color: !_isGasto ? AppColors.mint : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Icon Grid Picker
              const Text(
                'SELECCIONAR ICONO',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _iconOptions.length,
                itemBuilder: (context, index) {
                  IconData icon = _iconOptions[index];
                  bool isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedColor.withOpacity(0.15) : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? _selectedColor : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: isSelected ? _selectedColor : AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Color Picker
              const Text(
                'SELECCIONAR COLOR',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _colorOptions.take(5).map((color) {
                  bool isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 18),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.textPrimary : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: AppColors.background,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Categoría guardada exitosamente'),
                        backgroundColor: AppColors.mint,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Guardar categoría',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
