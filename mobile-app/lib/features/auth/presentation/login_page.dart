import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/network/api_exception.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _phoneController;
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _devCode;
  bool _otpRequested = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: '+998901234567');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _getOtp() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _devCode = null;
    });

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _errorMessage = 'Telefon raqam kiriting';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.requestOtp(phone);
      setState(() {
        _successMessage = response.message;
        _devCode = response.devCode;
        _otpRequested = true;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'OTP yuborishda xatolik yuz berdi';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _verifyOtp() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP tasdiqlash 48-qadamda ulanadi.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tizimga kirish'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Mobil telefon raqamingizni kiriting',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tizimdan foydalanish uchun telefon raqamingizga bir martalik kod (OTP) yuboramiz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // Error Message Box
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Success Message Box
                if (_successMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: TextStyle(color: Colors.green[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Dev OTP Info Box
                if (_devCode != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Dev OTP: $_devCode',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_otpRequested && !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Telefon raqam',
                    hintText: '+998901234567',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 24),

                if (!_otpRequested)
                  AppButton(
                    label: 'OTP olish',
                    fullWidth: true,
                    loading: _isLoading,
                    onPressed: _isLoading ? null : _getOtp,
                  ),

                if (_otpRequested) ...[
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tasdiqlash kodi',
                      hintText: '111111',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Tasdiqlash',
                    fullWidth: true,
                    onPressed: _verifyOtp,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : _getOtp,
                    child: const Text('Kodni qayta yuborish'),
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  child: const Text(
                    'Demo davom etish',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
