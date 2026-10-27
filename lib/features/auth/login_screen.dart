
import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../dashboard/admin_dashboard_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final schoolCodeController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  final ApiClient apiClient = ApiClient();
  late final AuthService authService;

  static const primaryColor = Color(0xFF3949AB);

  @override
  void initState() {
    super.initState();
    authService = AuthService(apiClient);
  }

  @override
  void dispose() {
    schoolCodeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    final schoolCode =
        schoolCodeController.text.trim().toUpperCase();
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (schoolCode.isEmpty ||
        username.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter school code, username and password',
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await authService.login(
        schoolCode: schoolCode,
        username: username,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  }

  // void openRegister() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => const RegisterScreen(),
  //     ),
  //   );
  // }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0E5EF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE3E8F2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        size: 34,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'School Admin Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to your school account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 26),

                    TextField(
                      controller: schoolCodeController,
                      enabled: !isLoading,
                      textCapitalization:
                          TextCapitalization.characters,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: inputDecoration(
                        label: 'School Code',
                        icon: Icons.domain_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: usernameController,
                      enabled: !isLoading,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: inputDecoration(
                        label: 'Username',
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordController,
                      enabled: !isLoading,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!isLoading) login();
                      },
                      decoration: inputDecoration(
                        label: 'Password',
                        icon: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          tooltip: obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : openForgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 49,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  //   Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       const Flexible(
                  //         child: Text(
                  //           "Don't have an account?",
                  //           style: TextStyle(
                  //             fontSize: 13,
                  //             color: Colors.blueGrey,
                  //           ),
                  //         ),
                  //       ),
                  //       // TextButton(
                  //       //   onPressed:
                  //       //       isLoading ? null : openRegister,
                  //       //   child: const Text(
                  //       //     'Register',
                  //       //     style: TextStyle(
                  //       //       fontWeight: FontWeight.bold,
                  //       //       color: primaryColor,
                  //       //     ),
                  //       //   ),
                  //       // ),
                  //     ],
                  //   ),
                   ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
