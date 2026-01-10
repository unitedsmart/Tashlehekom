import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/car_model.dart';
import '../../providers/car_provider.dart';
import '../../widgets/searchable_list_modal.dart';

class AdvancedFilterScreen extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const AdvancedFilterScreen({
    super.key,
    this.initialFilters,
  });

  @override
  State<AdvancedFilterScreen> createState() => _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState extends State<AdvancedFilterScreen> {
  // Filter controllers
  String? selectedBrand;
  String? selectedModel;
  String? selectedCity;
  String? selectedColor;
  RangeValues? priceRange;
  List<String> selectedYears = [];
  bool hasVinNumber = false;
  bool showVinOnly = false;

  // Data lists
  final List<String> brands = [
    'تويوتا',
    'هوندا',
    'نيسان',
    'هيونداي',
    'كيا',
    'مازدا',
    'سوبارو',
    'ميتسوبيشي',
    'إنفينيتي',
    'لكزس',
    'أكورا',
    'جينيسيس',
    'فورد',
    'شيفروليه',
    'جي إم سي',
    'كاديلاك',
    'بويك',
    'لينكولن',
    'كرايسلر',
    'دودج',
    'جيب',
    'رام',
    'بي إم دبليو',
    'مرسيدس بنز',
    'أودي',
    'فولكس واجن',
    'بورش',
    'ميني',
    'فولفو',
    'ساب',
    'جاكوار',
    'لاند روفر'
  ];

  final List<String> cities = [
    'الرياض',
    'جدة',
    'مكة المكرمة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'الطائف',
    'تبوك',
    'بريدة',
    'خميس مشيط',
    'حائل',
    'نجران',
    'جازان',
    'ينبع',
    'القطيف',
    'عرعر',
    'سكاكا'
  ];

  final List<String> colors = [
    'أبيض',
    'أسود',
    'فضي',
    'رمادي',
    'أحمر',
    'أزرق',
    'أخضر',
    'بني',
    'ذهبي',
    'برتقالي',
    'أصفر',
    'بنفسجي',
    'وردي'
  ];

  final List<String> years = List.generate(
    DateTime.now().year - 1990 + 1,
    (index) => (1990 + index).toString(),
  ).reversed.toList();

  @override
  void initState() {
    super.initState();
    _loadInitialFilters();
    // Ensure lists are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      if (carProvider.carBrands.isEmpty) carProvider.loadCarBrands();
      if (carProvider.cities.isEmpty) carProvider.loadCities();
    });
  }

  void _loadInitialFilters() {
    if (widget.initialFilters != null) {
      selectedBrand = widget.initialFilters!['brand'];
      selectedModel = widget.initialFilters!['model'];
      selectedCity = widget.initialFilters!['city'];
      selectedColor = widget.initialFilters!['color'];
      priceRange = widget.initialFilters!['priceRange'];
      selectedYears = List<String>.from(widget.initialFilters!['years'] ?? []);
      hasVinNumber = widget.initialFilters!['hasVinNumber'] ?? false;
      showVinOnly = widget.initialFilters!['showVinOnly'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.filter),
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              localizations.clearFilter,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Filter
            _buildSectionTitle(localizations.brand),
            Consumer<CarProvider>(
              builder: (context, carProvider, _) {
                return _buildSearchablePicker(
                  value: selectedBrand,
                  hint: languageProvider.isArabic
                      ? 'اختر الماركة'
                      : 'Select Brand',
                  icon: Icons.directions_car,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => SearchableListModal(
                        title: languageProvider.isArabic
                            ? 'اختر الماركة'
                            : 'Select Brand',
                        items: carProvider.carBrands,
                        selectedItem: selectedBrand,
                        onItemSelected: (val) {
                          setState(() {
                            selectedBrand = val;
                            selectedModel = null;
                          });
                          Navigator.pop(context);
                        },
                        allItemsText: languageProvider.isArabic
                            ? 'جميع الماركات'
                            : 'All Brands',
                        searchHint: languageProvider.isArabic
                            ? 'ابحث عن الماركة...'
                            : 'Search brand...',
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Model Filter (if brand is selected)
            if (selectedBrand != null) ...[
              _buildSectionTitle(localizations.model),
              Consumer<CarProvider>(
                builder: (context, carProvider, _) {
                  return _buildSearchablePicker(
                    value: selectedModel,
                    hint: languageProvider.isArabic
                        ? 'اختر الموديل'
                        : 'Select Model',
                    icon: Icons.car_rental,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => SearchableListModal(
                          title: languageProvider.isArabic
                              ? 'اختر الموديل'
                              : 'Select Model',
                          items: carProvider.models,
                          selectedItem: selectedModel,
                          onItemSelected: (val) {
                            setState(() => selectedModel = val);
                            Navigator.pop(context);
                          },
                          allItemsText: languageProvider.isArabic
                              ? 'جميع الموديلات'
                              : 'All Models',
                          searchHint: languageProvider.isArabic
                              ? 'ابحث عن الموديل...'
                              : 'Search model...',
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // City Filter
            _buildSectionTitle(localizations.city),
            Consumer<CarProvider>(
              builder: (context, carProvider, _) {
                return _buildSearchablePicker(
                  value: selectedCity,
                  hint: languageProvider.isArabic
                      ? 'اختر المدينة'
                      : 'Select City',
                  icon: Icons.location_on,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => SearchableListModal(
                        title: languageProvider.isArabic
                            ? 'اختر المدينة'
                            : 'Select City',
                        items: carProvider.cities,
                        selectedItem: selectedCity,
                        onItemSelected: (val) {
                          setState(() => selectedCity = val);
                          Navigator.pop(context);
                        },
                        allItemsText: languageProvider.isArabic
                            ? 'جميع المدن'
                            : 'All Cities',
                        searchHint: languageProvider.isArabic
                            ? 'ابحث عن المدينة...'
                            : 'Search city...',
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Color Filter
            _buildSectionTitle(localizations.color),
            _buildDropdown(
              value: selectedColor,
              items: colors,
              hint: languageProvider.isArabic ? 'اختر اللون' : 'Select Color',
              onChanged: (value) => setState(() => selectedColor = value),
            ),
            const SizedBox(height: 16),

            // Year Filter
            _buildSectionTitle(localizations.year),
            _buildYearSelector(),
            const SizedBox(height: 16),

            // Price Range Filter
            _buildSectionTitle(localizations.price),
            _buildPriceRangeSlider(),
            const SizedBox(height: 16),

            // VIN Number Filters
            _buildSectionTitle(localizations.vinNumber),
            _buildVinFilters(languageProvider),
            const SizedBox(height: 32),

            // Apply Filter Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  localizations.applyFilter,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSearchablePicker({
    required String? value,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          value ?? hint,
          style: value == null ? TextStyle(color: Colors.grey[600]) : null,
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required String? value,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildYearSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: years.take(10).map((year) {
        final isSelected = selectedYears.contains(year);
        return FilterChip(
          label: Text(year),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedYears.add(year);
              } else {
                selectedYears.remove(year);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSlider() {
    final currentRange = priceRange ?? const RangeValues(0, 100000);

    return Column(
      children: [
        RangeSlider(
          values: currentRange,
          min: 0,
          max: 500000,
          divisions: 50,
          labels: RangeLabels(
            '${currentRange.start.round()} ريال',
            '${currentRange.end.round()} ريال',
          ),
          onChanged: (values) {
            setState(() {
              priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${currentRange.start.round()} ريال'),
            Text('${currentRange.end.round()} ريال'),
          ],
        ),
      ],
    );
  }

  Widget _buildVinFilters(LanguageProvider languageProvider) {
    return Column(
      children: [
        CheckboxListTile(
          title: Text(languageProvider.isArabic
              ? 'يحتوي على رقم هيكل'
              : 'Has VIN Number'),
          value: hasVinNumber,
          onChanged: (value) {
            setState(() {
              hasVinNumber = value ?? false;
              if (!hasVinNumber) showVinOnly = false;
            });
          },
        ),
        if (hasVinNumber)
          CheckboxListTile(
            title: Text(languageProvider.isArabic
                ? 'عرض السيارات برقم هيكل فقط'
                : 'Show VIN cars only'),
            value: showVinOnly,
            onChanged: (value) {
              setState(() {
                showVinOnly = value ?? false;
              });
            },
          ),
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      selectedBrand = null;
      selectedModel = null;
      selectedCity = null;
      selectedColor = null;
      priceRange = null;
      selectedYears.clear();
      hasVinNumber = false;
      showVinOnly = false;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'brand': selectedBrand,
      'model': selectedModel,
      'city': selectedCity,
      'color': selectedColor,
      'priceRange': priceRange,
      'years': selectedYears,
      'hasVinNumber': hasVinNumber,
      'showVinOnly': showVinOnly,
    };

    Navigator.pop(context, filters);
  }
}
