import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'main_navigation_screen.dart';
import '../repositories/usuarioRepository.dart';
import '../entities/usuarioModel.dart';

enum LoginState {
  loginPin,
  onboardingName,
  onboardingPin,
  onboardingConfirmPin,
  onboardingSuccess,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static String userName = 'andres';

  static List<Map<String, String>> mockUsers = [];

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginState _state = LoginState.onboardingName;
  int _selectedUserIndex = 0;
  String _enteredPin = '';
  String? _loginPinError;

  // Onboarding controllers and states
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  final Usuariorepository _usuarioRepository = Usuariorepository();
  List<UsuarioModel> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _usuarioRepository.getAll();
      setState(() {
        _usuarios = users;
        if (_usuarios.isEmpty) {
          _state = LoginState.onboardingName;
        } else {
          _state = LoginState.loginPin;
          _selectedUserIndex = 0;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _state = LoginState.onboardingName;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _resetOnboarding() {
    setState(() {
      _nameController.clear();
      _pinController.clear();
      _confirmPinController.clear();
      _enteredPin = '';
      _loginPinError = null;
      _state = LoginState.onboardingName;
    });
  }

  Future<void> _saveUserAndFinish() async {
    final name = _nameController.text.trim().isEmpty ? 'Andrés' : _nameController.text.trim();
    final pinStr = _pinController.text.isEmpty ? '111111' : _pinController.text;
    final pinInt = int.tryParse(pinStr) ?? 111111;

    final newUser = UsuarioModel(nombre: name, pin: pinInt);
    
    try {
      final insertedId = await _usuarioRepository.insert(newUser);
      LoginScreen.userName = name;
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(userId: insertedId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el usuario: $e')),
        );
      }
    }
  }

  int _getPinStepNum() {
    switch (_state) {
      case LoginState.onboardingName:
        return 1;
      case LoginState.onboardingPin:
        return 2;
      case LoginState.onboardingConfirmPin:
        return 3;
      case LoginState.onboardingSuccess:
        return 4;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.mint,
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and App Name
              _buildHeader(),
              const SizedBox(height: 24),

              // Step Indicator (Only for onboarding)
              if (_state != LoginState.loginPin) ...[
                _buildStepIndicator(_getPinStepNum()),
                const SizedBox(height: 40),
              ],

              // Content based on state
              _buildStateContent(),
              
              const SizedBox(height: 32),
              // Footer
              Center(
                child: Text(
                  'Tus datos se guardan solo en este dispositivo',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.mint.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.trending_up_rounded,
              size: 24,
              color: AppColors.background,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'GastoSmart',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    Widget buildCircle(int stepNum) {
      bool isCompleted = currentStep > stepNum;
      bool isActive = currentStep == stepNum;

      if (isCompleted) {
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.mint,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 16,
            color: AppColors.background,
          ),
        );
      } else if (isActive) {
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.mint, width: 1.5),
          ),
          child: Center(
            child: Text(
              '$stepNum',
              style: const TextStyle(
                color: AppColors.mint,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      } else {
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF131D31),
          ),
          child: Center(
            child: Text(
              '$stepNum',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      }
    }

    Widget buildLine(int fromStep) {
      bool isActiveLine = currentStep > fromStep;
      return Expanded(
        child: Container(
          height: 1.5,
          color: isActiveLine ? AppColors.mint : const Color(0xFF1E293B),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      child: Row(
        children: [
          buildCircle(1),
          buildLine(1),
          buildCircle(2),
          buildLine(2),
          buildCircle(3),
        ],
      ),
    );
  }

  Widget _buildStateContent() {
    switch (_state) {
      case LoginState.loginPin:
        return _buildLoginPinView();
      case LoginState.onboardingName:
        return _buildOnboardingNameView();
      case LoginState.onboardingPin:
        return _buildOnboardingPinView();
      case LoginState.onboardingConfirmPin:
        return _buildOnboardingConfirmPinView();
      case LoginState.onboardingSuccess:
        return _buildOnboardingSuccessView();
    }
  }

  // --- 1. Login por PIN (Usuario Existente con Teclado Numérico) ---
  Widget _buildLoginPinView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        
        // SELECCIONA TU CUENTA Label
        const Center(
          child: Text(
            'SELECCIONA TU CUENTA',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Accounts Row
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_usuarios.length, (index) {
                final user = _usuarios[index];
                final name = user.nombre;
                final isSelected = _selectedUserIndex == index;
                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUserIndex = index;
                      _enteredPin = '';
                      _loginPinError = null;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF0F2B23)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.mint
                                  : AppColors.textSecondary.withOpacity(0.3),
                              width: isSelected ? 2.0 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.mint.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.mint
                                    : AppColors.textSecondary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 36),

        // PIN Label and Dots
        Center(
          child: Text(
            _loginPinError ?? 'Ingresa tu PIN',
            style: TextStyle(
              color: _loginPinError != null ? AppColors.coral : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Dynamic Dots Indicator based on selected user's PIN length
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _usuarios.isNotEmpty && _selectedUserIndex < _usuarios.length
                ? _usuarios[_selectedUserIndex].pin.toString().length
                : 6,
            (index) {
              bool isFilled = _enteredPin.length > index;
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
        const SizedBox(height: 36),

        // Numeric Keypad Grid
        Column(
          children: [
            Row(
              children: [
                _buildKeypadButton('1'),
                const SizedBox(width: 12),
                _buildKeypadButton('2'),
                const SizedBox(width: 12),
                _buildKeypadButton('3'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildKeypadButton('4'),
                const SizedBox(width: 12),
                _buildKeypadButton('5'),
                const SizedBox(width: 12),
                _buildKeypadButton('6'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildKeypadButton('7'),
                const SizedBox(width: 12),
                _buildKeypadButton('8'),
                const SizedBox(width: 12),
                _buildKeypadButton('9'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildEmptyKeypadSpace(),
                const SizedBox(width: 12),
                _buildKeypadButton('0'),
                const SizedBox(width: 12),
                _buildBackspaceButton(),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 32),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 24),

        // Iniciar nueva cuenta Button
        GestureDetector(
          onTap: _resetOnboarding,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBg.withOpacity(0.3),
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_add_outlined,
                      color: AppColors.mint,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Iniciar nueva cuenta',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Registrar otro usuario',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String digit) {
    return Expanded(
      child: InkWell(
        onTap: () => _handleKeypadTap(digit),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Expanded(
      child: InkWell(
        onTap: _handleBackspace,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyKeypadSpace() {
    return const Expanded(
      child: SizedBox(
        height: 64,
      ),
    );
  }

  void _handleKeypadTap(String digit) {
    if (_usuarios.isEmpty) return;
    final selectedUser = _usuarios[_selectedUserIndex];
    final correctPin = selectedUser.pin.toString();
    if (_enteredPin.length >= correctPin.length) return;
    
    setState(() {
      _loginPinError = null;
      _enteredPin += digit;
    });

    // Check if PIN is fully entered
    if (_enteredPin.length == correctPin.length) {
      if (int.tryParse(_enteredPin) == selectedUser.pin) {
        LoginScreen.userName = selectedUser.nombre;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(userId: selectedUser.id!),
          ),
        );
      } else {
        // Clear pin and show error
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            _enteredPin = '';
            _loginPinError = 'PIN incorrecto. Intenta de nuevo.';
          });
        });
      }
    }
  }

  void _handleBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _loginPinError = null;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  // --- 2. Onboarding Paso 1: Nombre ---
  Widget _buildOnboardingNameView() {
    final name = _nameController.text.trim();
    final initialLetter = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '¡Hola! 👋',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '¿Cómo te llamas? Así personalizamos tu experiencia.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 36),
        const Text(
          'TU NOMBRE',
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
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Andrés',
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _nameController.text.isNotEmpty ? AppColors.mint : AppColors.inputBorder,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Live Profile Preview Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBg.withOpacity(0.4),
            border: Border.all(color: AppColors.inputBorder, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2B23),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.mint.withOpacity(0.4), width: 1),
                ),
                child: Center(
                  child: Text(
                    initialLetter,
                    style: const TextStyle(
                      color: AppColors.mint,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Andrés' : name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tu perfil en GastoSmart',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: name.isNotEmpty
                ? () => setState(() => _state = LoginState.onboardingPin)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.background,
              disabledBackgroundColor: AppColors.mint.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continuar ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. Onboarding Paso 2: Crear PIN ---
  Widget _buildOnboardingPinView() {
    final len = _pinController.text.length;
    
    // Compute indicators
    Color bar1 = const Color(0xFF1E293B);
    Color bar2 = const Color(0xFF1E293B);
    Color bar3 = const Color(0xFF1E293B);
    Color bar4 = const Color(0xFF1E293B);
    String strengthText = '';
    Color strengthColor = AppColors.textSecondary;

    if (len > 0 && len < 4) {
      bar1 = AppColors.coral;
      strengthText = 'PIN muy corto';
      strengthColor = AppColors.coral;
    } else if (len == 4) {
      bar1 = const Color(0xFFF1B44C);
      bar2 = const Color(0xFFF1B44C);
      strengthText = 'PIN simple';
      strengthColor = const Color(0xFFF1B44C);
    } else if (len == 5) {
      bar1 = AppColors.mint;
      bar2 = AppColors.mint;
      bar3 = AppColors.mint;
      strengthText = 'PIN seguro';
      strengthColor = AppColors.mint;
    } else if (len >= 6) {
      bar1 = AppColors.mint;
      bar2 = AppColors.mint;
      bar3 = AppColors.mint;
      bar4 = AppColors.mint;
      strengthText = 'PIN seguro ✓';
      strengthColor = AppColors.mint;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Crea tu PIN 🔒🔑',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Este PIN protegerá tu información. Mínimo 4 dígitos.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 36),
        const Text(
          'TU PIN',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _pinController,
          obscureText: _obscurePin,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: AppColors.textPrimary, 
            fontSize: 20,
            letterSpacing: 8,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '••••••',
            hintStyle: const TextStyle(letterSpacing: 8, fontSize: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePin = !_obscurePin;
                });
              },
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _pinController.text.isNotEmpty ? AppColors.mint : AppColors.inputBorder,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Strength bars
        Row(
          children: [
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: bar1, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 6),
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: bar2, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 6),
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: bar3, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 6),
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: bar4, borderRadius: BorderRadius.circular(2)))),
          ],
        ),
        if (strengthText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            strengthText,
            style: TextStyle(
              color: strengthColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        const SizedBox(height: 48),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: len >= 4
                ? () => setState(() => _state = LoginState.onboardingConfirmPin)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.background,
              disabledBackgroundColor: AppColors.mint.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continuar ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 4. Onboarding Paso 3: Confirmar PIN ---
  Widget _buildOnboardingConfirmPinView() {
    final matches = _confirmPinController.text == _pinController.text;
    final len = _confirmPinController.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Confirma tu PIN 🔒',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa el mismo PIN para confirmar.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 36),
        const Text(
          'CONFIRMAR PIN',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _confirmPinController,
          obscureText: _obscureConfirmPin,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: AppColors.textPrimary, 
            fontSize: 20,
            letterSpacing: 8,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '••••••',
            hintStyle: const TextStyle(letterSpacing: 8, fontSize: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPin = !_obscureConfirmPin;
                });
              },
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _confirmPinController.text.isNotEmpty ? AppColors.mint : AppColors.inputBorder,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (len > 0 && !matches) ...[
          const SizedBox(height: 8),
          const Text(
            'Los PINs no coinciden',
            style: TextStyle(color: AppColors.coral, fontSize: 13),
          ),
        ],

        const SizedBox(height: 48),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: (len >= 4 && matches)
                ? () => setState(() => _state = LoginState.onboardingSuccess)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.background,
              disabledBackgroundColor: AppColors.mint.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Crear cuenta ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.check_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _pinController.clear();
              _confirmPinController.clear();
              _state = LoginState.onboardingPin;
            });
          },
          child: const Text(
            'Cambiar PIN',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // --- 5. Onboarding Paso 4: Éxito ---
  Widget _buildOnboardingSuccessView() {
    final name = _nameController.text.trim();
    final initialLetter = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    final pinDigits = _pinController.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF0D251F),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.mint, width: 2),
            ),
            child: Center(
              child: Text(
                initialLetter,
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            '¡Todo listo, $name! 🎉',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tu cuenta está creada y protegida con tu PIN. Empieza a controlar tus finanzas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 36),
        
        // Profile Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TU PERFIL',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nombre',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Seguridad',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  Text(
                    'PIN de $pinDigits dígitos ✓',
                    style: const TextStyle(
                      color: AppColors.mint,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _saveUserAndFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Entrar a GastoSmart ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
