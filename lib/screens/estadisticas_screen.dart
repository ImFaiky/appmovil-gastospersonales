import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../theme/app_colors.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  String _activeTab = 'Mensual'; // 'Mensual', 'Categorías', 'Tendencia'

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 24),

              // KPI Row: Ingresos, Gastos, Ahorro
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      label: 'Ingresos',
                      value: '\$23,700',
                      valueColor: AppColors.mint,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiCard(
                      label: 'Gastos',
                      value: '\$13,199',
                      valueColor: AppColors.coral,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiCard(
                      label: 'Ahorro',
                      value: '\$10,501',
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

  Widget _buildTabButton(String tabName) {
    bool isActive = _activeTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = tabName;
          });
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
                  children: const [
                    Text('\$24k', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Text('\$18k', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Text('\$12k', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Text('\$6k', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Text('\$0k', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  ],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildMonthDoubleBar('Feb', 0, 0),
                          _buildMonthDoubleBar('Mar', 0, 0),
                          _buildMonthDoubleBar('Abr', 0, 0),
                          _buildMonthDoubleBar('May', 0.12, 0.02),
                          _buildMonthDoubleBar('Jun', 0.94, 0.46),
                          _buildMonthDoubleBar('Jul', 0.98, 0.55),
                        ],
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

  // --- TAB 2: CATEGORÍAS ---
  Widget _buildCategoriasView() {
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
          const Text(
            'Gastos por categoría',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Doughnut Ring Chart Center Render
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: DoughnutChartPainter(
                  sections: [
                    DoughnutSection(percentage: 0.39, color: const Color(0xFFFB923C)), // Vivienda
                    DoughnutSection(percentage: 0.16, color: const Color(0xFF34D399)), // Alimentación
                    DoughnutSection(percentage: 0.11, color: const Color(0xFFFBBF24)), // Entretenimiento
                    DoughnutSection(percentage: 0.11, color: const Color(0xFFF87171)), // Salud
                    DoughnutSection(percentage: 0.09, color: const Color(0xFF22D3EE)), // Servicios
                    DoughnutSection(percentage: 0.08, color: const Color(0xFFC084FC)), // Ropa
                    DoughnutSection(percentage: 0.06, color: const Color(0xFF60A5FA)), // Educación
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Detailed breakdown Category List
          _buildCategoryBreakdownRow(
            icon: Icons.home_rounded,
            iconColor: const Color(0xFFFB923C),
            name: 'Vivienda',
            percent: '39%',
            amount: '\$9,000',
          ),
          _buildCategoryBreakdownRow(
            icon: Icons.shopping_cart_rounded,
            iconColor: const Color(0xFF34D399),
            name: 'Alimentación',
            percent: '16%',
            amount: '\$3,720',
          ),
          _buildCategoryBreakdownRow(
            icon: Icons.movie_creation_rounded,
            iconColor: const Color(0xFFFBBF24),
            name: 'Entretenimiento',
            percent: '11%',
            amount: '\$2,599',
          ),
          _buildCategoryBreakdownRow(
            icon: Icons.medical_services_rounded,
            iconColor: const Color(0xFFF87171),
            name: 'Salud',
            percent: '11%',
            amount: '\$2,480',
          ),
          _buildCategoryBreakdownRow(
            icon: Icons.lightbulb_rounded,
            iconColor: const Color(0xFF22D3EE),
            name: 'Servicios',
            percent: '9%',
            amount: '\$2,040',
          ),
          _buildCategoryBreakdownRow(
            icon: Icons.checkroom_rounded,
            iconColor: const Color(0xFFC084FC),
            name: 'Ropa',
            percent: '8%',
            amount: '\$1,770',
          ),
          _buildCategoryBreakdownRow(
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFF60A5FA),
            name: 'Educación',
            percent: '6%',
            amount: '\$1,500',
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
                widthFactor: barRatio,
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
                  children: const [
                    Text('\$24k', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Text('\$18k', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Text('\$12k', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Text('\$6k', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Text('\$0k', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  ],
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
                      Positioned.fill(
                        child: CustomPaint(
                          painter: TrendLinePainter(
                            ingresosPoints: [0.0, 0.0, 0.0, 0.12, 0.94, 0.98],
                            gastosPoints: [0.0, 0.0, 0.0, 0.02, 0.46, 0.55],
                            ahorroPoints: [0.0, 0.0, 0.0, 0.10, 0.48, 0.43],
                          ),
                        ),
                      ),
                      // Bottom X labels positioned overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Feb', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                            Text('Mar', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                            Text('Abr', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                            Text('May', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                            Text('Jun', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                            Text('Jul', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                          ],
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
      ..strokeCap = StrokeCap.square; // Straight caps for gaps

    for (var section in sections) {
      if (section.percentage == 0) continue;
      
      final sweepAngle = (section.percentage * 2 * math.pi) - gapAngle;
      paint.color = section.color;
      
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      final double y = height - (ratios[i] * (height - 10)) - 5;
      points.add(Offset(x, y));
    }

    // Draw smooth bezier line or segment path
    final Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 0; i < count - 1; i++) {
      // Bezier curve interpolation points
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
      // Draw dashed path using path metrics
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
      // Outer border circle
      canvas.drawCircle(point, 5, dotPaint);
      canvas.drawCircle(point, 2.5, outerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
