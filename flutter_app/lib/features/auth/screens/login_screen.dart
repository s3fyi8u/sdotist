import 'package:flutter/material.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileScaffold: _buildMobileScaffold(context),
      tabletScaffold: _buildDesktopScaffold(context),
      desktopScaffold: _buildDesktopScaffold(context),
    );
  }

  Widget _buildDesktopScaffold(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Brand for Desktop
               Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 50,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'sdotist',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Container(
                  width: 450,
                  padding: const EdgeInsets.all(40),
                  child: _buildLoginForm(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Hero(
                tag: 'app_logo',
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              _buildLoginForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome Back!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please sign in to continue',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 48),

          // Inputs
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value!.isEmpty ? 'Enter email' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (value) => value!.isEmpty ? 'Enter password' : null,
          ),
          const SizedBox(height: 24),

          // Action Button
          PrimaryButton(
            text: 'Login',
            isLoading: authProvider.isLoading,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await authProvider.login(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                   if (context.mounted) {
                     final error = ErrorMapper.map(e);
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Row(
                           children: [
                             const Icon(Icons.error_outline, color: Colors.white),
                             const SizedBox(width: 8),
                             Expanded(child: Text(error.message)),
                           ],
                         ),
                         backgroundColor: Colors.red,
                         behavior: SnackBarBehavior.floating,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                       ),
                     );
                   }
                }
              }
            },
          ),
          const SizedBox(height: 24),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
