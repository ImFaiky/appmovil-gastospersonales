import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'inicio_screen.dart';
import 'movimientos_screen.dart';
import 'cuentas_screen.dart';
import 'categorias_screen.dart';
import 'estadisticas_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int userId;
  const MainNavigationScreen({super.key, required this.userId});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  List<Widget> _getScreens() {
    return [
      InicioScreen(
        userId: widget.userId,
        onTabSelected: _onItemTapped,
        isActive: _selectedIndex == 0,
      ),
      MovimientosScreen(
        userId: widget.userId,
        isActive: _selectedIndex == 1,
      ),
      CuentasScreen(
        userId: widget.userId,
        isActive: _selectedIndex == 2,
      ),
      CategoriasScreen(
        userId: widget.userId,
        isActive: _selectedIndex == 3,
      ),
      EstadisticasScreen(
        userId: widget.userId,
        isActive: _selectedIndex == 4,
      ),
    ];
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _getScreens(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: AppColors.bottomNavBg,
          selectedItemColor: AppColors.mint,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.mint,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.grid_view_rounded, size: 24),
              ),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.swap_horiz_rounded, size: 24),
              ),
              label: 'Movimientos',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.credit_card_rounded, size: 24),
              ),
              label: 'Cuentas',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.local_offer_outlined, size: 24),
              ),
              label: 'Categorías',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.bar_chart_rounded, size: 24),
              ),
              label: 'Estadísticas',
            ),
          ],
        ),
      ),
    );
  }
}
