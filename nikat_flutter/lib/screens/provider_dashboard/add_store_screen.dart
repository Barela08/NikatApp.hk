import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/provider_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/providers_provider.dart';
import '../../services/provider_service.dart';

class AddStoreScreen extends ConsumerStatefulWidget {
  const AddStoreScreen({super.key});

  @override
  ConsumerState<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends ConsumerState<AddStoreScreen> {
  final _shopNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception('Not logged in');
      final location = ref.read(locationProvider);

      final provider = ProviderModel(
        id: '',
        userId: user.id,
        shopName: _shopNameController.text.trim(),
        ownerName: user.name,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        categoryId: _selectedCategory!,
        categoryName: AppConstants.categories.firstWhere((c) => c['id'] == _selectedCategory, orElse: () => {})['name'] as String?,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        latitude: location.latitude ?? AppConstants.defaultLat,
        longitude: location.longitude ?? AppConstants.defaultLng,
        phone: _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(providerServiceProvider).createProvider(provider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop submitted for verification!'), backgroundColor: AppColors.success),
        );
        context.go('/provider-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('List Your Shop')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shop Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))
                  .animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(labelText: 'Shop Name *', prefixIcon: Icon(Icons.store_outlined)),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter shop name' : null,
              ).animate(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 16),
              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select Category *'),
                dropdownColor: AppColors.surfaceVariant,
                items: AppConstants.categories.where((c) => c['id'] != 'more').map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id'] as String,
                    child: Text('${cat['icon']} ${cat['name']}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
              ).animate(delay: 150.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined)),
                maxLines: 3,
              ).animate(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 24),
              const Text('Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))
                  .animate(delay: 250.ms).fadeIn(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Full Address *', prefixIcon: Icon(Icons.location_on_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter address' : null,
              ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City *', prefixIcon: Icon(Icons.location_city_outlined)),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter city' : null,
              ).animate(delay: 350.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 24),
              const Text('Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))
                  .animate(delay: 400.ms).fadeIn(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number *', prefixIcon: Icon(Icons.phone_outlined)),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid phone' : null,
              ).animate(delay: 450.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(labelText: 'WhatsApp Number (optional)', prefixIcon: Icon(Icons.chat_outlined)),
                keyboardType: TextInputType.phone,
              ).animate(delay: 500.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.warning.withOpacity(0.3))),
                child: const Row(
                  children: [
                    Text('⚠️', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Expanded(child: Text('Your shop will be reviewed by admin before going live. This usually takes 24 hours.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted))),
                  ],
                ),
              ).animate(delay: 550.ms).fadeIn(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Submit for Verification'),
              ).animate(delay: 600.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
