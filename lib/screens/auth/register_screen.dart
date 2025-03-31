import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airline_app/services/auth_service.dart';
import 'package:airline_app/widgets/custom_button.dart';
import 'package:airline_app/widgets/custom_text_field.dart';
import 'package:airline_app/screens/flight/search_screen.dart';
import 'package:airline_app/theme/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      if (_tabController.index == 0) {
        // Register with phone
        await authService.registerWithPhone(
          _nameController.text,
          _phoneController.text,
          _passwordController.text,
        );
      } else {
        // Register with email
        await authService.registerWithEmail(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
      }

      // Navigate to search screen on successful registration
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Реєстрація'),
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Airplane Icon
                const Icon(
                  Icons.airplanemode_active,
                  color: Colors.blue,
                  size: 48,
                ),
                
                const SizedBox(height: 12),
                
                // "Airlines Transportation" Text
                const Text(
                  'Airlines Transportation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Register Form
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
                          Tab(text: 'Реєстрація за телефоном'),
                          Tab(text: 'Реєстрація через пошту'),
                        ],
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: AppTheme.secondaryTextColor,
                        indicatorColor: AppTheme.primaryColor,
                      ),
                      SizedBox(
                        height: 380,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Phone Registration Tab
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: _nameController,
                                    hintText: "Ім'я",
                                    prefixIcon: const Icon(Icons.person),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Введіть ім'я";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
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
                                      if (value.length < 6) {
                                        return 'Пароль повинен містити мінімум 6 символів';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 30),
                                  CustomButton(
                                    text: 'Зареєструватися',
                                    onPressed: _register,
                                    isLoading: _isLoading,
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Вже маєте акаунт? Увійти'),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Email Registration Tab
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: _nameController,
                                    hintText: "Ім'я",
                                    prefixIcon: const Icon(Icons.person),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Введіть ім'я";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
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
                                      if (value.length < 6) {
                                        return 'Пароль повинен містити мінімум 6 символів';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 30),
                                  CustomButton(
                                    text: 'Зареєструватися',
                                    onPressed: _register,
                                    isLoading: _isLoading,
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Вже маєте акаунт? Увійти'),
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
      ),
    );
  }
}
