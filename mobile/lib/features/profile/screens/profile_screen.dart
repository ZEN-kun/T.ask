import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_mobile/app/theme.dart';
import 'package:task_mobile/app/theme_provider.dart';
import 'package:task_mobile/core/utils/file_picker_helper.dart';
import 'package:task_mobile/core/widgets/glossy_background.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _companyController;

  String? _photoBase64;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _departmentController = TextEditingController(text: user?.department ?? '');
    _companyController = TextEditingController(text: user?.companyName ?? '');
    _photoBase64 = user?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarPhoto() async {
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      backgroundColor: AppTheme.solidCardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: AppTheme.accentBlue(context)),
                title: Text('Choose from Gallery', style: TextStyle(color: AppTheme.textPrimary(context))),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: AppTheme.accentBlue(context)),
                title: Text('Take a Photo', style: TextStyle(color: AppTheme.textPrimary(context))),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final b64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _photoBase64 = b64;
        });
      }
    } catch (e) {
      // Fallback to generic file picker if camera/gallery plugin is unavailable
      try {
        final pickedFile = await pickAvatarImage();
        if (pickedFile != null) {
          final b64 = 'data:image/jpeg;base64,${base64Encode(pickedFile.bytes)}';
          setState(() {
            _photoBase64 = b64;
          });
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to pick photo: $err')),
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;

    setState(() => _isSaving = true);
    try {
      final firestore = ref.read(firestoreProvider);
      final updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'department': _departmentController.text.trim(),
        if (currentUser.isManager) 'company_name': _companyController.text.trim(),
        if (_photoBase64 != null) 'photo_url': _photoBase64,
      };

      await firestore.collection('users').doc(currentUser.uid).update(updatedData);

      final authInstance = FirebaseAuth.instance;
      if (authInstance.currentUser != null) {
        await authInstance.currentUser!.updateDisplayName(_nameController.text.trim());
      }

      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        department: _departmentController.text.trim(),
        companyName: currentUser.isManager ? _companyController.text.trim() : null,
        photoUrl: _photoBase64,
      );
      ref.read(authProvider.notifier).setUser(updatedUser);

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            content: Text('Profile updated successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Failed to save profile: $e'),
          ),
        );
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.solidCardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out', style: TextStyle(color: AppTheme.textPrimary(context), fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to log out of T.ask?', style: TextStyle(color: AppTheme.textSecondary(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  ImageProvider? _getAvatarImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('data:image')) {
      try {
        final commaIdx = photoUrl.indexOf(',');
        if (commaIdx != -1) {
          final bytes = base64Decode(photoUrl.substring(commaIdx + 1));
          return MemoryImage(bytes);
        }
      } catch (_) {}
    }
    return NetworkImage(photoUrl);
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = currentMode == mode;
    final isDark = AppTheme.isDark(context);

    final activeBg = AppTheme.selectedPillBg(context);
    final activeBorder = AppTheme.selectedPillBorder(context);
    final activeColor = AppTheme.selectedPillText(context);
    final inactiveColor = AppTheme.textSecondary(context);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: activeBorder, width: 1.1) : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? activeColor : inactiveColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = AppTheme.isDark(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user profile found')));
    }

    final avatarProvider = _getAvatarImage(_photoBase64);

    return GlossyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Profile & Settings',
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: AppTheme.textPrimary(context)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with Edit Badge
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accentBlue(context).withValues(alpha: 0.35), width: 2.5),
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: AppTheme.accentBlue(context),
                        backgroundImage: avatarProvider,
                        child: avatarProvider == null
                            ? Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: InkWell(
                        onTap: _pickAvatarPhoto,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.ctaBackground(context),
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.white, width: 2),
                          ),
                          child: Icon(Icons.camera_alt_rounded, size: 15, color: AppTheme.ctaForeground(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickAvatarPhoto,
                  icon: Icon(Icons.photo_outlined, size: 16, color: AppTheme.accentBlue(context)),
                  label: Text('Change Avatar Photo', style: TextStyle(fontSize: 13, color: AppTheme.accentBlue(context), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),

                // Role & Email Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTint(context),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                  ),
                  child: Text(
                    '${user.role.toUpperCase()} • ${user.email}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentBlue(context),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Appearance & Theme Selector Card (FinovAi Style)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.cardBorder(context), width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF3E679B).withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentTint(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.palette_outlined, size: 18, color: AppTheme.accentBlue(context)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appearance',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Choose your preferred interface theme',
                                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 3-Segment Pill Selector
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkRecessed : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppTheme.darkRecessedBorder : AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            _buildThemeOption(
                              context: context,
                              label: 'System',
                              icon: Icons.brightness_auto_outlined,
                              mode: ThemeMode.system,
                              currentMode: currentThemeMode,
                            ),
                            _buildThemeOption(
                              context: context,
                              label: 'Light',
                              icon: Icons.light_mode_outlined,
                              mode: ThemeMode.light,
                              currentMode: currentThemeMode,
                            ),
                            _buildThemeOption(
                              context: context,
                              label: 'Dark',
                              icon: Icons.dark_mode_outlined,
                              mode: ThemeMode.dark,
                              currentMode: currentThemeMode,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Personal Information Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.cardBorder(context), width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF3E679B).withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Details',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary(context)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: AppTheme.textPrimary(context)),
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: AppTheme.textPrimary(context)),
                        decoration: const InputDecoration(
                          labelText: 'WhatsApp Phone Number',
                          hintText: 'e.g. 7981929830 or +91 7981929830',
                          prefixIcon: Icon(Icons.phone_outlined),
                          helperText: 'Used for automated WhatsApp task assignments',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a phone number' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Organization Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.cardBorder(context), width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF3E679B).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organization & Team',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary(context)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _departmentController,
                        style: TextStyle(color: AppTheme.textPrimary(context)),
                        decoration: const InputDecoration(
                          labelText: 'Department / Team',
                          hintText: 'e.g. Frontend, Backend, QA',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      if (user.isManager) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _companyController,
                          style: TextStyle(color: AppTheme.textPrimary(context)),
                          decoration: const InputDecoration(
                            labelText: 'Company / Organization Name',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save Changes Button (Pill Shape)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Save Profile Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ctaBackground(context),
                      foregroundColor: AppTheme.ctaForeground(context),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: _isSaving ? null : _saveProfile,
                  ),
                ),
                const SizedBox(height: 14),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.logout_rounded, color: AppTheme.statusOverdueTextColor(context), size: 18),
                    label: Text(
                      'Log Out',
                      style: TextStyle(
                        color: AppTheme.statusOverdueTextColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.overdueBorderColor(context)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: _confirmLogout,
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
