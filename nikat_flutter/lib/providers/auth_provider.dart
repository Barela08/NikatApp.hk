import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.watch(authServiceProvider).getUserProfile(user.uid);
});

final userProfileProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
});

class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier(this._authService) : super(const OtpState());

  final AuthService _authService;
  String? _verificationId;

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null, otpSent: false);
    await _authService.sendOtp(
      phone: phone,
      onVerified: (credential) async {
        state = state.copyWith(isLoading: false, autoVerified: true, credential: credential);
      },
      onError: (e) {
        state = state.copyWith(isLoading: false, error: e.message ?? 'OTP failed');
      },
      onCodeSent: (verificationId, _) {
        _verificationId = verificationId;
        state = state.copyWith(isLoading: false, otpSent: true);
      },
      onTimeout: () => state = state.copyWith(isLoading: false, error: 'OTP timeout'),
    );
  }

  Future<bool> verifyOtp(String otp) async {
    if (_verificationId == null) return false;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.verifyOtp(verificationId: _verificationId!, smsCode: otp);
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Invalid OTP');
      return false;
    }
  }

  void reset() => state = const OtpState();
}

class OtpState {
  final bool isLoading;
  final bool otpSent;
  final bool autoVerified;
  final String? error;
  final PhoneAuthCredential? credential;

  const OtpState({
    this.isLoading = false,
    this.otpSent = false,
    this.autoVerified = false,
    this.error,
    this.credential,
  });

  OtpState copyWith({
    bool? isLoading, bool? otpSent, bool? autoVerified,
    String? error, PhoneAuthCredential? credential,
  }) => OtpState(
        isLoading: isLoading ?? this.isLoading,
        otpSent: otpSent ?? this.otpSent,
        autoVerified: autoVerified ?? this.autoVerified,
        error: error,
        credential: credential ?? this.credential,
      );
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) {
  return OtpNotifier(ref.watch(authServiceProvider));
});
