import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_mobile/app/theme.dart';
import 'package:task_mobile/core/utils/validation_utils.dart';
import 'package:task_mobile/core/widgets/glossy_background.dart';
import 'package:task_mobile/features/auth/models/app_user.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isRegister = false;
  String _selectedRole = 'employee'; // 'employee' or 'manager'

  final _formKey = GlobalKey<FormState>();

  // Passwords visibility toggle
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Common controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Manager specific controllers
  final _companyController = TextEditingController();
  final _sectorController = TextEditingController();

  // Employee specific controllers
  final _ageController = TextEditingController();
  final _departmentController = TextEditingController();
  final _employeeOrgController = TextEditingController();
  AppUser? _selectedManager;

  @override
  void initState() {
    super.initState();
    // Reset selected manager whenever the employee types/edits their organization
    _employeeOrgController.addListener(() {
      if (_selectedManager != null) {
        final currentOrg = _employeeOrgController.text.trim().toLowerCase();
        final managerOrg = (_selectedManager!.companyName ?? '').trim().toLowerCase();
        if (currentOrg.isEmpty || !managerOrg.contains(currentOrg)) {
          setState(() {
            _selectedManager = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _sectorController.dispose();
    _ageController.dispose();
    _departmentController.dispose();
    _employeeOrgController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    bool success = false;

    if (!_isRegister) {
      // Sign In
      success = await authNotifier.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      // Registration
      final cleanPhone = ValidationUtils.cleanPhone(_phoneController.text.trim());

      if (_selectedRole == 'manager') {
        success = await authNotifier.registerManager(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: cleanPhone,
          companyName: _companyController.text.trim(),
          sector: _sectorController.text.trim(),
        );
      } else {
        // Employee
        if (_selectedManager == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFDC2626),
              content: Text('Please select a manager from the list of matching managers.'),
            ),
          );
          return;
        }

        success = await authNotifier.registerEmployee(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: cleanPhone,
          age: int.tryParse(_ageController.text.trim()) ?? 25,
          companyName: _employeeOrgController.text.trim(),
          department: _departmentController.text.trim(),
          managerId: _selectedManager!.uid,
          managerName: _selectedManager!.name,
        );
      }
    }

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Filter managers dynamically by employee's entered organization name
    final employeeOrg = _employeeOrgController.text.trim();
    final matchingManagersAsync = ref.watch(managersByOrganizationProvider(employeeOrg));

    return GlossyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: AppTheme.isDark(context)
                            ? BoxDecoration(
                                color: AppTheme.cardBg(context),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.cardBorder(context)),
                                boxShadow: AppTheme.cardShadow(context),
                              )
                            : null,
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 72,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Formatted Executive Motto Capsule (Frosted Glass)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg(context),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppTheme.cardBorder(context), width: 1.0),
                          boxShadow: AppTheme.cardShadow(context),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '✦ ',
                              style: TextStyle(
                                color: Color(0xFFD9A014),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: AppTheme.textPrimary(context),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                                children: [
                                  const TextSpan(text: 'What are your '),
                                  TextSpan(
                                    text: 'Tasks?',
                                    style: TextStyle(
                                      color: AppTheme.accentBlue(context),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Error Banner
                    if (authState.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.statusOverdueBackground(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.overdueBorderColor(context)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppTheme.statusOverdueTextColor(context), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authState.errorMessage!,
                                style: TextStyle(color: AppTheme.statusOverdueTextColor(context), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Form Title Header
                    Text(
                      _isRegister ? 'Create an Account' : 'Sign In',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Role Selector (Only when registering)
                    if (_isRegister) ...[
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.recessedSurface(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.cardBorder(context)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedRole = 'employee'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 11),
                                  decoration: BoxDecoration(
                                    color: _selectedRole == 'employee' ? AppTheme.selectedPillBg(context) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: _selectedRole == 'employee' ? Border.all(color: AppTheme.selectedPillBorder(context), width: 1.1) : null,
                                  ),
                                  child: Text(
                                    'Employee',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: _selectedRole == 'employee' ? AppTheme.selectedPillText(context) : AppTheme.textSecondary(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedRole = 'manager'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 11),
                                  decoration: BoxDecoration(
                                    color: _selectedRole == 'manager' ? AppTheme.selectedPillBg(context) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: _selectedRole == 'manager' ? Border.all(color: AppTheme.selectedPillBorder(context), width: 1.1) : null,
                                  ),
                                  child: Text(
                                    'Manager',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: _selectedRole == 'manager' ? AppTheme.selectedPillText(context) : AppTheme.textSecondary(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Full Name (Registration only)
                    if (_isRegister) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your full name' : null,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Email Address (With strict format checking)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'name@company.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: ValidationUtils.validateEmail,
                  ),
                  const SizedBox(height: 14),

                  // Phone Number (International WhatsApp check - Registration only)
                  if (_isRegister) ...[
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (for WhatsApp task alerts)',
                        hintText: '+1234567890 or +919876543210',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: ValidationUtils.validatePhone,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: ValidationUtils.validatePassword,
                  ),
                  const SizedBox(height: 14),

                  // Confirm Password (Registration only)
                  if (_isRegister) ...[
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (v) => ValidationUtils.validateConfirmPassword(v, _passwordController.text),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ==================== MANAGER SPECIFIC FIELDS ====================
                  if (_isRegister && _selectedRole == 'manager') ...[
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'Company / Organization Name',
                        hintText: 'e.g. Apex Innovations, Google',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your organization name' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _sectorController,
                      decoration: const InputDecoration(
                        labelText: 'Sector / Department',
                        hintText: 'e.g. Software, Finance, Product',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your sector' : null,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ==================== EMPLOYEE SPECIFIC FIELDS ====================
                  if (_isRegister && _selectedRole == 'employee') ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              prefixIcon: Icon(Icons.cake_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              final n = int.tryParse(v);
                              if (n == null || n < 16 || n > 100) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _departmentController,
                            decoration: const InputDecoration(
                              labelText: 'Department',
                              hintText: 'e.g. Frontend, QA',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter department' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Employee Organization Input
                    TextFormField(
                      controller: _employeeOrgController,
                      decoration: const InputDecoration(
                        labelText: 'Organization / Company Name',
                        hintText: 'Type your company name to find your manager',
                        prefixIcon: Icon(Icons.domain_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please type your company name' : null,
                      onChanged: (_) {
                        setState(() {}); // Trigger rebuild to query matching managers
                      },
                    ),
                    const SizedBox(height: 14),

                    // Dynamic Manager Selector matching entered Organization
                    if (employeeOrg.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Text(
                          'ℹ️ Enter your organization name above to see available managers.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      )
                    else
                      matchingManagersAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                        error: (err, stack) => Text('Error loading managers: $err'),
                        data: (managers) {
                          if (managers.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Text(
                                'No managers found for "$employeeOrg". Please verify the company name with your manager.',
                                style: const TextStyle(color: Color(0xFF92400E), fontSize: 13),
                              ),
                            );
                          }

                          return DropdownButtonFormField<AppUser>(
                            initialValue: _selectedManager,
                            decoration: const InputDecoration(
                              labelText: 'Select Your Manager',
                              prefixIcon: Icon(Icons.supervisor_account_outlined),
                            ),
                            items: managers.map((m) {
                              final label = '${m.name} (${m.companyName} — ${m.sector ?? 'General'})';
                              return DropdownMenuItem<AppUser>(
                                value: m,
                                child: Text(label, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedManager = val),
                            validator: (v) => v == null ? 'Please select a manager' : null,
                          );
                        },
                      ),
                    const SizedBox(height: 14),
                  ],

                  const SizedBox(height: 12),

                  // Submit Button
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.ctaBackground(context),
                      foregroundColor: AppTheme.ctaForeground(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      elevation: 0,
                    ),
                    child: authState.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.ctaForeground(context),
                            ),
                          )
                        : Text(
                            _isRegister ? 'Register as ${_selectedRole.toUpperCase()}' : 'Sign In',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.ctaForeground(context),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Switch between Sign In & Register
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegister = !_isRegister;
                      });
                    },
                    child: Text(
                      _isRegister ? 'Already have an account? Sign In' : "Don't have an account? Create one",
                      style: TextStyle(color: AppTheme.accentBlue(context), fontWeight: FontWeight.w600),
                    ),
                  ),
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
