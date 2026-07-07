import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/network/api_exception.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_button.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';

// ... (qolgan o'zgarmaslar)
const Map<String, String> _rolesMap = {
  'FARMER': 'Dehqon/Fermer',
  'LIVESTOCK_OWNER': 'Chorvador',
  'MACHINERY_OWNER': 'Texnika egasi',
  'BUYER': 'Xaridor',
  'AGRONOMIST': 'Agronom',
  'VETERINARIAN': 'Veterinar',
};

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _phoneController;
  final _otpController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoadingRequest = false;
  bool _isLoadingVerify = false;
  String? _errorMessage;
  String? _successMessage;
  String? _devCode;
  bool _otpRequested = false;
  String _selectedRole = 'FARMER';

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: '+998901234567');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialAuth();
    });
  }

  Future<void> _checkInitialAuth() async {
    final authState = ref.read(authControllerProvider);
    if (authState.isAuthenticated) {
      if (mounted) {
        context.go('/home');
      }
      return;
    }

    setState(() {
      _isLoadingVerify = true;
    });

    final isAuthenticated = await ref.read(authControllerProvider.notifier).checkAuth();
    if (mounted) {
      setState(() {
        _isLoadingVerify = false;
      });
      if (isAuthenticated) {
        context.go('/home');
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
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
      _isLoadingRequest = true;
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
        _isLoadingRequest = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final code = _otpController.text.trim();
    final fullName = _fullNameController.text.trim();
    final address = _addressController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'OTP kodni kiriting';
      });
      return;
    }

    if (fullName.isEmpty) {
      setState(() {
        _errorMessage = 'Ism familiyangizni kiriting';
      });
      return;
    }

    if (fullName.length < 3) {
      setState(() {
        _errorMessage = 'Ism familiya kamida 3 ta belgidan iborat bo‘lishi kerak';
      });
      return;
    }

    setState(() {
      _isLoadingVerify = true;
    });

    try {
      final phone = _phoneController.text.trim();
      final authService = ref.read(authServiceProvider);
      final tokenStorage = ref.read(tokenStorageProvider);

      // Verify OTP against the backend
      final verifyResponse = await authService.verifyOtp(
        phone: phone,
        code: code,
        role: _selectedRole,
        fullName: fullName,
        address: address.isEmpty ? null : address,
      );
      final token = verifyResponse.accessToken;

      if (token.isNotEmpty) {
        // Save the access token
        await tokenStorage.saveAccessToken(token);

        // Fetch User profile details (GET /auth/me)
        final user = await authService.getMe();

        if (!user.isActive) {
          await tokenStorage.clearAccessToken();
          setState(() {
            _errorMessage = 'Foydalanuvchi faol emas';
          });
          return;
        }

        // Set authenticated state in AuthController
        ref.read(authControllerProvider.notifier).setAuthenticatedFromLogin(user);

        setState(() {
          _successMessage = 'Muvaffaqiyatli kirdingiz';
        });

        if (mounted) {
          context.go('/home');
        }
      } else {
        setState(() {
          _errorMessage = 'Noto‘g‘ri token qabul qilindi';
        });
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'OTP tasdiqlashda xatolik yuz berdi';
      });
    } finally {
      setState(() {
        _isLoadingVerify = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showLoading = _isLoadingRequest || _isLoadingVerify;

    // Listen to global AuthState changes for error messages (e.g. session expired)
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        setState(() {
          _errorMessage = next.errorMessage;
        });
      }
    });

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
                  AppInfoBox(
                    message: _errorMessage!,
                    icon: Icons.error_outline,
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[900],
                  ),
                  const SizedBox(height: 16),
                ],

                // Success Message Box
                if (_successMessage != null) ...[
                  AppInfoBox(
                    message: _successMessage!,
                    icon: Icons.check_circle_outline,
                    backgroundColor: Colors.green[50],
                    foregroundColor: Colors.green[900],
                  ),
                  const SizedBox(height: 16),
                ],

                // Dev OTP Info Box
                if (_devCode != null) ...[
                  AppInfoBox(
                    message: 'Dev OTP: $_devCode',
                    icon: Icons.info_outline,
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[900],
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_otpRequested && !showLoading,
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
                    loading: _isLoadingRequest,
                    onPressed: showLoading ? null : _getOtp,
                  ),

                if (_otpRequested) ...[
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    enabled: !showLoading,
                    decoration: const InputDecoration(
                      labelText: 'Tasdiqlash kodi',
                      hintText: '111111',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _fullNameController,
                    keyboardType: TextInputType.name,
                    enabled: !showLoading,
                    decoration: const InputDecoration(
                      labelText: 'Ism familiyangiz',
                      hintText: 'Ism familiyangiz',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Sizning rolingiz',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work_outlined),
                    ),
                    items: _rolesMap.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: showLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedRole = value;
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    enabled: !showLoading,
                    decoration: const InputDecoration(
                      labelText: 'Manzil yoki tuman (ixtiyoriy)',
                      hintText: 'Manzil yoki tuman',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Tasdiqlash',
                    fullWidth: true,
                    loading: _isLoadingVerify,
                    onPressed: showLoading ? null : _verifyOtp,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: showLoading ? null : _getOtp,
                    child: const Text('Kodni qayta yuborish'),
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demo rejim keyingi bosqichlarda qayta yoqiladi. Hozir login talab qilinadi.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
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
