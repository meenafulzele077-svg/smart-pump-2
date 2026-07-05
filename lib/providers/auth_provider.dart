import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'service_providers.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final box = Hive.box(AppConstants.sessionBox);
    final loggedIn = box.get(AppConstants.keyLoggedIn, defaultValue: false) as bool;
    return AuthState(isLoggedIn: loggedIn);
  }

  Future<String> requestOtp(String mobile) async {
    final service = ref.read(userServiceProvider);
    return service.requestOtp(mobile);
  }

  Future<void> verifyOtp(String requestId, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(userServiceProvider);
      final user = await service.verifyOtp(requestId, otp);
      await _persistSession();
      state = state.copyWith(isLoggedIn: true, isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loginWithMpin(String mobile, String mpin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(userServiceProvider);
      final user = await service.loginWithMpin(mobile, mpin);
      await _persistSession();
      state = state.copyWith(isLoggedIn: true, isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Incorrect MPIN. Please try again.');
    }
  }

  Future<void> loginWithBiometrics() async {
    // In a real build, `local_auth`'s LocalAuthentication().authenticate(...)
    // is called from the UI layer first; on success this simply restores
    // the previously remembered session.
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 400));
    final service = ref.read(userServiceProvider);
    final user = await service.getCurrentUser();
    await _persistSession();
    state = state.copyWith(isLoggedIn: true, isLoading: false, user: user);
  }

  Future<void> _persistSession() async {
    final box = Hive.box(AppConstants.sessionBox);
    await box.put(AppConstants.keyLoggedIn, true);
  }

  Future<void> logout() async {
    final service = ref.read(userServiceProvider);
    await service.logout();
    final box = Hive.box(AppConstants.sessionBox);
    await box.put(AppConstants.keyLoggedIn, false);
    state = const AuthState(isLoggedIn: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Convenience provider that loads the current user profile once logged in.
final currentUserProvider = FutureProvider<UserModel>((ref) async {
  final service = ref.watch(userServiceProvider);
  return service.getCurrentUser();
});
