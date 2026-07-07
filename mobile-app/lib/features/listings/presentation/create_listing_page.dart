import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/network/api_exception.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/features/categories/data/category_models.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_models.dart';
import 'package:qishloq_ai_mobile/features/regions/data/region_models.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_button.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_bottom_nav.dart';

class CreateListingPage extends ConsumerStatefulWidget {
  const CreateListingPage({super.key});

  @override
  ConsumerState<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends ConsumerState<CreateListingPage> {
  // Wizard current step
  int _currentStep = 0;

  // Step Form Keys
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  // Form Field State Variables
  Category? _selectedCategory;
  Region? _selectedRegion;
  String? _listingType;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  // Loaders and error states
  bool _isInitLoading = true;
  bool _isSubmitting = false;
  String? _initErrorMessage;
  String? _submitErrorMessage;
  Listing? _createdListing;

  List<Category> _categories = [];
  List<Region> _regions = [];

  String? _step1Error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider);
      if (!authState.isAuthenticated) {
        context.go('/login');
        return;
      }

      // Set default phone number from auth state
      if (authState.user?.phone != null) {
        _phoneController.text = authState.user!.phone;
      }

      _loadReferenceData();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    setState(() {
      _isInitLoading = true;
      _initErrorMessage = null;
    });

    try {
      final categoryList = await ref
          .read(categoryServiceProvider)
          .getCategories();
      final regionList = await ref.read(regionServiceProvider).getRegions();

      setState(() {
        _categories = categoryList;
        _regions = regionList;
        _isInitLoading = false;
      });
    } catch (e) {
      setState(() {
        _initErrorMessage = e.toString();
        _isInitLoading = false;
      });
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'MACHINERY_RENT':
        return 'Texnika ijarasi';
      case 'PRODUCT_SALE':
        return 'Dehqon mahsulotlari';
      case 'LIVESTOCK_SALE':
        return 'Chorva savdosi';
      case 'MACHINERY_SALE':
        return 'Texnika savdosi';
      case 'SERVICE':
        return 'Agro xizmatlar';
      default:
        return type;
    }
  }

  IconData _getCategoryIcon(String type) {
    switch (type) {
      case 'MACHINERY_RENT':
        return Icons.agriculture_outlined;
      case 'PRODUCT_SALE':
        return Icons.shopping_basket_outlined;
      case 'LIVESTOCK_SALE':
        return Icons.pets_outlined;
      case 'MACHINERY_SALE':
        return Icons.construction_outlined;
      case 'SERVICE':
        return Icons.build_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) {
      if (_selectedCategory == null) {
        setState(() {
          _step1Error = 'Iltimos, kategoriyani tanlang';
        });
        return;
      }
      setState(() {
        _step1Error = null;
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      if (_step2FormKey.currentState != null &&
          _step2FormKey.currentState!.validate()) {
        setState(() {
          _currentStep = 2;
        });
      }
    } else if (_currentStep == 2) {
      if (_step3FormKey.currentState != null &&
          _step3FormKey.currentState!.validate()) {
        setState(() {
          _currentStep = 3;
        });
      }
    } else if (_currentStep == 3) {
      if (_step4FormKey.currentState != null &&
          _step4FormKey.currentState!.validate()) {
        setState(() {
          _currentStep = 4;
        });
      }
    }
  }

  void _prevStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) {
      return 'Sarlavha yozish majburiy';
    }
    if (title.length < 3) {
      return 'Kamida 3 ta belgi kiriting';
    }
    if (title.length > 120) {
      return 'Ko‘pi bilan 120 ta belgi kiriting';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final description = value?.trim() ?? '';
    if (description.length > 2000) {
      return 'Ko‘pi bilan 2000 ta belgi kiriting';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final price = value?.trim() ?? '';
    if (price.isEmpty) {
      return null;
    }
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(price)) {
      return 'Narx faqat raqam yoki decimal formatda bo‘lsin';
    }
    final numValue = double.tryParse(price);
    if (numValue == null || numValue <= 0) {
      return 'Narx 0 dan katta bo‘lsin';
    }
    return null;
  }

  String? _validateUnit(String? value) {
    final unit = value?.trim() ?? '';
    if (unit.length > 30) {
      return 'Ko‘pi bilan 30 ta belgi kiriting';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return null;
    }
    final reg = RegExp(r'^\+998\d{9}$');
    if (!reg.hasMatch(phone)) {
      return 'Telefon formati xato (masalan: +998901234567)';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    final address = value?.trim() ?? '';
    if (address.length > 255) {
      return 'Ko‘pi bilan 255 ta belgi kiriting';
    }
    return null;
  }

  void _showStepError(int step, String message) {
    setState(() {
      _currentStep = step;
      _submitErrorMessage = null;
      _step1Error = step == 0 ? message : null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateAllBeforeSubmit() {
    if (_selectedCategory == null || _listingType == null) {
      _showStepError(0, 'Iltimos, kategoriyani tanlang');
      return false;
    }

    final step2Error =
        _validateTitle(_titleController.text) ??
        _validateDescription(_descriptionController.text);
    if (step2Error != null) {
      _showStepError(1, step2Error);
      return false;
    }

    final step3Error =
        _validatePrice(_priceController.text) ??
        _validateUnit(_unitController.text) ??
        _validatePhone(_phoneController.text);
    if (step3Error != null) {
      _showStepError(2, step3Error);
      return false;
    }

    final step4Error = _validateAddress(_addressController.text);
    if (step4Error != null) {
      _showStepError(3, step4Error);
      return false;
    }

    return true;
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) {
      return;
    }
    if (!_validateAllBeforeSubmit()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitErrorMessage = null;
    });

    try {
      final request = CreateListingRequest(
        type: _listingType!,
        categoryId: _selectedCategory!.id,
        regionId: _selectedRegion?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priceAmount: _priceController.text.trim(),
        priceCurrency: 'UZS',
        unit: _unitController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      final listing = await ref
          .read(listingServiceProvider)
          .createListing(request);

      if (!mounted) {
        return;
      }
      setState(() {
        _createdListing = listing;
        _isSubmitting = false;
      });
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitErrorMessage = e.message;
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitErrorMessage = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!next.isAuthenticated && next.isLoading == false) {
        context.go('/login');
      }
    });

    if (!authState.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('E’lon joylash')),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _buildBody() {
    if (_isInitLoading) {
      return const AppLoadingState(message: 'Yuklanmoqda...');
    }

    if (_initErrorMessage != null) {
      return AppErrorState(
        title: 'Ma’lumotlarni yuklashda xatolik yuz berdi',
        message: _initErrorMessage!,
        onRetry: _loadReferenceData,
      );
    }

    if (_createdListing != null) {
      return _buildSuccessScreen();
    }

    Widget stepWidget;
    switch (_currentStep) {
      case 0:
        stepWidget = _buildStep1CategorySelection();
        break;
      case 1:
        stepWidget = _buildStep2Info();
        break;
      case 2:
        stepWidget = _buildStep3PriceContact();
        break;
      case 3:
        stepWidget = _buildStep4Location();
        break;
      case 4:
        stepWidget = _buildStep5Review();
        break;
      default:
        stepWidget = const SizedBox();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner about images
          const AppInfoBox(
            message:
                'E’lon admin tomonidan tasdiqlangandan keyin ko‘rinadi. Rasm qo‘shish keyingi bosqichda ulanadi.',
          ),
          const SizedBox(height: 20),

          // Progress Indicator
          _buildProgressIndicator(),

          if (_submitErrorMessage != null) ...[
            AppInfoBox(
              message: _submitErrorMessage!,
              icon: Icons.error_outline,
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[800],
            ),
            const SizedBox(height: 16),
          ],

          // Step Content
          stepWidget,
          const SizedBox(height: 32),

          // Bottom Buttons
          _buildBottomButtons(),

          // Spacing so it doesn't get covered by AppBottomNav
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = [
      'Kategoriya',
      'Ma’lumot',
      'Narx va aloqa',
      'Joylashuv',
      'Tasdiqlash',
    ];

    final progress = (_currentStep + 1) / steps.length;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_currentStep + 1}/${steps.length} ${steps[_currentStep]}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            Text(
              '${((_currentStep + 1) / steps.length * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(primary),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStep1CategorySelection() {
    if (_categories.isEmpty) {
      return const AppEmptyState(
        title: 'Kategoriyalar mavjud emas',
        message: 'Iltimos, keyinroq qayta urinib ko‘ring.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'E’lon kategoriyasini tanlang',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory?.id == category.id;
            final primary = Theme.of(context).colorScheme.primary;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _listingType = category.type;
                  _step1Error = null;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primary : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category.type),
                      color: isSelected ? primary : Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.nameUz,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected ? primary : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getTypeLabel(category.type),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? primary.withValues(alpha: 0.7)
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: primary)
                    else
                      Icon(Icons.radio_button_off, color: Colors.grey[400]),
                  ],
                ),
              ),
            );
          },
        ),
        if (_step1Error != null) ...[
          const SizedBox(height: 12),
          Text(
            _step1Error!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2Info() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sarlavha va Tavsif',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'E’lon sarlavhasi *',
              hintText: 'Masalan: MTZ traktor ijaraga beriladi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            validator: (val) {
              return _validateTitle(val);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Tafsilotlar / Tavsif',
              hintText: 'E’lon haqida batafsil yozing...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            validator: (val) {
              return _validateDescription(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3PriceContact() {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Narx va Aloqa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Narxi',
                    hintText: '0.00',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (val) {
                    return _validatePrice(val);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'UZS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _unitController,
            decoration: const InputDecoration(
              labelText: 'O‘lchov birligi',
              hintText: 'Masalan: kg, dona, soat, kun',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.scale_outlined),
            ),
            validator: (val) {
              return _validateUnit(val);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Bog‘lanish telefoni',
              hintText: '+998901234567',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (val) {
              return _validatePhone(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Location() {
    return Form(
      key: _step4FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Joylashuv',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Region>(
            decoration: const InputDecoration(
              labelText: 'Hudud',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            hint: const Text('Hududni tanlang (ixtiyoriy)'),
            initialValue: _selectedRegion,
            items: [
              const DropdownMenuItem<Region>(
                value: null,
                child: Text('Tanlanmagan'),
              ),
              ..._regions.map((Region reg) {
                return DropdownMenuItem<Region>(
                  value: reg,
                  child: Text(reg.nameUz),
                );
              }),
            ],
            onChanged: (Region? newReg) {
              setState(() {
                _selectedRegion = newReg;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Manzil',
              hintText: 'Masalan: Samarqand viloyati, Oqdaryo tumani...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.map_outlined),
            ),
            validator: (val) {
              return _validateAddress(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep5Review() {
    final priceStr = _priceController.text.trim().isNotEmpty
        ? '${_priceController.text.trim()} UZS'
        : 'Kiritilmagan';
    final unitStr = _unitController.text.trim().isNotEmpty
        ? _unitController.text.trim()
        : 'Kiritilmagan';
    final phoneStr = _phoneController.text.trim().isNotEmpty
        ? _phoneController.text.trim()
        : 'Kiritilmagan';
    final addressStr = _addressController.text.trim().isNotEmpty
        ? _addressController.text.trim()
        : 'Kiritilmagan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ma’lumotlarni tasdiqlang',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewItem(
                  'Kategoriya',
                  _selectedCategory?.nameUz ?? 'Kiritilmagan',
                ),
                const Divider(height: 24),
                _buildReviewItem(
                  'E’lon turi',
                  _getTypeLabel(_listingType ?? ''),
                ),
                const Divider(height: 24),
                _buildReviewItem('Sarlavha', _titleController.text.trim()),
                const Divider(height: 24),
                _buildReviewItem(
                  'Tavsif',
                  _descriptionController.text.trim().isNotEmpty
                      ? _descriptionController.text.trim()
                      : 'Kiritilmagan',
                ),
                const Divider(height: 24),
                _buildReviewItem('Narxi', priceStr),
                const Divider(height: 24),
                _buildReviewItem('O‘lchov birligi', unitStr),
                const Divider(height: 24),
                _buildReviewItem('Bog‘lanish telefoni', phoneStr),
                const Divider(height: 24),
                _buildReviewItem(
                  'Hudud',
                  _selectedRegion?.nameUz ?? 'Kiritilmagan',
                ),
                const Divider(height: 24),
                _buildReviewItem('Manzil', addressStr),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    final isLastStep = _currentStep == 4;
    final isNextDisabled = _currentStep == 0 && _categories.isEmpty;

    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: AppButton(
              label: 'Ortga',
              variant: AppButtonVariant.outlined,
              onPressed: _isSubmitting ? null : _prevStep,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: AppButton(
            label: isLastStep ? 'E’lonni yuborish' : 'Keyingi',
            loading: isLastStep ? _isSubmitting : false,
            onPressed: isNextDisabled
                ? null
                : () {
                    if (isLastStep) {
                      _submitForm();
                    } else {
                      _nextStep();
                    }
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return AppSuccessState(
      title: 'Muvaffaqiyatli yuborildi!',
      message: 'E’lon yuborildi. Admin tasdiqlaganidan keyin ommaga ko‘rinadi.',
      actions: [
        AppButton(
          label: 'Rasm qo‘shish',
          fullWidth: true,
          onPressed: () =>
              context.go('/listings/${_createdListing!.id}/images'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            icon: const Icon(Icons.list_alt_outlined),
            label: const Text('Mening e\'lonlarim'),
            onPressed: () => context.go('/my-listings'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => context.go('/listings'),
            child: const Text('E’lonlar ro‘yxatiga o‘tish'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/home'),
          child: const Text('Bosh sahifaga qaytish'),
        ),
      ],
    );
  }
}
