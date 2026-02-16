import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';


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

  
  String? _selectedUniversity;
  String? _selectedDegree;
  String? _emailError; // Added state for email error
  PlatformFile? _documentFile; // Selected student ID document

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
  XFile? _imageFile;
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
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      // Validate file size (5MB max)
      if (file.size > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).translate('file_too_large'))),
          );
        }
        return;
      }
      setState(() {
        _documentFile = file;
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
            // ignore: deprecated_member_use
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
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Container(
                  width: 500,
                  padding: const EdgeInsets.all(40),
                  child: _buildRegisterForm(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('create_account'))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _buildRegisterForm(context),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return Form(
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
                    radius: 50,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    backgroundImage: _imageFile != null
                        ? (kIsWeb
                            ? NetworkImage(_imageFile!.path)
                            : FileImage(File(_imageFile!.path))) as ImageProvider
                        : null,
                    child: _imageFile == null
                        ? Icon(Icons.person_outline, size: 50, color: isDark ? Colors.white54 : Colors.grey)
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
                      size: 16,
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
            t.translate('personal_information'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _nameController,
            label: t.translate('full_name'),
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) return t.translate('name_required');
              final words = value.trim().split(RegExp(r'\s+'));
              if (words.length < 3) return t.translate('name_required');

              return null;
            },

          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: t.translate('email_address'),
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (_emailError != null) return _emailError;
              if (value == null || value.isEmpty) return t.translate('email_required');
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) return t.translate('invalid_email');
              return null;
            },
          ),
          const SizedBox(height: 16),
          

          CustomTextField(
            controller: _passwordController,
            label: t.translate('password'),
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (value) => value!.isEmpty ? t.translate('enter_password_validation') : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _confirmPasswordController,
            label: t.translate('confirm_password'),
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.translate('confirm_your_password');
              }
              if (value != _passwordController.text) {
                return t.translate('passwords_not_match');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _dateController,
            label: t.translate('date_of_birth'),
            prefixIcon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: () => _selectDate(context),
            validator: (value) => value!.isEmpty ? t.translate('select_date') : null,
          ),
          const SizedBox(height: 32),

          // Academic Info
          Text(
            t.translate('academic_year'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // University Searchable Dropdown
          SearchableDropdown(
            value: _selectedUniversity,
            items: _universities,
            label: t.translate('university'),
            onChanged: (newValue) {
              setState(() {
                _selectedUniversity = newValue;
              });
            },
            validator: (value) => value == null || value.isEmpty ? t.translate('select_university') : null,
          ),

          const SizedBox(height: 16),
          
          // Degree Dropdown
          SearchableDropdown(
            value: _selectedDegree,
            items: _degrees,
            label: t.translate('degree'),
            onChanged: (newValue) {
              setState(() {
                _selectedDegree = newValue;
              });
            },
            validator: (value) => value == null || value.isEmpty ? t.translate('select_degree') : null,
          ),

          const SizedBox(height: 16),
          // Academic Year Dropdown
          SearchableDropdown(
            value: _selectedAcademicYear,
            items: _academicYears,
            label: t.translate('academic_year'),
            onChanged: (newValue) {
              setState(() {
                _selectedAcademicYear = newValue;
              });
            },
            validator: (value) => value == null || value.isEmpty ? t.translate('select_academic_year') : null,
          ),

          const SizedBox(height: 16),
          CustomTextField(
            controller: _specializationController,
            label: t.translate('specialization'),
            prefixIcon: Icons.book_outlined,
          ),
          const SizedBox(height: 32),

          // Student ID Document Upload
          Text(
            t.translate('upload_student_id'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickDocument,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _documentFile != null
                      ? (isDark ? Colors.white54 : Colors.black54)
                      : (isDark ? Colors.white24 : Colors.grey.shade300),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isDark ? Colors.grey[900] : Colors.grey[50],
              ),
              child: Column(
                children: [
                  Icon(
                    _documentFile != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                    size: 40,
                    color: _documentFile != null
                        ? Colors.green
                        : (isDark ? Colors.white54 : Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _documentFile != null
                        ? _documentFile!.name
                        : t.translate('select_document'),
                    style: TextStyle(
                      color: _documentFile != null
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? Colors.white54 : Colors.grey),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_documentFile == null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'JPEG, PNG, PDF (Max 5MB)',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Document validation error
          Builder(
            builder: (context) {
              // This will be shown by form validation
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 48),

          // Action Button
          PrimaryButton(
            text: t.translate('register'),
            isLoading: authProvider.isLoading,
            onPressed: () async {
              // Validate document separately
              if (_documentFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.translate('document_required'))),
                );
                return;
              }
              if (_formKey.currentState!.validate()) {
                try {
                  final message = await authProvider.register(
                    name: _nameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    dateOfBirth: _dateController.text,
                    university: _selectedUniversity!,
                    degree: _selectedDegree,
                    specialization: _specializationController.text,
                    academicYear: _selectedAcademicYear,
                    documentFile: _documentFile,
                    profileImageFile: _imageFile,
                  );
                  
                  // Show success dialog (account under review)
                  if (context.mounted) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.mark_email_read, size: 40, color: Colors.green),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                t.translate('registration_successful'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                t.translate('check_email_verification'),
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx); // Close dialog
                                    Navigator.pop(context); // Go back to login
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? Colors.white : Colors.black,
                                    foregroundColor: isDark ? Colors.black : Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: Text(t.translate('confirm')),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                } on DioException catch (e) {
                    String errorMessage = t.translate('registration_failed');
                    if (e.response?.data != null) {
                      if (e.response!.data is List) {
                        final list = e.response!.data as List;
                        errorMessage = list.map((item) => item['msg'].toString()).join('\n');
                      } else if (e.response!.data is Map) {
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
                t.translate('already_have_account'),
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  t.translate('login'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


