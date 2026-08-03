import 'package:flutter/material.dart';

/// Helper centralizado para resolver íconos de categorías.
/// Usa un mapa constante de codePoint → IconData para permitir
/// el tree-shaking de íconos en builds de release.
class IconHelper {
  IconHelper._();

  /// Mapa de codePoint (int) a IconData constante.
  /// Contiene todos los íconos disponibles en la app.
  static final Map<int, IconData> _codePointMap = {
    Icons.shopping_cart_rounded.codePoint: Icons.shopping_cart_rounded,
    Icons.directions_bus_rounded.codePoint: Icons.directions_bus_rounded,
    Icons.medical_services_rounded.codePoint: Icons.medical_services_rounded,
    Icons.menu_book_rounded.codePoint: Icons.menu_book_rounded,
    Icons.movie_creation_rounded.codePoint: Icons.movie_creation_rounded,
    Icons.home_rounded.codePoint: Icons.home_rounded,
    Icons.checkroom_rounded.codePoint: Icons.checkroom_rounded,
    Icons.lightbulb_rounded.codePoint: Icons.lightbulb_rounded,
    Icons.inventory_2_rounded.codePoint: Icons.inventory_2_rounded,
    Icons.work_rounded.codePoint: Icons.work_rounded,
    Icons.laptop_chromebook_rounded.codePoint: Icons.laptop_chromebook_rounded,
    Icons.trending_up_rounded.codePoint: Icons.trending_up_rounded,
    Icons.help_outline_rounded.codePoint: Icons.help_outline_rounded,
    Icons.category_rounded.codePoint: Icons.category_rounded,
  };

  /// Mapa de nombre de ícono (String) a IconData constante.
  static const Map<String, IconData> _nameMap = {
    'shopping_cart_rounded': Icons.shopping_cart_rounded,
    'directions_bus_rounded': Icons.directions_bus_rounded,
    'medical_services_rounded': Icons.medical_services_rounded,
    'menu_book_rounded': Icons.menu_book_rounded,
    'movie_creation_rounded': Icons.movie_creation_rounded,
    'home_rounded': Icons.home_rounded,
    'checkroom_rounded': Icons.checkroom_rounded,
    'lightbulb_rounded': Icons.lightbulb_rounded,
    'inventory_2_rounded': Icons.inventory_2_rounded,
    'work_rounded': Icons.work_rounded,
    'laptop_chromebook_rounded': Icons.laptop_chromebook_rounded,
    'trending_up_rounded': Icons.trending_up_rounded,
  };

  /// Resuelve un ícono desde un string que puede ser un codePoint numérico
  /// o un nombre de ícono. Devuelve [fallback] si no se encuentra.
  static IconData resolve(String iconName, {IconData fallback = Icons.help_outline_rounded}) {
    // Intentar parsear como codePoint numérico
    final codePoint = int.tryParse(iconName);
    if (codePoint != null) {
      return _codePointMap[codePoint] ?? fallback;
    }
    // Buscar por nombre
    return _nameMap[iconName] ?? fallback;
  }
}
