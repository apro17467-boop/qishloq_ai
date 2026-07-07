import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qishloq_ai_mobile/core/network/api_exception.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_button.dart';

class ListingImageUploadPage extends ConsumerStatefulWidget {
  final String listingId;
  final String? listingTitle;

  const ListingImageUploadPage({
    super.key,
    required this.listingId,
    this.listingTitle,
  });

  @override
  ConsumerState<ListingImageUploadPage> createState() => _ListingImageUploadPageState();
}

class _ListingImageUploadPageState extends ConsumerState<ListingImageUploadPage> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];

  bool _isUploading = false;
  String? _uploadProgressMessage;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider);
      if (!authState.isAuthenticated) {
        context.go('/login');
      }
    });
  }

  Future<void> _pickImages() async {
    if (_selectedFiles.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 5 ta rasm yuklash mumkin')),
      );
      return;
    }

    try {
      final List<XFile> pickedList = await _picker.pickMultiImage();
      if (pickedList.isEmpty) return;

      setState(() {
        _errorMessage = null;
        _successMessage = null;
      });

      for (var file in pickedList) {
        if (_selectedFiles.length >= 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Faqat birinchi 5 ta rasm tanlab olindi')),
            );
          }
          break;
        }

        // Validate extension
        final name = file.name.toLowerCase();
        if (!name.endsWith('.jpg') &&
            !name.endsWith('.jpeg') &&
            !name.endsWith('.png') &&
            !name.endsWith('.webp')) {
          setState(() {
            _errorMessage = 'Faqat JPG, PNG yoki WEBP formatidagi rasmlarni tanlash mumkin.';
          });
          continue;
        }

        // Validate size (5MB limit)
        final length = await file.length();
        if (length > 5 * 1024 * 1024) {
          setState(() {
            _errorMessage = 'Rasm hajmi 5MB dan oshmasligi lozim (${file.name}).';
          });
          continue;
        }

        setState(() {
          _selectedFiles.add(file);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Rasmlarni tanlashda xatolik yuz berdi: ${e.toString()}';
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedFiles.isEmpty) {
      setState(() {
        _errorMessage = 'Kamida bitta rasm tanlang';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    int successCount = 0;
    int totalCount = _selectedFiles.length;

    try {
      for (int i = 0; i < totalCount; i++) {
        setState(() {
          _uploadProgressMessage = '${i + 1}/$totalCount rasm yuklanmoqda...';
        });

        final file = _selectedFiles[i];
        
        await ref.read(listingServiceProvider).uploadListingImage(
          listingId: widget.listingId,
          filePath: file.path,
          fileName: file.name,
        );

        successCount++;
      }

      setState(() {
        _selectedFiles.clear();
        _successMessage = 'Barcha $successCount ta rasm muvaffaqiyatli yuklandi.';
        _isUploading = false;
        _uploadProgressMessage = null;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = 'Yuklashda xatolik: ${e.message} ($successCount/$totalCount yuklandi)';
        _isUploading = false;
        _uploadProgressMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Yuklashda xatolik yuz berdi: ${e.toString()} ($successCount/$totalCount yuklandi)';
        _isUploading = false;
        _uploadProgressMessage = null;
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
        title: const Text('Rasm qo‘shish'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isUploading ? null : () => context.go('/listings'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
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
                        'E’lon admin tasdiqlaganidan keyin ommaga ko‘rinadi. Rasmlar e’lonni yaxshiroq ko‘rsatishga yordam beradi.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (widget.listingTitle != null) ...[
                Text(
                  widget.listingTitle!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],

              // Success Alert
              if (_successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: Colors.green[800], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Error Alert
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[800], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Uploading Status
              if (_isUploading && _uploadProgressMessage != null) ...[
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        _uploadProgressMessage!,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Image Picker Section
              if (!_isUploading) ...[
                Center(
                  child: InkWell(
                    onTap: _pickImages,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!, style: BorderStyle.values[1]),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[50],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Rasm tanlash (Maks. 5 ta)',
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'JPG, PNG, WEBP (Maks 5MB)',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Image Preview List
              if (_selectedFiles.isNotEmpty) ...[
                const Text(
                  'Tanlangan rasmlar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(file.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (!_isUploading)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.red.withValues(alpha: 0.8),
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 12, color: Colors.white),
                                padding: EdgeInsets.zero,
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],

              // Actions
              if (!_isUploading) ...[
                AppButton(
                  label: 'Yuklash',
                  fullWidth: true,
                  onPressed: _selectedFiles.isEmpty ? null : _uploadImages,
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
                    child: const Text('Keyinroq / Ro‘yxatga o‘tish'),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _isUploading ? null : () => context.go('/home'),
                  child: const Text('Bosh sahifaga qaytish'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
