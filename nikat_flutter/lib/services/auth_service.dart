import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> sendOtp({
    required String phone,
    required Function(PhoneAuthCredential) onVerified,
    required Function(FirebaseAuthException) onError,
    required Function(String, int?) onCodeSent,
    required Function() onTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onVerified,
      verificationFailed: onError,
      codeSent: (verificationId, resendToken) => onCodeSent(verificationId, resendToken),
      codeAutoRetrievalTimeout: (_) => onTimeout(),
    );
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel> createUserProfile({
    required String uid,
    required String phone,
    required String name,
    required String role,
    String? city,
  }) async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {}

    final user = UserModel(
      id: uid,
      name: name,
      phone: phone,
      role: role,
      city: city,
      fcmToken: fcmToken,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _db.collection(AppConstants.usersCollection).doc(uid).set(user.toFirestore());
    return user;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.usersCollection).doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFcmToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await updateUserProfile(uid, {'fcmToken': token});
    }
  }

  Future<void> saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, languageCode);
    if (currentUser != null) {
      await updateUserProfile(currentUser!.uid, {'languageCode': languageCode});
    }
  }

  Future<String?> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyLanguage);
  }

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserRole);
  }

  Future<void> deleteAccount() async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _db.collection(AppConstants.usersCollection).doc(uid).delete();
    await currentUser?.delete();
  }
}
