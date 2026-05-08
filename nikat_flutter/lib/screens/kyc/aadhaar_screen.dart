import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

enum _KycStep { aadhaarNumber, frontPhoto, backPhoto, selfie, review, submitted }

class AadhaarScreen extends ConsumerStatefulWidget {
  const AadhaarScreen({super.key});

  @override
  ConsumerState<AadhaarScreen> createState() => _AadhaarScreenState();
}

class _AadhaarScreenState extends ConsumerState<AadhaarScreen> {
  _KycStep _step = _KycStep.aadhaarNumber;
  final _aadhaarController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  XFile? _frontImage;
  XFile? _backImage;
  XFile? _selfieImage;
  bool _isLoading = false;
  bool _agreed = false;

  String get _maskedAadhaar {
    final n = _aadhaarController.text.replaceAll(' ', '');
    if (n.length < 12) return n;
    return 'XXXX XXXX ${n.substring(8)}';
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1200);
    if (file == null) return;
    setState(() {
      if (type == 'front') _frontImage = file;
      else if (type == 'back') _backImage = file;
      else _selfieImage = file;
    });
  }

  Future<void> _submit() async {
    if (!_agreed) return;
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception('Not logged in');

      // In real app: upload images to Firebase Storage, then save URLs
      // Here we save the KYC record with placeholders
      await FirebaseFirestore.instance.collection(AppConstants.kycCollection).add({
        'userId': user.id,
        'aadhaarNumber': _aadhaarController.text.replaceAll(' ', ''),
        'name': _nameController.text.trim(),
        'dob': _dobController.text.trim(),
        'frontImageUrl': 'pending_upload',
        'backImageUrl': 'pending_upload',
        'selfieUrl': 'pending_upload',
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Update user's KYC status
      await ref.read(authServiceProvider).updateUserProfile(user.id, {'kycStatus': 'pending'});

      setState(() {
        _step = _KycStep.submitted;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Aadhaar KYC'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _ProgressBar(step: _step.index, total: _KycStep.submitted.index),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _KycStep.aadhaarNumber:
        return _buildAadhaarInput();
      case _KycStep.frontPhoto:
        return _buildPhotoStep(
          key: const ValueKey('front'),
          title: 'Front of Aadhaar Card',
          subtitle: 'Take a clear photo of the front side',
          icon: '🪪',
          image: _frontImage,
          onCamera: () => _pickImage(ImageSource.camera, 'front'),
          onGallery: () => _pickImage(ImageSource.gallery, 'front'),
          onNext: () => setState(() => _step = _KycStep.backPhoto),
        );
      case _KycStep.backPhoto:
        return _buildPhotoStep(
          key: const ValueKey('back'),
          title: 'Back of Aadhaar Card',
          subtitle: 'Take a clear photo of the back side',
          icon: '🔄',
          image: _backImage,
          onCamera: () => _pickImage(ImageSource.camera, 'back'),
          onGallery: () => _pickImage(ImageSource.gallery, 'back'),
          onNext: () => setState(() => _step = _KycStep.selfie),
        );
      case _KycStep.selfie:
        return _buildPhotoStep(
          key: const ValueKey('selfie'),
          title: 'Take a Selfie',
          subtitle: 'Hold your Aadhaar card next to your face',
          icon: '🤳',
          image: _selfieImage,
          onCamera: () => _pickImage(ImageSource.camera, 'selfie'),
          onGallery: () => _pickImage(ImageSource.gallery, 'selfie'),
          onNext: () => setState(() => _step = _KycStep.review),
        );
      case _KycStep.review:
        return _buildReview();
      case _KycStep.submitted:
        return _buildSubmitted();
    }
  }

  Widget _buildAadhaarInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      key: const ValueKey('aadhaar'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('🔐', style: TextStyle(fontSize: 48)).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text('Aadhaar Verification', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800))
              .animate(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 8),
          const Text('Required for shop listing and service provider access',
              style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 14))
              .animate(delay: 150.ms).fadeIn(),
          const SizedBox(height: 32),
          TextFormField(
            controller: _aadhaarController,
            keyboardType: TextInputType.number,
            maxLength: 14,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _AadhaarFormatter(),
            ],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 3),
            decoration: const InputDecoration(
              labelText: 'Aadhaar Number',
              hintText: 'XXXX XXXX XXXX',
              prefixIcon: Icon(Icons.credit_card_outlined),
              counterText: '',
            ),
          ).animate(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name (as on Aadhaar)',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dobController,
            decoration: const InputDecoration(
              labelText: 'Date of Birth (DD/MM/YYYY)',
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
            keyboardType: TextInputType.datetime,
          ).animate(delay: 350.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🔒', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your Aadhaar data is encrypted and used only for identity verification. We comply with UIDAI guidelines.',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted, height: 1.5),
                  ),
                ),
              ],
            ),
          ).animate(delay: 400.ms).fadeIn(),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              final n = _aadhaarController.text.replaceAll(' ', '');
              if (n.length != 12) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter valid 12-digit Aadhaar number')),
                );
                return;
              }
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter name as on Aadhaar')),
                );
                return;
              }
              setState(() => _step = _KycStep.frontPhoto);
            },
            child: const Text('Continue →'),
          ).animate(delay: 450.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildPhotoStep({
    required Key key,
    required String title,
    required String subtitle,
    required String icon,
    required XFile? image,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onNext,
  }) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(icon, style: const TextStyle(fontSize: 48)).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))
              .animate(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 14))
              .animate(delay: 150.ms).fadeIn(),
          const SizedBox(height: 32),
          // Preview
          GestureDetector(
            onTap: onCamera,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: image != null ? AppColors.primary : AppColors.border,
                  width: image != null ? 2 : 1,
                ),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(File(image.path), fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined, color: AppColors.onSurfaceMuted, size: 48),
                        const SizedBox(height: 12),
                        const Text('Tap to capture', style: TextStyle(color: AppColors.onSurfaceMuted)),
                      ],
                    ),
            ),
          ).animate(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCamera,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 24),
          _PhotoTips(),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: image == null ? null : onNext,
            child: const Text('Continue →'),
          ).animate(delay: 400.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildReview() {
    return SingleChildScrollView(
      key: const ValueKey('review'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('✅', style: TextStyle(fontSize: 48)).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text('Review & Submit', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))
              .animate(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 6),
          const Text('Verify your details before submitting',
              style: TextStyle(color: AppColors.onSurfaceMuted)).animate(delay: 150.ms).fadeIn(),
          const SizedBox(height: 28),
          _ReviewCard(label: 'Aadhaar Number', value: _maskedAadhaar),
          const SizedBox(height: 8),
          _ReviewCard(label: 'Full Name', value: _nameController.text.trim()),
          if (_dobController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ReviewCard(label: 'Date of Birth', value: _dobController.text.trim()),
          ],
          const SizedBox(height: 8),
          _ReviewCard(label: 'Front Photo', value: _frontImage != null ? '✅ Uploaded' : '❌ Missing'),
          const SizedBox(height: 8),
          _ReviewCard(label: 'Back Photo', value: _backImage != null ? '✅ Uploaded' : '❌ Missing'),
          const SizedBox(height: 8),
          _ReviewCard(label: 'Selfie with Aadhaar', value: _selfieImage != null ? '✅ Uploaded' : '❌ Missing'),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: _agreed ? AppColors.primary : Colors.transparent,
                    border: Border.all(color: _agreed ? AppColors.primary : AppColors.border, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _agreed ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'I confirm that all information is accurate and belongs to me. I consent to NIKAT using this for KYC verification.',
                    style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, height: 1.5),
                  ),
                ),
              ],
            ),
          ).animate(delay: 300.ms).fadeIn(),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: (!_agreed || _isLoading) ? null : _submit,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Submit for Verification'),
          ).animate(delay: 400.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildSubmitted() {
    return Center(
      key: const ValueKey('submitted'),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80))
                .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            const Text('KYC Submitted!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary))
                .animate(delay: 200.ms).slideY(begin: 0.3, duration: 400.ms).fadeIn(),
            const SizedBox(height: 12),
            const Text('Your Aadhaar verification is under review.\nThis usually takes 24-48 hours.',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurfaceMuted, height: 1.6))
                .animate(delay: 300.ms).fadeIn(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  Row(children: [
                    Text('✅', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Expanded(child: Text('Documents submitted securely', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted))),
                  ]),
                  SizedBox(height: 8),
                  Row(children: [
                    Text('🔔', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Expanded(child: Text('You\'ll get a notification when approved', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted))),
                  ]),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Home'),
            ).animate(delay: 500.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (step + 1) / (total + 1),
      backgroundColor: AppColors.surfaceVariant,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      minHeight: 3,
    );
  }
}

class _PhotoTips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📸 Tips for a good photo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('• Ensure good lighting\n• All text should be clearly visible\n• No glare or reflections\n• Hold the card flat',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted, height: 1.6)),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _AadhaarFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 12) return oldValue;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
