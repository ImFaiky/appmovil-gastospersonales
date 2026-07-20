import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'carlos@ejemplo.com');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Glowing Logo Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mint.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.trending_up_rounded,
                      size: 40,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // App Name
              const Center(
                child: Text(
                  'GastoSmart',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // App Tagline
              const Center(
                child: Text(
                  'Control de gastos personales',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Welcome Headers
              const Text(
                'Bienvenido',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Inicia sesión para continuar',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 36),

              // Email Input Label
              const Text(
                'CORREO',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              
              // Email Text Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'ejemplo@correo.com',
                ),
              ),
              const SizedBox(height: 24),

              // Password Input Label
              const Text(
                'CONTRASEÑA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              // Password Text Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Iniciar Sesión Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to dashboard
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(),
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
                    'Iniciar sesión',
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
