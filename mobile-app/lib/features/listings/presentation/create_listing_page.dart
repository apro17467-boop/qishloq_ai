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

class CreateListingPage extends ConsumerStatefulWidget {
  const CreateListingPage({super.key});

  @override
  ConsumerState<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends ConsumerState<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Field State Variables
  Category? _selectedCategory;
  Region? _selectedRegion;
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
      final categoryList = await ref.read(categoryServiceProvider).getCategories();
      final regionList = await ref.read(regionServiceProvider).getRegions();

      setState(() {
        _categories = categoryList;
        _regions = regionList;
        _isInitLoading = false;
      });
    } catch (e) {
      setState(() {
        _initErrorMessage = 'Ma’lumotlarni yuklashda xatolik yuz berdi: ${e.toString()}';
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

  Future<void> _submitForm() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, e’lon kategoriyasini tanlang')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitErrorMessage = null;
    });

    try {
      final request = CreateListingRequest(
        type: _selectedCategory!.type,
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

      final listing = await ref.read(listingServiceProvider).createListing(request);

      setState(() {
        _createdListing = listing;
        _isSubmitting = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _submitErrorMessage = e.message;
        _isSubmitting = false;
      });
    } catch (e) {
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('E’lon joylash'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isInitLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Yuklanmoqda...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_initErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _initErrorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Qayta urinish',
                onPressed: _loadReferenceData,
              ),
            ],
          ),
        ),
      );
    }

    if (_createdListing != null) {
      return _buildSuccessScreen();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner about images
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'E’lon admin tomonidan tasdiqlangandan keyin ko‘rinadi. Rasm qo‘shish keyingi bosqichda ulanadi.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_submitErrorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _submitErrorMessage!,
                  style: TextStyle(color: Colors.red[800], fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'E’lon tafsilotlari',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<Category>(
              decoration: const InputDecoration(
                labelText: 'Kategoriya *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              hint: const Text('Kategoriyani tanlang'),
              initialValue: _selectedCategory,
              items: _categories.map((Category cat) {
                return DropdownMenuItem<Category>(
                  value: cat,
                  child: Text(cat.nameUz),
                );
              }).toList(),
              validator: (val) => val == null ? 'Kategoriyani tanlash majburiy' : null,
              onChanged: (Category? newCat) {
                setState(() {
                  _selectedCategory = newCat;
                });
              },
            ),
            const SizedBox(height: 16),

            // Listing Type Display
            if (_selectedCategory != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.label_outline, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'E’lon turi (kategoriyaga qarab)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getTypeLabel(_selectedCategory!.type),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'E’lon sarlavhasi *',
                hintText: 'Masalan: Samarqand qizil pomidori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Sarlavha yozish majburiy';
                }
                if (val.trim().length < 3) {
                  return 'Kamida 3 ta belgi kiriting';
                }
                if (val.trim().length > 120) {
                  return 'Ko‘pi bilan 120 ta belgi kiriting';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Tafsilotlar / Tavsif',
                hintText: 'E’lon haqida batafsil ma’lumot bering (nav, holat va hokazo)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (val) {
                if (val != null && val.trim().length > 2000) {
                  return 'Ko‘pi bilan 2000 ta belgi kiriting';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price & Currency & Unit
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  key: const ValueKey('priceAmountKey'),
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Narxi',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty) {
                        final numValue = double.tryParse(val.trim());
                        if (numValue == null) {
                          return 'Noto‘g‘ri son format';
                        }
                        if (numValue <= 0) {
                          return 'Narx 0 dan katta bo‘lsin';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

            // Unit
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'O‘lchov birligi',
                hintText: 'Masalan: kg, dona, soat, kun',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale_outlined),
              ),
              validator: (val) {
                if (val != null && val.trim().length > 30) {
                  return 'Ko‘pi bilan 30 ta belgi kiriting';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Manzil va Aloqa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Region Dropdown
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

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Manzil',
                hintText: 'Masalan: Oqdaryo tumani, Dahbed qo‘rg‘oni',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map_outlined),
              ),
              validator: (val) {
                if (val != null && val.trim().length > 255) {
                  return 'Ko‘pi bilan 255 ta belgi kiriting';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone
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
                if (val != null && val.trim().isNotEmpty) {
                  final reg = RegExp(r'^\+998\d{9}$');
                  if (!reg.hasMatch(val.trim())) {
                    return 'Telefon formati xato (masalan: +998901234567)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            AppButton(
              label: 'E’lonni yuborish',
              fullWidth: true,
              loading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submitForm,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Muvaffaqiyatli yuborildi!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'E’lon yuborildi. Admin tasdiqlaganidan keyin ommaga ko‘rinadi.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Rasm qo‘shish',
              fullWidth: true,
              onPressed: () => context.go('/listings/${_createdListing!.id}/images'),
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
        ),
      ),
    );
  }
}
