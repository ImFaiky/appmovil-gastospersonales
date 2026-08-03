import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../entities/usuarioModel.dart';
import '../repositories/usuarioRepository.dart';
import '../settings/db_conection.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class PerfilScreen extends StatefulWidget {
  final int userId;
  const PerfilScreen({super.key, required this.userId});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _repository = Usuariorepository();
  final _db = DbConnection();

  // Controllers for editing current user
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  bool _obscurePin = true;

  // Controllers for creating a new user
  final _newNameController = TextEditingController();
  final _newPinController = TextEditingController();
  bool _newObscurePin = true;
  String? _newPinError;
  String? _pinError;

  UsuarioModel? _currentUser;
  List<UsuarioModel> _allUsers = [];
  bool _isLoading = true;

  final Map<int, int> _failedPinAttemptsMap = {};
  final Map<int, int> _lockoutSecondsMap = {};
  final Map<int, Timer?> _lockoutTimersMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (var timer in _lockoutTimersMap.values) {
      timer?.cancel();
    }
    _nameController.dispose();
    _pinController.dispose();
    _newNameController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _repository.getById(widget.userId);
      final users = await _repository.getAll();

      if (user != null) {
        _nameController.text = user.nombre;
        _pinController.text = user.pin;
      }

      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _allUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar perfiles: $e')),
      );
    }
  }

  Future<void> _actualizarPerfil() async {
    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }

    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre solo puede contener letras.'),
          backgroundColor: AppColors.coral,
        ),
      );
      return;
    }

    if (pin.isEmpty || int.tryParse(pin) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PIN debe ser un código numérico')),
      );
      return;
    }

    if (pin.length < 6 || pin.length > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PIN debe tener entre 6 y 8 dígitos.')),
      );
      return;
    }

    if (_currentUser == null) return;

    try {
      _currentUser!.nombre = name;
      _currentUser!.pin = pin;

      await _repository.update(_currentUser!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppColors.mint,
        ),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar perfil: $e')),
      );
    }
  }

  Future<void> _crearNuevoUsuario() async {
    final name = _newNameController.text.trim();
    final pin = _newPinController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un nombre')),
      );
      return;
    }

    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre solo puede contener letras.'),
          backgroundColor: AppColors.coral,
        ),
      );
      return;
    }

    if (pin.isEmpty || int.tryParse(pin) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PIN debe ser numérico')),
      );
      return;
    }

    if (pin.length < 6 || pin.length > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PIN debe tener entre 6 y 8 dígitos.')),
      );
      return;
    }

    try {
      final newUser = UsuarioModel(nombre: name, pin: pin);
      await _repository.insert(newUser);

      _newNameController.clear();
      _newPinController.clear();

      if (!mounted) return;
      Navigator.of(context).pop(); // Close creation modal/dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario creado exitosamente'),
          backgroundColor: AppColors.mint,
        ),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear usuario: $e')),
      );
    }
  }

  Future<bool> _showSecurityPinDialog({
    required String title,
    required String message,
    required String expectedPin,
    required int targetUserId,
    required String accountName,
  }) async {
    final pinController = TextEditingController();
    final focusNode = FocusNode();
    String enteredPin = '';
    String? errorMessage;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            
            void startLockoutTimer() {
              _lockoutTimersMap[targetUserId]?.cancel();
              _lockoutTimersMap[targetUserId] = Timer.periodic(const Duration(seconds: 1), (timer) {
                if (mounted) {
                  setDialogState(() {
                    final remaining = _lockoutSecondsMap[targetUserId] ?? 0;
                    if (remaining > 1) {
                      _lockoutSecondsMap[targetUserId] = remaining - 1;
                    } else {
                      _lockoutSecondsMap[targetUserId] = 0;
                      _failedPinAttemptsMap[targetUserId] = 0;
                      _lockoutTimersMap[targetUserId]?.cancel();
                      focusNode.requestFocus();
                    }
                  });
                } else {
                  timer.cancel();
                }
              });
            }

            final userLockout = _lockoutSecondsMap[targetUserId] ?? 0;
            if (userLockout > 0 && _lockoutTimersMap[targetUserId] == null) {
              startLockoutTimer();
            }

            final isLockedOut = userLockout > 0;

            return AlertDialog(
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border, width: 1),
              ),
              title: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: AppColors.coral, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    message,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Account name being changed / deleted
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.mint.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.mint.withOpacity(0.2),
                          child: Text(
                            accountName.isNotEmpty ? accountName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: AppColors.mint,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            accountName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      isLockedOut
                          ? 'Bloqueado. Espera ${(_lockoutSecondsMap[targetUserId] ?? 0)} segundos.'
                          : (errorMessage ?? 'Ingresa el PIN'),
                      style: TextStyle(
                        color: (isLockedOut || errorMessage != null) ? AppColors.coral : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Circles Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      expectedPin.length,
                      (index) {
                        bool isFilled = enteredPin.length > index;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled ? AppColors.mint : Colors.transparent,
                            border: Border.all(
                              color: isFilled
                                  ? AppColors.mint
                                  : AppColors.textSecondary.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Hidden TextField
                  Opacity(
                    opacity: 0.0,
                    child: SizedBox(
                      height: 1,
                      width: 1,
                      child: TextField(
                        controller: pinController,
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        enabled: !isLockedOut,
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(expectedPin.length),
                        ],
                        onChanged: (val) {
                          setDialogState(() {
                            enteredPin = val;
                          });

                          if (val.length == expectedPin.length) {
                            if (val == expectedPin) {
                              _failedPinAttemptsMap[targetUserId] = 0;
                              _lockoutSecondsMap[targetUserId] = 0;
                              _lockoutTimersMap[targetUserId]?.cancel();
                              focusNode.unfocus();
                              Navigator.of(context).pop(true);
                            } else {
                              Future.delayed(const Duration(milliseconds: 200), () {
                                if (context.mounted) {
                                  setDialogState(() {
                                    pinController.clear();
                                    enteredPin = '';
                                    final attempts = (_failedPinAttemptsMap[targetUserId] ?? 0) + 1;
                                    _failedPinAttemptsMap[targetUserId] = attempts;
                                    if (attempts >= 3) {
                                      _lockoutSecondsMap[targetUserId] = 30;
                                      errorMessage = 'Demasiados intentos. Espera 30 s.';
                                      focusNode.unfocus();
                                      startLockoutTimer();
                                    } else {
                                      errorMessage = 'PIN incorrecto. Intento $attempts de 3';
                                    }
                                  });
                                }
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    focusNode.unfocus();
                    Navigator.of(context).pop(false);
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // Stop any pending lockout timer tied to this dialog and release the
    // controller/focus node after the current frame, so the dialog can finish
    // tearing down before disposal (avoids '_dependents.isEmpty' assertions).
    _lockoutTimersMap[targetUserId]?.cancel();
    _lockoutTimersMap[targetUserId] = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pinController.dispose();
      focusNode.dispose();
    });
    return result ?? false;
  }

  Future<void> _borrarUsuarioCascade(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Confirmar eliminación',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar al usuario "$name"? Esta acción es irreversible y borrará permanentemente sus cuentas y transacciones asociadas.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar Todo', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    
    // Give confirmation dialog pop transition time to finish cleanly
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // Require the PIN of the account being deleted (consistent with switch).
    final targetUser = _allUsers.firstWhere(
      (u) => u.id == id,
      orElse: () => _currentUser!,
    );

    final pinConfirmed = await _showSecurityPinDialog(
      title: 'Confirmar con PIN',
      message: 'Ingresa el PIN de seguridad de esta cuenta para confirmar y autorizar la eliminación.',
      expectedPin: targetUser.pin,
      targetUserId: id,
      accountName: name,
    );
    if (!pinConfirmed || !mounted) return;

    // Save navigator and scaffold messenger references BEFORE async work
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Cascade delete accounts and movements
      final database = await _db.database;
      final accounts = await database.query('cuentas', where: 'usuarioId = ?', whereArgs: [id]);
      for (var acc in accounts) {
        final accId = acc['id'] as int;
        await database.delete('movimientos', where: 'cuentaId = ?', whereArgs: [accId]);
      }
      await database.delete('cuentas', where: 'usuarioId = ?', whereArgs: [id]);
      
      // Delete user record
      await _repository.delete(id);

      if (!mounted) return;

      if (id == widget.userId) {
        // Deleted current user, navigate to login.
        // Drop keyboard focus and defer navigation to the next frame so the
        // PIN dialog/keyboard finish tearing down before rebuilding the tree.
        FocusManager.instance.primaryFocus?.unfocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        });
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Usuario "$name" y sus datos eliminados'),
            backgroundColor: AppColors.coral,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al eliminar usuario: $e')),
      );
    }
  }

  Future<void> _switchUser(UsuarioModel user) async {
    if (user.id == widget.userId) return;
    
    final pinConfirmed = await _showSecurityPinDialog(
      title: 'Cambiar de Cuenta',
      message: 'Ingresa el PIN de seguridad de esta cuenta para acceder a ella.',
      expectedPin: user.pin,
      targetUserId: user.id!,
      accountName: user.nombre,
    );

    if (!pinConfirmed || !mounted) return;

    // Save navigator reference before using it
    final navigator = Navigator.of(context);

    // Drop keyboard focus and defer navigation to the next frame so the PIN
    // dialog/keyboard finish tearing down before we rebuild the whole tree.
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainNavigationScreen(userId: user.id!)),
        (route) => false,
      );
    });
  }

  void _showAddUserDialog() {
    _newNameController.clear();
    _newPinController.clear();
    _newObscurePin = true;
    _newPinError = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Nuevo Usuario',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _newNameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintText: 'Ej. María Pérez',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newPinController,
                      obscureText: _newObscurePin,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(8),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          if (value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
                            _newPinError = 'El PIN solo acepta números, no letras';
                          } else {
                            _newPinError = null;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'PIN de Seguridad',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        hintText: 'Debe tener entre 6 y 8 dígitos',
                        errorText: _newPinError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _newObscurePin ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              _newObscurePin = !_newObscurePin;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: _crearNuevoUsuario,
                  child: const Text('Crear', style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter out the active user from the listed others
    final otherUsers = _allUsers.where((u) => u.id != widget.userId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil de Usuario',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(true), // return true to reload previous screens
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.mint))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: Edit active profile
                    const Text(
                      'DATOS DE PERFIL',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          // User Avatar circle
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.mint.withOpacity(0.15),
                            child: Text(
                              _currentUser != null && _currentUser!.nombre.isNotEmpty
                                  ? _currentUser!.nombre[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: AppColors.mint,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Nombre Completo',
                              labelStyle: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _pinController,
                            obscureText: _obscurePin,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppColors.textPrimary),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(8),
                            ],
                            onChanged: (value) {
                              setState(() {
                                if (value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
                                  _pinError = 'El PIN solo acepta números, no letras';
                                } else {
                                  _pinError = null;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'PIN de Seguridad',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              helperText: 'Debe contener entre 6 y 8 números',
                              errorText: _pinError,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePin ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePin = !_obscurePin;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _actualizarPerfil,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mint,
                                foregroundColor: AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Guardar Cambios',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Option to self-delete profile
                          TextButton.icon(
                            onPressed: () => _currentUser != null 
                                ? _borrarUsuarioCascade(_currentUser!.id!, _currentUser!.nombre) 
                                : null,
                            icon: const Icon(Icons.delete_forever_rounded, color: AppColors.coral, size: 18),
                            label: const Text(
                              'Eliminar mi cuenta permanentemente',
                              style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Section 2: Manage other profiles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'OTROS USUARIOS',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showAddUserDialog,
                          child: const Row(
                            children: [
                              Icon(Icons.add_circle_outline_rounded, color: AppColors.mint, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Nuevo',
                                style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    otherUsers.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border.withOpacity(0.5)),
                            ),
                            child: const Center(
                              child: Text(
                                'No hay otros usuarios registrados.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: otherUsers.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final u = otherUsers[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.textSecondary.withOpacity(0.15),
                                      child: Text(
                                        u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : 'U',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            u.nombre,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Toca para cambiar de cuenta',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Switch User button
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.mint, size: 16),
                                      onPressed: () => _switchUser(u),
                                      tooltip: 'Iniciar sesión con esta cuenta',
                                    ),
                                    // Delete user button
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral, size: 20),
                                      onPressed: () => _borrarUsuarioCascade(u.id!, u.nombre),
                                      tooltip: 'Eliminar este usuario',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}
