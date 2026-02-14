import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/searchable_dropdown.dart'; // Import


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateController = TextEditingController();
  // final _universityController = TextEditingController(); // Removed
  final _specializationController = TextEditingController();
  final _academicYearController = TextEditingController();
  
  String? _selectedUniversity;
  String? _selectedDegree;
  String? _emailError; // Added state for email error

  final List<String> _degrees = [
    'Diploma',
    'Bachelor',
    'Master',
    'Doctorate',
  ];

  final List<String> _academicYears = ['1', '2', '3', '4', '5'];
  String? _selectedAcademicYear;

  final List<String> _universities = [
    'Istanbul University',
    'Istanbul Technical University',
    'Bogazici University',
    'Marmara University',
    'Yildiz Technical University',
    'Mimar Sinan Fine Arts University',
    'Istanbul Medeniyet University',
    'Istanbul University Cerrahpasa',
    'Turkish German University',
    'National Defense University Turkey',
    'Health Sciences University Turkey',
    'Galatasaray University',
    'Istanbul Sabahattin Zaim University',
    'Koc University',
    'Sabanci University',
    'Yeditepe University',
    'Bahcesehir University',
    'Istanbul Bilgi University',
    'Istanbul Aydin University',
    'Istanbul Medipol University',
    'Istinye University',
    'Acibadem University',
    'Altinbas University',
    'Beykent University',
    'Beykoz University',
    'Biruni University',
    'Fenerbahce University',
    'Haliç University',
    'Istanbul Arel University',
    'Istanbul Atlas University',
    'Istanbul Esenyurt University',
    'Istanbul Gelisim University',
    'Istanbul Kent University',
    'Istanbul Kultur University',
    'Istanbul Okan University',
    'Istanbul Rumeli University',
    'Istanbul Ticaret University',
    'Kadir Has University',
    'Maltepe University',
    'Nisantasi University',
    'Ozyegin University',
    'Piri Reis University',
    'Uskudar University',
    'Ibn Haldun University',
  ];

  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (_emailError != null) {
        setState(() {
          _emailError = null;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Colors.white, // Header background color
                    onPrimary: Colors.black, // Header text color
                    surface: Color(0xFF1E1E1E), // Background color
                    onSurface: Colors.white, // Text color
                  )
                : const ColorScheme.light(
                    primary: Colors.black, // Header background color
                    onPrimary: Colors.white, // Header text color
                    surface: Colors.white, // Background color
                    onSurface: Colors.black, // Text color
                  ),
            dialogBackgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white : Colors.black, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Image Picker
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                          child: _imageFile == null
                              ? Icon(Icons.person_outline, size: 60, color: isDark ? Colors.white54 : Colors.grey)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Personal Info
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter full name';
                    final words = value.trim().split(RegExp(r'\s+'));
                    if (words.length < 3) return 'Enter full name (at least 3 words)';

                    return null;
                  },

                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (_emailError != null) return _emailError;
                    if (value == null || value.isEmpty) return 'Enter email';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                

                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _dateController,
                  label: 'Date of Birth',
                  prefixIcon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) => value!.isEmpty ? 'Select date of birth' : null,
                ),
                const SizedBox(height: 32),

                // Academic Info
                Text(
                  'Academic Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // University Searchable Dropdown
                SearchableDropdown(
                  value: _selectedUniversity,
                  items: _universities,
                  label: 'University',
                  onChanged: (newValue) {
                    setState(() {
                      _selectedUniversity = newValue;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Select university' : null,
                ),

                const SizedBox(height: 16),
                
                // Degree Dropdown
                SearchableDropdown(
                  value: _selectedDegree,
                  items: _degrees,
                  label: 'Degree',
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDegree = newValue;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Select degree' : null,
                ),

                const SizedBox(height: 16),
                // Academic Year Dropdown
                SearchableDropdown(
                  value: _selectedAcademicYear,
                  items: _academicYears,
                  label: 'Academic Year',
                  onChanged: (newValue) {
                    setState(() {
                      _selectedAcademicYear = newValue;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Select year' : null,
                ),

                const SizedBox(height: 16),
                CustomTextField(
                  controller: _specializationController,
                  label: 'Specialization',
                  prefixIcon: Icons.book_outlined,
                ),
                const SizedBox(height: 48),

                // Action Button
                PrimaryButton(
                  text: 'Register',
                  isLoading: authProvider.isLoading,
                  onPressed: () async {
                    print("Register button pressed");
                    if (_formKey.currentState!.validate()) {
                      print("Form is valid");
                      try {
                        await authProvider.register(
                          name: _nameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          dateOfBirth: _dateController.text,
                          university: _selectedUniversity!, // Use selected university
                          degree: _selectedDegree,
                          specialization: _specializationController.text,
                          academicYear: _selectedAcademicYear,
                          profileImagePath: _imageFile?.path,
                        );
                        
                        // Auto Login after registration
                        await authProvider.login(
                          _emailController.text,
                          _passwordController.text,
                        );

                          if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registration successful!')),
                          );
                          
                          // Pop until we are back to the main screen (Profile or Home)
                           Navigator.popUntil(context, (route) {
                              return route.settings.name != '/login' && route.settings.name != '/register';
                           });
                        }
                      } on DioException catch (e) {
                         print("DioException caught in RegisterScreen: ${e.response?.data}");
                         String errorMessage = 'Registration failed';
                         if (e.response?.data != null) {
                           if (e.response!.data is List) {
                             // Handle FastAPI validation errors (List)
                             final list = e.response!.data as List;
                             errorMessage = list.map((item) => item['msg'].toString()).join('\n');
                           } else if (e.response!.data is Map) {
                             // Handle standard errors (Map)
                             errorMessage = e.response!.data['detail']?.toString() ?? e.message ?? 'Unknown error';
                           }
                         }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('An error occurred: $e')),
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
                      "Already have an account?",
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


