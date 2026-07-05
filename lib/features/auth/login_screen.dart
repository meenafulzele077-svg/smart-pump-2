import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

enum _LoginMode { mobile, otp, mpin }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  _LoginMode _mode = _LoginMode.mobile;
  final _mobileController = TextEditingController(text: '9876543210');
  final _mpinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _otpRequestId = '';
  String _otp = '';
  bool _rememberDevice = true;

  @override
  void dispose() {
    _mobileController.dispose();
    _mpinController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final requestId = await ref.read(authProvider.notifier).requestOtp(_mobileController.text);
    setState(() {
      _otpRequestId = requestId;
      _mode = _LoginMode.otp;
    });
  }

  Future<void> _verifyOtp() async {
    await ref.read(authProvider.notifier).verifyOtp(_otpRequestId, _otp);
    _afterLogin();
  }

  Future<void> _loginWithMpin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).loginWithMpin(_mobileController.text, _mpinController.text);
    _afterLogin();
  }

  Future<void> _loginWithBiometrics() async {
    // Real implementation: use `local_auth`'s LocalAuthentication().authenticate()
    // here first, then call the provider only on biometric success.
    await ref.read(authProvider.notifier).loginWithBiometrics();
    _afterLogin();
  }

  void _afterLogin() {
    final state = ref.read(authProvider);
    if (state.isLoggedIn && mounted) {
      context.go('/home');
    } else if (state.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.tealGreenGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 24),
                Text('Welcome back', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  'Control and monitor your pumps from anywhere.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildModeContent(theme, authState),
                ),
                const SizedBox(height: 20),
                if (_mode != _LoginMode.otp) _buildModeToggle(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle(ThemeData theme) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            _mode = _mode == _LoginMode.mobile ? _LoginMode.mpin : _LoginMode.mobile;
          });
        },
        icon: Icon(_mode == _LoginMode.mobile ? Icons.pin_rounded : Icons.sms_rounded),
        label: Text(_mode == _LoginMode.mobile ? 'Login with MPIN instead' : 'Login with OTP instead'),
      ),
    );
  }

  Widget _buildModeContent(ThemeData theme, AuthState authState) {
    switch (_mode) {
      case _LoginMode.mobile:
        return Column(
          key: const ValueKey('mobile'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mobile Number', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: Validators.mobileNumber,
              decoration: const InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text('+91', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: '98765 43210',
                counterText: '',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: authState.isLoading ? null : _sendOtp,
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Send OTP'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: authState.isLoading ? null : _loginWithBiometrics,
              icon: const Icon(Icons.fingerprint_rounded),
              label: const Text('Use Biometrics'),
            ),
          ],
        );
      case _LoginMode.otp:
        return Column(
          key: const ValueKey('otp'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter the OTP sent to +91 ${_mobileController.text}',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (v) => _otp = v,
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12),
                fieldHeight: 48,
                fieldWidth: 42,
                activeColor: theme.colorScheme.primary,
                selectedColor: theme.colorScheme.primary,
                inactiveColor: theme.colorScheme.outlineVariant,
                activeFillColor: theme.colorScheme.surface,
                selectedFillColor: theme.colorScheme.surface,
                inactiveFillColor: theme.colorScheme.surface,
              ),
              enableActiveFill: true,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: authState.isLoading ? null : _verifyOtp,
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Verify & Continue'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _mode = _LoginMode.mobile),
              child: const Text('Change mobile number'),
            ),
          ],
        );
      case _LoginMode.mpin:
        return Column(
          key: const ValueKey('mpin'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mobile Number', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: Validators.mobileNumber,
              decoration: const InputDecoration(hintText: '98765 43210', counterText: ''),
            ),
            const SizedBox(height: 16),
            Text('MPIN', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _mpinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              validator: Validators.mpin,
              decoration: const InputDecoration(hintText: '••••', counterText: ''),
            ),
            Row(
              children: [
                Checkbox(
                  value: _rememberDevice,
                  onChanged: (v) => setState(() => _rememberDevice = v ?? true),
                ),
                const Text('Remember this device'),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: authState.isLoading ? null : _loginWithMpin,
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Login'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: authState.isLoading ? null : _loginWithBiometrics,
              icon: const Icon(Icons.fingerprint_rounded),
              label: const Text('Use Biometrics'),
            ),
          ],
        );
    }
  }
}
