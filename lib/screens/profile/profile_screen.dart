import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airline_app/services/auth_service.dart';
import 'package:airline_app/widgets/custom_text_field.dart';
import 'package:airline_app/widgets/custom_button.dart';
import 'package:airline_app/screens/auth/login_screen.dart';
import 'package:airline_app/theme/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;
  String _selectedLanguage = 'Укр';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    if (user != null) {
      _nameController.text = user.fullName;
      _contactController.text = 'Контактна інформація';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.contactNumber ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you'd update the user profile here
      await Future.delayed(const Duration(seconds: 1));
      
      Fluttertoast.showToast(
        msg: 'Профіль успішно оновлено',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Помилка оновлення профілю: ${e.toString()}',
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

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.logout();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Помилка виходу: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Профіль'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    const Text(
                      'Основная информация',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Full name
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'ФИО',
                      readOnly: !_isEditing,
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Введіть ваше ім'я";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Contact information
                    CustomTextField(
                      controller: _contactController,
                      hintText: 'Контактные данные',
                      readOnly: !_isEditing,
                      prefixIcon: const Icon(Icons.contact_page),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введіть контактні дані';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Contact details section
                    const Text(
                      'Изменение email',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      readOnly: !_isEditing,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введіть email';
                        }
                        if (!value.contains('@')) {
                          return 'Введіть коректний email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone field
                    const Text(
                      'Изменение номера телефона',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _phoneController,
                      hintText: 'Номер телефона',
                      readOnly: !_isEditing,
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
                    
                    // Password change section
                    const Text(
                      'Смена пароля',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Новый пароль',
                      obscureText: true,
                      readOnly: !_isEditing,
                      prefixIcon: const Icon(Icons.lock),
                      validator: _isEditing
                          ? (value) {
                              if (value != null && value.isNotEmpty && value.length < 6) {
                                return 'Пароль має містити мінімум 6 символів';
                              }
                              return null;
                            }
                          : null,
                    ),
                    const SizedBox(height: 24),
                    
                    // Language selection
                    Row(
                      children: [
                        const Icon(Icons.language, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Мова інтерфейсу',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedLanguage,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Switch(
                                value: _selectedLanguage == 'Укр',
                                onChanged: _isEditing
                                    ? (value) {
                                        setState(() {
                                          _selectedLanguage = value ? 'Укр' : 'Eng';
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Logout button
                    CustomButton(
                      text: 'Вийти з акаунту',
                      onPressed: _logout,
                      isLoading: _isLoading,
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
