import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/providers/car_provider.dart';
import 'package:tashlehekomv2/services/image_service.dart';
import 'package:tashlehekomv2/screens/auth/login_screen.dart';
import 'package:tashlehekomv2/widgets/searchable_list_modal.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _vinController = TextEditingController();

  String? _selectedBrand;
  String? _selectedCity;
  List<int> _selectedYears = [];
  List<File> _selectedImages = [];
  File? _vinImage;
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  final ImageService _imageService = ImageService();

  final List<int> _availableYears = List.generate(
    DateTime.now().year - 1980 + 1,
    (index) => DateTime.now().year - index,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      carProvider.loadCarBrands();
      carProvider.loadCities();
    });
  }

  @override
  void dispose() {
    _modelController.dispose();
    _colorController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة سيارة'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brand selection (searchable)
              Consumer<CarProvider>(
                builder: (context, carProvider, child) {
                  return FormField<String>(
                    validator: (_) {
                      if (_selectedBrand == null || _selectedBrand!.isEmpty) {
                        return 'يرجى اختيار ماركة السيارة';
                      }
                      return null;
                    },
                    builder: (state) => InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => SearchableListModal(
                            title: 'اختر ماركة السيارة',
                            items: carProvider.carBrands,
                            selectedItem: _selectedBrand,
                            onItemSelected: (val) {
                              setState(() {
                                _selectedBrand = val;
                              });
                              state.didChange(val);
                              Navigator.pop(context);
                            },
                            allItemsText: 'جميع الماركات',
                            searchHint: 'ابحث عن الماركة...',
                          ),
                        );
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'ماركة السيارة *',
                          prefixIcon: Icon(Icons.directions_car),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ).copyWith(errorText: state.errorText),
                        child: Text(
                          _selectedBrand ?? 'اختر ماركة السيارة',
                          style: _selectedBrand == null
                              ? TextStyle(color: Colors.grey[600])
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Model field
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'موديل السيارة *',
                  prefixIcon: Icon(Icons.car_rental),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال موديل السيارة';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Manufacturing years selection
              InkWell(
                onTap: _showYearPicker,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'سنة الصنع *',
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    errorText:
                        _selectedYears.isEmpty ? 'يرجى اختيار سنة الصنع' : null,
                  ),
                  child: Text(
                    _selectedYears.isEmpty
                        ? 'اختر سنة الصنع'
                        : _selectedYears.join(', '),
                    style: _selectedYears.isEmpty
                        ? TextStyle(color: Colors.grey[600])
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Color field (optional)
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'لون السيارة (اختياري)',
                  prefixIcon: Icon(Icons.palette),
                ),
              ),

              const SizedBox(height: 16),

              // City selection (searchable)
              Consumer<CarProvider>(
                builder: (context, carProvider, child) {
                  return FormField<String>(
                    validator: (_) {
                      if (_selectedCity == null || _selectedCity!.isEmpty) {
                        return 'يرجى اختيار المدينة';
                      }
                      return null;
                    },
                    builder: (state) => InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => SearchableListModal(
                            title: 'اختر المدينة',
                            items: carProvider.cities,
                            selectedItem: _selectedCity,
                            onItemSelected: (val) {
                              setState(() {
                                _selectedCity = val;
                              });
                              state.didChange(val);
                              Navigator.pop(context);
                            },
                            allItemsText: 'جميع المدن',
                            searchHint: 'ابحث عن المدينة...',
                          ),
                        );
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'المدينة *',
                          prefixIcon: Icon(Icons.location_on),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ).copyWith(errorText: state.errorText),
                        child: Text(
                          _selectedCity ?? 'اختر المدينة',
                          style: _selectedCity == null
                              ? TextStyle(color: Colors.grey[600])
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // VIN number field (optional)
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهيكل (اختياري)',
                  prefixIcon: Icon(Icons.confirmation_number),
                  helperText: '17 خانة من الأرقام والحروف',
                ),
                maxLength: 17,
                onChanged: (value) {
                  if (value.length == 17) {
                    // VIN image becomes required
                    setState(() {});
                  }
                },
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 17) {
                    return 'رقم الهيكل يجب أن يكون 17 خانة';
                  }
                  return null;
                },
              ),

              // VIN image (required if VIN is entered)
              if (_vinController.text.length == 17) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickVinImage,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _vinImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _vinImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 32, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'صورة رقم الهيكل *',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Car images
              const Text(
                'صور السيارة *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Add image button
                    InkWell(
                      onTap: _pickCarImages,
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 32, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'إضافة صورة',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Selected images
                    ..._selectedImages.map((image) => Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  image,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.remove(image);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              if (_selectedImages.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'يجب إضافة صورة واحدة على الأقل',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Upload progress indicator
              if (_isLoading) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _uploadStatus,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(_uploadProgress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Upload progress indicator
              if (_isLoading) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.cloud_upload,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _uploadStatus.isEmpty
                                  ? 'جاري المعالجة...'
                                  : _uploadStatus,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.blue.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(_uploadProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitCar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoading ? Colors.grey : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_uploadStatus.isEmpty
                              ? 'جاري الإضافة...'
                              : 'جاري الرفع...'),
                        ],
                      )
                    : const Text(
                        'إضافة السيارة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showYearPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر سنة الصنع'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return ListView(
                children: _availableYears
                    .map((year) => CheckboxListTile(
                          title: Text(year.toString()),
                          value: _selectedYears.contains(year),
                          onChanged: (selected) {
                            setDialogState(() {
                              if (selected == true) {
                                _selectedYears.add(year);
                              } else {
                                _selectedYears.remove(year);
                              }
                              _selectedYears.sort((a, b) => b.compareTo(a));
                            });
                          },
                        ))
                    .toList(),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCarImages() async {
    try {
      final List<File> images = await _imageService.pickMultipleImages(
        maxImages: 10,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصور: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickVinImage() async {
    try {
      final File? image = await _imageService.pickImage(
        source: ImageSource.camera,
      );

      if (image != null) {
        setState(() {
          _vinImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التقاط صورة رقم الهيكل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitCar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedYears.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار سنة الصنع'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إضافة صورة واحدة على الأقل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_vinController.text.length == 17 && _vinImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إضافة صورة رقم الهيكل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);

    // التحقق من تسجيل الدخول
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadStatus = 'جاري رفع الصور...';
      _uploadProgress = 0.0;
    });

    final carProvider = Provider.of<CarProvider>(context, listen: false);

    try {
      // إضافة timeout للعملية كاملة
      await Future.any([
        _performUpload(authProvider, carProvider),
        Future.delayed(
            const Duration(minutes: 5),
            () => throw TimeoutException(
                'انتهت مهلة الرفع', const Duration(minutes: 5))),
      ]);
    } on TimeoutException {
      setState(() {
        _isLoading = false;
        _uploadStatus = '';
        _uploadProgress = 0.0;
      });

      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            icon: const Icon(
              Icons.access_time,
              color: Colors.orange,
              size: 64,
            ),
            title: const Text(
              'انتهت مهلة الرفع',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'استغرق رفع البيانات وقتاً أطول من المتوقع. يرجى التحقق من الاتصال والمحاولة مرة أخرى.',
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      }
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
        _uploadStatus = '';
        _uploadProgress = 0.0;
      });

      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            icon: const Icon(
              Icons.error,
              color: Colors.red,
              size: 64,
            ),
            title: const Text(
              'خطأ في الرفع',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'حدث خطأ أثناء رفع البيانات:\n$e',
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _performUpload(
      FirebaseAuthProvider authProvider, CarProvider carProvider) async {
    try {
      // رفع صور السيارة إلى Firebase Storage
      final String carId = DateTime.now().millisecondsSinceEpoch.toString();
      final String basePath = 'cars/$carId';

      setState(() {
        _uploadStatus = 'جاري رفع صور السيارة...';
      });

      final List<String> imageUrls = await _imageService.uploadMultipleImages(
        _selectedImages,
        basePath,
        onProgress: (index, progress) {
          setState(() {
            _uploadProgress = (index + progress) / _selectedImages.length;
            _uploadStatus =
                'جاري رفع الصورة ${index + 1} من ${_selectedImages.length}...';
          });
        },
      );

      // رفع صورة رقم الهيكل إذا كانت موجودة
      String? vinImageUrl;
      if (_vinImage != null) {
        setState(() {
          _uploadStatus = 'جاري رفع صورة رقم الهيكل...';
        });

        vinImageUrl = await _imageService.uploadImage(
          _vinImage!,
          '$basePath/vin_image.jpg',
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );
      }

      setState(() {
        _uploadStatus = 'جاري حفظ بيانات السيارة...';
        _uploadProgress = 1.0;
      });

      final success = await carProvider.addCar(
        sellerId: authProvider.currentUser!.id,
        sellerName: authProvider.currentUser!.username,
        brand: _selectedBrand!,
        model: _modelController.text,
        manufacturingYears: _selectedYears,
        color: _colorController.text.isEmpty ? null : _colorController.text,
        city: _selectedCity!,
        vinNumber: _vinController.text.isEmpty ? null : _vinController.text,
        vinImage: vinImageUrl,
        images: imageUrls,
      );

      setState(() {
        _isLoading = false;
        _uploadStatus = '';
        _uploadProgress = 0.0;
      });

      if (mounted) {
        if (success) {
          // إظهار رسالة نجاح مع تأكيد
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                title: const Text(
                  'تم بنجاح!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تم إضافة السيارة بنجاح',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ستتم مراجعة السيارة من قبل الإدارة قبل النشر',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // إغلاق الحوار أولاً
                      Navigator.of(context).pop();

                      // العودة للشاشة الرئيسية بدلاً من pop
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('موافق'),
                  ),
                ],
              );
            },
          );
        } else {
          // إظهار رسالة خطأ مع خيارات
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                icon: const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 64,
                ),
                title: const Text(
                  'حدث خطأ',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  'حدث خطأ في إضافة السيارة. يرجى المحاولة مرة أخرى.',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إعادة المحاولة'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // إغلاق الحوار أولاً
                      Navigator.of(context).pop();

                      // العودة للشاشة الرئيسية
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('إلغاء'),
                  ),
                ],
              );
            },
          );
        }
      }
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
        _uploadStatus = '';
        _uploadProgress = 0.0;
      });

      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            icon: const Icon(
              Icons.error,
              color: Colors.red,
              size: 64,
            ),
            title: const Text(
              'خطأ في الرفع',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'حدث خطأ أثناء رفع البيانات:\n$e',
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      }
    }
  }
}
