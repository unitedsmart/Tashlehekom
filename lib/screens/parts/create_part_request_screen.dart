import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/models/part_request_model.dart';
import 'package:tashlehekomv2/providers/car_provider.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/services/part_request_service.dart';
import 'package:tashlehekomv2/widgets/searchable_list_modal.dart';

class CreatePartRequestScreen extends StatefulWidget {
  const CreatePartRequestScreen({super.key});

  @override
  State<CreatePartRequestScreen> createState() =>
      _CreatePartRequestScreenState();
}

class _CreatePartRequestScreenState extends State<CreatePartRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _carModelController = TextEditingController();
  final _partRequestService = PartRequestService();

  String? _selectedBrand;
  String? _selectedCity;
  String? _selectedYear;
  bool _isLoading = false;

  final List<String> _years = List.generate(
    DateTime.now().year - 1990 + 1,
    (index) => (DateTime.now().year - index).toString(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      if (carProvider.carBrands.isEmpty) carProvider.loadCarBrands();
      if (carProvider.cities.isEmpty) carProvider.loadCities();
    });
  }

  @override
  void dispose() {
    _partNameController.dispose();
    _descriptionController.dispose();
    _carModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب قطعة غيار'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // معلومات السيارة
              _buildSectionTitle('معلومات السيارة'),
              const SizedBox(height: 12),

              // ماركة السيارة
              Consumer<CarProvider>(
                builder: (context, carProvider, _) => _buildSelector(
                  label: 'ماركة السيارة',
                  value: _selectedBrand,
                  items: carProvider.carBrands,
                  icon: Icons.directions_car,
                  onSelect: (val) => setState(() => _selectedBrand = val),
                ),
              ),
              const SizedBox(height: 12),

              // موديل السيارة
              TextFormField(
                controller: _carModelController,
                decoration: const InputDecoration(
                  labelText: 'موديل السيارة',
                  hintText: 'مثال: كامري، أكورد، سوناتا',
                  prefixIcon: Icon(Icons.car_repair),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),

              // سنة الصنع
              _buildSelector(
                label: 'سنة الصنع (اختياري)',
                value: _selectedYear,
                items: _years,
                icon: Icons.calendar_today,
                onSelect: (val) => setState(() => _selectedYear = val),
                isRequired: false,
              ),
              const SizedBox(height: 24),

              // معلومات القطعة
              _buildSectionTitle('معلومات القطعة المطلوبة'),
              const SizedBox(height: 12),

              // اسم القطعة
              TextFormField(
                controller: _partNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم القطعة',
                  hintText: 'مثال: فلتر زيت، بطارية، مساعدات',
                  prefixIcon: Icon(Icons.build),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),

              // وصف إضافي
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'وصف إضافي (اختياري)',
                  hintText: 'أي تفاصيل إضافية عن القطعة...',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // المدينة
              _buildSectionTitle('موقعك'),
              const SizedBox(height: 12),

              Consumer<CarProvider>(
                builder: (context, carProvider, _) => _buildSelector(
                  label: 'المدينة',
                  value: _selectedCity,
                  items: carProvider.cities,
                  icon: Icons.location_city,
                  onSelect: (val) => setState(() => _selectedCity = val),
                ),
              ),
              const SizedBox(height: 32),

              // زر الإرسال
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('إرسال الطلب', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSelector({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String) onSelect,
    bool isRequired = true,
  }) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => SearchableListModal(
            title: label,
            items: items,
            selectedItem: value,
            onItemSelected: (val) {
              if (val != null) onSelect(val);
              Navigator.pop(context);
            },
            allItemsText: 'الكل',
            searchHint: 'ابحث...',
          ),
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          errorText: isRequired && value == null ? 'مطلوب' : null,
        ),
        child: Text(
          value ?? 'اختر',
          style: TextStyle(
            color: value != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBrand == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إكمال جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider =
          Provider.of<FirebaseAuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final request = PartRequest(
        id: '',
        userId: user.id,
        userName: user.username,
        userPhone: user.phoneNumber,
        carBrand: _selectedBrand!,
        carModel: _carModelController.text.trim(),
        carYear: _selectedYear,
        partName: _partNameController.text.trim(),
        partDescription: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        city: _selectedCity!,
        createdAt: DateTime.now(),
      );

      await _partRequestService.createRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('تم إرسال طلبك بنجاح! ستتلقى عروض من التشاليح قريباً'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
