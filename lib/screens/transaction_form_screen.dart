import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TransactionFormScreen extends StatefulWidget {
  final String? initialType;
  const TransactionFormScreen({super.key, this.initialType});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _conceptController = TextEditingController();
  final _amountController = TextEditingController(text: '0.00');
  
  late bool _isGasto;
  String _selectedAccount = 'Efectivo';
  String _selectedCategory = 'Alimentación';
  DateTime _selectedDate = DateTime.now();

  final List<String> _accounts = ['Efectivo', 'Banco BBVA', 'Tarjeta Visa'];
  
  final List<String> _gastosCategories = [
    'Alimentación',
    'Transporte',
    'Salud',
    'Educación',
    'Entretenimiento',
    'Vivienda',
    'Ropa',
    'Servicios',
    'Otros'
  ];

  final List<String> _ingresosCategories = [
    'Salario',
    'Freelance',
    'Inversiones',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    _isGasto = widget.initialType != 'Ingreso';
    _selectedCategory = _isGasto ? _gastosCategories[0] : _ingresosCategories[0];
  }

  @override
  void dispose() {
    _conceptController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> activeCategories = _isGasto ? _gastosCategories : _ingresosCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva transacción',
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Large Digital Amount Input
              Center(
                child: Column(
                  children: [
                    const Text(
                      'MONTO',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '\$',
                          style: TextStyle(
                            color: AppColors.mint,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(color: AppColors.textSecondary),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                              filled: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Segmented Toggle (Gasto / Ingreso)
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
                            _selectedCategory = _gastosCategories[0];
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
                            _selectedCategory = _ingresosCategories[0];
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

              // Concepto Field
              const Text(
                'CONCEPTO',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _conceptController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Ej. Supermercado, Salario...',
                ),
              ),
              const SizedBox(height: 24),

              // Cuenta Selector Dropdown
              const Text(
                'CUENTA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedAccount,
                    dropdownColor: AppColors.cardBg,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedAccount = newValue;
                        });
                      }
                    },
                    items: _accounts.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Categoría Selector Dropdown
              const Text(
                'CATEGORÍA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: AppColors.cardBg,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                    items: activeCategories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Date Picker Field
              const Text(
                'FECHA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.inputBorder, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Action button: Guardar transacción
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transacción guardada exitosamente'),
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
                    'Guardar transacción',
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
