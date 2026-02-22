import 'package:flutter/material.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/shake_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _shakeTrigger = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeTrigger.dispose();
    super.dispose();
  }

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
      body: Stack(
        children: [
          Center(
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
          Positioned(
            top: 16,
            left: 16,
            child: BackButton(
              color: isDark ? Colors.white : Colors.black,
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
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
    final t = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.translate('welcome_back'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            t.translate('sign_in_continue'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 48),

          // Inputs
          ShakeWidget(
            shakeTrigger: _shakeTrigger,
            child: Column(
              children: [
                CustomTextField(
                  controller: _emailController,
                  label: t.translate('email'),
                  hint: t.translate('enter_email'),
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\x00-\x7F]')),
                  ],
                  validator: (value) => value!.isEmpty ? t.translate('enter_email_validation') : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: t.translate('password'),
                  hint: t.translate('enter_password'),
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\x00-\x7F]')),
                  ],
                  validator: (value) => value!.isEmpty ? t.translate('enter_password_validation') : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          PrimaryButton(
            text: t.translate('login'),
            isLoading: authProvider.isLoading,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await authProvider.login(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (context.mounted) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      // If root (e.g. from session expired or logout), go to Profile (Index 2)
                      Navigator.pushReplacementNamed(context, '/home', arguments: 2);
                    }
                  }
                } catch (e) {
                     if (context.mounted) {
                       _shakeTrigger.value = true;
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
                } else {
                  _shakeTrigger.value = true;
                }
              },
          ),
          const SizedBox(height: 24),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.translate('no_account'),
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  t.translate('create_account'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "v1.0.2 (Cache Check)", 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
