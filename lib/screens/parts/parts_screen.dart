import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/image_display_widget.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  List<Map<String, dynamic>> _parts = [];
  List<Map<String, dynamic>> _filteredParts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadParts();
  }

  Future<void> _loadParts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final parts = await DatabaseService.instance.getAllParts();
      setState(() {
        _parts = parts;
        _filteredParts = parts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل قطع الغيار: $e')),
        );
      }
    }
  }

  void _filterParts() {
    setState(() {
      _filteredParts = _parts.where((part) {
        final matchesSearch = _searchQuery.isEmpty ||
            part['part_name']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            part['compatible_cars']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            part['description']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        final matchesCity =
            _selectedCity == null || part['city'] == _selectedCity;

        return matchesSearch && matchesCity;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(
                languageProvider.isArabic ? 'قطع الغيار' : 'Spare Parts');
          },
        ),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search field
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    return TextField(
                      decoration: InputDecoration(
                        hintText: languageProvider.isArabic
                            ? 'ابحث عن قطع الغيار...'
                            : 'Search for spare parts...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _filterParts();
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                // City filter
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText:
                            languageProvider.isArabic ? 'المدينة' : 'City',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: _selectedCity,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(languageProvider.isArabic
                              ? 'جميع المدن'
                              : 'All Cities'),
                        ),
                        ...[
                          'الرياض',
                          'جدة',
                          'الدمام',
                          'مكة المكرمة',
                          'المدينة المنورة'
                        ].map((city) => DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                        _filterParts();
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Parts list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredParts.isEmpty
                    ? Center(
                        child: Consumer<LanguageProvider>(
                          builder: (context, languageProvider, child) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.build_circle_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  languageProvider.isArabic
                                      ? 'لا توجد قطع غيار متاحة'
                                      : 'No spare parts available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredParts.length,
                        itemBuilder: (context, index) {
                          final part = _filteredParts[index];
                          return _buildPartCard(part);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartCard(Map<String, dynamic> part) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Part image
                if (part['images'] != null &&
                    part['images'].toString().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 120,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ImageDisplayWidget(
                        imageUrl: _getFirstImage(part['images']),
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.build_circle,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Part name and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        part['part_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${part['price']?.toStringAsFixed(0) ?? '0'} ${languageProvider.isArabic ? 'ريال' : 'SAR'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Part number
                if (part['part_number'] != null &&
                    part['part_number'].toString().isNotEmpty)
                  Text(
                    '${languageProvider.isArabic ? 'رقم القطعة:' : 'Part Number:'} ${part['part_number']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 8),

                // Compatible cars
                Row(
                  children: [
                    Icon(Icons.directions_car,
                        size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        part['compatible_cars'] ?? '',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Condition
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    part['condition'] ?? '',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                if (part['description'] != null &&
                    part['description'].toString().isNotEmpty)
                  Text(
                    part['description'],
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),

                // Seller info and location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              part['seller_name'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.red[600]),
                        const SizedBox(width: 4),
                        Text(
                          part['city'] ?? '',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFirstImage(String imagesString) {
    try {
      // Remove brackets and quotes, then split by comma
      final cleanString = imagesString.replaceAll(RegExp(r'[\[\]"]'), '');
      final imagesList = cleanString.split(',');
      if (imagesList.isNotEmpty) {
        return imagesList.first.trim();
      }
    } catch (e) {
      // Return a default image path if parsing fails
    }
    return 'assets/images/parts/part1_1.svg'; // Default fallback
  }
}
