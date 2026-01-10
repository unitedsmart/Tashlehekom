import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/providers/car_provider.dart';
import 'package:tashlehekomv2/providers/language_provider.dart';
import 'package:tashlehekomv2/l10n/app_localizations.dart';
import 'package:tashlehekomv2/screens/search/advanced_filter_screen.dart';
import 'searchable_list_modal.dart';

class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({super.key});

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final carProvider = Provider.of<CarProvider>(context, listen: false);
    _searchController.text = carProvider.searchQuery ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search field
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: languageProvider.isArabic
                      ? 'ابحث عن السيارة أو البائع...'
                      : 'Search for car or seller...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            Provider.of<CarProvider>(context, listen: false)
                                .setSearchQuery(null);
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  Provider.of<CarProvider>(context, listen: false)
                      .setSearchQuery(value.isEmpty ? null : value);
                },
              );
            },
          ),

          const SizedBox(height: 12),

          // Filter chips
          Consumer<CarProvider>(
            builder: (context, carProvider, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // City filter
                    Consumer<LanguageProvider>(
                      builder: (context, languageProvider, child) {
                        return FilterChip(
                          label: Text(carProvider.selectedCity ??
                              (languageProvider.isArabic
                                  ? 'جميع المدن'
                                  : 'All Cities')),
                          selected: carProvider.selectedCity != null,
                          onSelected: (selected) {
                            _showCityPicker(context, carProvider);
                          },
                          avatar: const Icon(Icons.location_on, size: 16),
                        );
                      },
                    ),

                    const SizedBox(width: 8),

                    // Brand filter
                    Consumer<LanguageProvider>(
                      builder: (context, languageProvider, child) {
                        return FilterChip(
                          label: Text(carProvider.selectedBrand ??
                              (languageProvider.isArabic
                                  ? 'جميع الماركات'
                                  : 'All Brands')),
                          selected: carProvider.selectedBrand != null,
                          onSelected: (selected) {
                            _showBrandPicker(context, carProvider);
                          },
                          avatar: const Icon(Icons.directions_car, size: 16),
                        );
                      },
                    ),

                    const SizedBox(width: 8),

                    // Model filter
                    Consumer<LanguageProvider>(
                      builder: (context, languageProvider, child) {
                        final hasBrand = carProvider.selectedBrand != null;
                        return FilterChip(
                          label: Text(carProvider.selectedModel ??
                              (languageProvider.isArabic
                                  ? 'جميع الموديلات'
                                  : 'All Models')),
                          selected: carProvider.selectedModel != null,
                          onSelected: (selected) {
                            _showModelPicker(context, carProvider);
                          },
                          avatar:
                              const Icon(Icons.directions_car_filled, size: 16),
                        );
                      },
                    ),

                    const SizedBox(width: 8),

                    // Advanced Filter Button
                    Consumer<LanguageProvider>(
                      builder: (context, languageProvider, child) {
                        final localizations = AppLocalizations.of(context)!;
                        return ActionChip(
                          label: Text(localizations.filter),
                          onPressed: () =>
                              _showAdvancedFilter(context, carProvider),
                          avatar: const Icon(Icons.tune, size: 16),
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        );
                      },
                    ),

                    const SizedBox(width: 8),

                    // Clear filters
                    if (carProvider.selectedCity != null ||
                        carProvider.selectedBrand != null ||
                        carProvider.selectedModel != null ||
                        carProvider.searchQuery != null)
                      Consumer<LanguageProvider>(
                        builder: (context, languageProvider, child) {
                          final localizations = AppLocalizations.of(context)!;
                          return ActionChip(
                            label: Text(localizations.clearFilter),
                            onPressed: () {
                              _searchController.clear();
                              carProvider.clearFilters();
                            },
                            avatar: const Icon(Icons.clear, size: 16),
                          );
                        },
                      )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCityPicker(BuildContext context, CarProvider carProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SearchableListModal(
        title: 'اختر المدينة',
        items: carProvider.cities,
        selectedItem: carProvider.selectedCity,
        onItemSelected: (city) {
          carProvider.setSelectedCity(city);
          Navigator.pop(context);
        },
        allItemsText: 'جميع المدن',
        searchHint: 'ابحث عن المدينة...',
      ),
    );
  }

  void _showBrandPicker(BuildContext context, CarProvider carProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SearchableListModal(
        title: 'اختر الماركة',
        items: carProvider.carBrands,
        selectedItem: carProvider.selectedBrand,
        onItemSelected: (brand) {
          carProvider.setSelectedBrand(brand);
          Navigator.pop(context);
        },
        allItemsText: 'جميع الماركات',
        searchHint: 'ابحث عن الماركة...',
      ),
    );
  }

  void _showModelPicker(BuildContext context, CarProvider carProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SearchableListModal(
        title: 'اختر الموديل',
        items: carProvider.models,
        selectedItem: carProvider.selectedModel,
        onItemSelected: (model) {
          carProvider.setSelectedModel(model);
          Navigator.pop(context);
        },
        allItemsText: 'جميع الموديلات',
        searchHint: 'ابحث عن الموديل...',
      ),
    );
  }

  Future<void> _showAdvancedFilter(
      BuildContext context, CarProvider carProvider) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AdvancedFilterScreen(
          initialFilters: carProvider.currentFilters,
        ),
      ),
    );

    if (result != null) {
      carProvider.applyAdvancedFilters(result);
    }
  }
}
