import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../entities/movimientoModel.dart';
import '../repositories/movimientoRepository.dart';
import '../repositories/cuentaRepository.dart';
import '../entities/cuentaModel.dart';
import '../settings/db_conection.dart';
import 'account_form_screen.dart';

class TransactionFormScreen extends StatefulWidget {
  final int userId;
  final String? initialType;
  final Movimientomodel? movement;
  const TransactionFormScreen({super.key, required this.userId, this.initialType, this.movement});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _conceptController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  
  late bool _isGasto;
  DateTime _selectedDate = DateTime.now();

  // Database variables
  final _db = DbConnection();
  final _cuentaRepository = CuentaRepository();
  final _movimientoRepository = MovimientoRepository();

  List<Cuentamodel> _realAccounts = [];
  List<Map<String, dynamic>> _realCategories = [];
  int? _selectedAccountId;
  int? _selectedCategoryId;
  bool _isLoading = true;
  String? _conceptError;

  @override
  void initState() {
    super.initState();
    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        _amountController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _amountController.text.length,
        );
      }
    });

    if (widget.movement != null) {
      final mov = widget.movement!;
      _conceptController.text = mov.descripcion;
      _amountController.text = mov.monto.toStringAsFixed(2);
      _isGasto = mov.tipo == 'gasto';
      _selectedDate = mov.fecha;
      _selectedAccountId = mov.cuentaId;
      _selectedCategoryId = mov.categoriaId;
    } else {
      _isGasto = widget.initialType != 'Ingreso';
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final accounts = await _cuentaRepository.getAll(widget.userId);
      final categoriesResult = await _db.getAll('categorias');

      if (mounted) {
        if (accounts.isEmpty) {
          _showNoAccountDialog();
          return;
        }

        setState(() {
          _realAccounts = accounts;
          _realCategories = categoriesResult;
          _isLoading = false;

          // Set default selected account ID
          if (_selectedAccountId == null && _realAccounts.isNotEmpty) {
            _selectedAccountId = _realAccounts[0].id;
          }

          // Set default category ID based on type
          if (_selectedCategoryId == null) {
            final activeCats = _getActiveCategories();
            if (activeCats.isNotEmpty) {
              _selectedCategoryId = activeCats[0]['id'] as int;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showNoAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppColors.coral, size: 28),
              SizedBox(width: 10),
              Text(
                'Sin cuentas',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Primero debes crear una cuenta antes de registrar una nueva transacción.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => AccountFormScreen(userId: widget.userId),
                  ),
                );
                if (created == true) {
                  _loadData();
                } else {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text(
                'Crear cuenta',
                style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getActiveCategories() {
    final targetType = _isGasto ? 'gasto' : 'ingreso';
    return _realCategories.where((cat) => cat['tipo'] == targetType).toList();
  }

  @override
  void dispose() {
    _conceptController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(DateTime.now()) ? DateTime.now() : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.mint),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.movement != null ? 'Editar transacción' : 'Nueva transacción',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
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
                            focusNode: _amountFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}|^\d*')),
                            ],
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
                            final activeCats = _getActiveCategories();
                            if (activeCats.isNotEmpty) {
                              _selectedCategoryId = activeCats[0]['id'] as int;
                            }
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
                            final activeCats = _getActiveCategories();
                            if (activeCats.isNotEmpty) {
                              _selectedCategoryId = activeCats[0]['id'] as int;
                            }
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
                decoration: InputDecoration(
                  hintText: 'Ej. Supermercado, Salario...',
                  errorText: _conceptError,
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty &&
                        !RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$').hasMatch(value)) {
                      _conceptError = 'El concepto solo puede contener letras.';
                    } else {
                      _conceptError = null;
                    }
                  });
                },
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
                  color: AppColors.cardBg.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedAccountId,
                    hint: Text(
                      _realAccounts.isEmpty ? 'Crea una cuenta primero' : 'Selecciona una cuenta',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                    dropdownColor: AppColors.cardBg,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedAccountId = newValue;
                        });
                      }
                    },
                    items: _realAccounts.map<DropdownMenuItem<int>>((Cuentamodel value) {
                      return DropdownMenuItem<int>(
                        value: value.id,
                        child: Text(value.nombre),
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
                  color: AppColors.cardBg.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedCategoryId,
                    hint: const Text(
                      'Selecciona una categoría',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                    dropdownColor: AppColors.cardBg,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategoryId = newValue;
                        });
                      }
                    },
                    items: _getActiveCategories().map<DropdownMenuItem<int>>((Map<String, dynamic> value) {
                      return DropdownMenuItem<int>(
                        value: value['id'] as int,
                        child: Text(value['nombre'] as String),
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
                    color: AppColors.cardBg.withAlpha(128),
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
                  onPressed: () async {
                    final concept = _conceptController.text.trim();
                    final amountStr = _amountController.text.trim();
                    final amount = double.tryParse(amountStr) ?? 0.0;

                    if (concept.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, ingresa un concepto')),
                      );
                      return;
                    }

                    final conceptRegExp = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$');
                    if (!conceptRegExp.hasMatch(concept)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('El concepto solo puede contener letras.'),
                          backgroundColor: AppColors.coral,
                        ),
                      );
                      return;
                    }

                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
                    if (_selectedDate.isAfter(today)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se permiten fechas posteriores al día actual')),
                      );
                      return;
                    }

                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, ingresa un monto válido mayor a 0')),
                      );
                      return;
                    }

                    if (amount > 999999999.00) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El monto ingresado es demasiado grande (máximo 999,999,999.00)')),
                      );
                      return;
                    }

                    final amountRegExp = RegExp(r'^\d+(\.\d{1,2})?$');
                    if (!amountRegExp.hasMatch(amountStr)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, ingresa un formato de monto válido (Ej. 10.50)')),
                      );
                      return;
                    }

                    if (_selectedAccountId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, selecciona una cuenta')),
                      );
                      return;
                    }

                    if (_selectedCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, selecciona una categoría')),
                      );
                      return;
                    }

                    final selectedAccount = _realAccounts.firstWhere((acc) => acc.id == _selectedAccountId);
                    
                    double availableSaldo = selectedAccount.saldo;
                    if (widget.movement != null && widget.movement!.cuentaId == selectedAccount.id) {
                      if (widget.movement!.tipo == 'gasto') {
                        availableSaldo += widget.movement!.monto;
                      } else {
                        availableSaldo -= widget.movement!.monto;
                      }
                    }

                    if (_isGasto && amount > availableSaldo) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Saldo insuficiente en la cuenta "${selectedAccount.nombre}" '
                            '(Disponible: \$${availableSaldo.toStringAsFixed(2)})'
                          ),
                          backgroundColor: AppColors.coral,
                        ),
                      );
                      return;
                    }

                    try {
                      if (widget.movement == null) {
                        // 1. Create movement
                        final newMovement = Movimientomodel(
                          tipo: _isGasto ? 'gasto' : 'ingreso',
                          monto: amount,
                          descripcion: concept,
                          fecha: _selectedDate,
                          cuentaId: _selectedAccountId!,
                          categoriaId: _selectedCategoryId!,
                        );

                        // 2. Insert to Database
                        await _movimientoRepository.insert(newMovement);

                        // 3. Update Account Balance
                        if (_isGasto) {
                          selectedAccount.saldo -= amount;
                        } else {
                          selectedAccount.saldo += amount;
                        }
                        await _cuentaRepository.update(selectedAccount);
                      } else {
                        final oldMov = widget.movement!;
                        
                        // 1. Revert old balance
                        final oldAccount = _realAccounts.firstWhere((acc) => acc.id == oldMov.cuentaId);
                        if (oldMov.tipo == 'gasto') {
                          oldAccount.saldo += oldMov.monto;
                        } else {
                          oldAccount.saldo -= oldMov.monto;
                        }
                        
                        // Apply new balance to new account
                        final newAccount = _realAccounts.firstWhere((acc) => acc.id == _selectedAccountId);
                        if (_isGasto) {
                          newAccount.saldo -= amount;
                        } else {
                          newAccount.saldo += amount;
                        }

                        // Save accounts
                        await _cuentaRepository.update(oldAccount);
                        if (oldAccount.id != newAccount.id) {
                          await _cuentaRepository.update(newAccount);
                        }

                        // 2. Update movement in DB
                        final updatedMovement = Movimientomodel(
                          id: oldMov.id,
                          tipo: _isGasto ? 'gasto' : 'ingreso',
                          monto: amount,
                          descripcion: concept,
                          fecha: _selectedDate,
                          cuentaId: _selectedAccountId!,
                          categoriaId: _selectedCategoryId!,
                        );
                        await _movimientoRepository.update(updatedMovement);
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(widget.movement != null ? 'Transacción modificada exitosamente' : 'Transacción guardada exitosamente'),
                            backgroundColor: AppColors.mint,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al guardar la transacción: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.movement != null ? 'Guardar cambios' : 'Guardar transacción',
                    style: const TextStyle(
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
