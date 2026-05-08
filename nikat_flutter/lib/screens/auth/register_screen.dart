import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _role = AppConstants.roleCustomer;
  bool _isLoading = false;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadPreferredRole();
  }

  Future<void> _loadPreferredRole() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.keyUserRole);
    if (saved != null && mounted) setState(() => _role = saved);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _profileImagePath = file.path);
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final authUser = ref.read(authStateProvider).valueOrNull;
      if (authUser == null) throw Exception('Not authenticated');

      await ref.read(authServiceProvider).createUserProfile(
        uid: authUser.uid,
        phone: authUser.phoneNumber ?? '',
        name: _nameController.text.trim(),
        role: _role,
        city: _cityController.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserId, authUser.uid);
      await prefs.setString(AppConstants.keyUserRole, _role);

      if (mounted) {
        if (_role == AppConstants.roleProvider) {
          context.go('/add-store');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                    ),
                    child: _profileImagePath != null
                        ? const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 48))
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 28),
                              SizedBox(height: 4),
                              Text('Photo', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                            ],
                          ),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _RoleChip(label: '👤 Customer', value: AppConstants.roleCustomer, selected: _role, onTap: (v) => setState(() => _role = v)),
                    const SizedBox(width: 12),
                    _RoleChip(label: '🏪 Provider', value: AppConstants.roleProvider, selected: _role, onTap: (v) => setState(() => _role = v)),
                  ],
                ).animate(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ).animate(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city_outlined)),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your city' : null,
                ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Create Account'),
                ).animate(delay: 400.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.value, required this.selected, required this.onTap});
  final String label;
  final String value;
  final String selected;
  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGlow : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : AppColors.onSurface)),
        ),
      ),
    );
  }
}
