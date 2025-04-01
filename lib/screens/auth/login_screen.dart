import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airline_app/services/auth_service.dart';
import 'package:airline_app/widgets/custom_button.dart';
import 'package:airline_app/widgets/custom_text_field.dart';
import 'package:airline_app/screens/auth/register_screen.dart';
import 'package:airline_app/screens/flight/search_screen.dart';
import 'package:airline_app/theme/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      if (_tabController.index == 0) {
        // Login with phone
        await authService.loginWithPhone(
          _phoneController.text,
          _passwordController.text,
        );
      } else {
        // Login with email
        await authService.loginWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      }

      // Navigate to search screen on successful login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Airplane Icon
                      const Icon(
                        Icons.airplanemode_active,
                        color: Colors.blue,
                        size: 64,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // "Airlines Transportation" Text
                      const Text(
                        'Airlines\nTransportation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Login Tabs
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            TabBar(
                              controller: _tabController,
                              tabs: const [
                                Tab(text: 'Вхід за номером телефону'),
                                Tab(text: 'Вхід через пошту'),
                              ],
                              labelColor: AppTheme.primaryColor,
                              unselectedLabelColor: AppTheme.secondaryTextColor,
                              indicatorColor: AppTheme.primaryColor,
                            ),
                            SizedBox(
                              height: 300,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Phone Login Tab
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        CustomTextField(
                                          controller: _phoneController,
                                          hintText: 'Номер телефону',
                                          keyboardType: TextInputType.phone,
                                          prefixIcon: const Icon(Icons.phone),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Введіть номер телефону';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          controller: _passwordController,
                                          hintText: 'Пароль',
                                          obscureText: true,
                                          prefixIcon: const Icon(Icons.key),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Введіть пароль';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        CustomButton(
                                          text: 'Вход',
                                          onPressed: _login,
                                          isLoading: _isLoading,
                                        ),
                                        const SizedBox(height: 10),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const RegisterScreen(),
                                              ),
                                            );
                                          },
                                          child: const Text('Новий користувач'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Email Login Tab
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        CustomTextField(
                                          controller: _emailController,
                                          hintText: 'Email',
                                          keyboardType: TextInputType.emailAddress,
                                          prefixIcon: const Icon(Icons.email),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Введіть email';
                                            }
                                            if (!value.contains('@')) {
                                              return 'Невірний формат email';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          controller: _passwordController,
                                          hintText: 'Пароль',
                                          obscureText: true,
                                          prefixIcon: const Icon(Icons.key),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Введіть пароль';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        CustomButton(
                                          text: 'Вход',
                                          onPressed: _login,
                                          isLoading: _isLoading,
                                        ),
                                        const SizedBox(height: 10),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const RegisterScreen(),
                                              ),
                                            );
                                          },
                                          child: const Text('Новий користувач'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
