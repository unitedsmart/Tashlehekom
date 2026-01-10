import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tashlehekomv2/models/car_model.dart';
import 'package:tashlehekomv2/l10n/app_localizations.dart';

class CarComparisonScreen extends StatefulWidget {
  final List<CarModel> cars;

  const CarComparisonScreen({
    super.key,
    required this.cars,
  });

  @override
  State<CarComparisonScreen> createState() => _CarComparisonScreenState();
}

class _CarComparisonScreenState extends State<CarComparisonScreen> {
  late List<CarModel> _selectedCars;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedCars = widget.cars.take(2).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.carComparison),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _selectedCars.length < 3 ? _addCarToComparison : null,
            tooltip: 'إضافة سيارة للمقارنة',
          ),
        ],
      ),
      body: _selectedCars.isEmpty ? _buildEmptyState() : _buildComparisonView(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد سيارات للمقارنة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'اختر سيارتين أو أكثر للمقارنة بينهما',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _addCarToComparison,
            child: const Text('إضافة سيارة'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // عرض السيارات المختارة
          _buildCarsHeader(),
          const Divider(),
          // جدول المقارنة
          _buildComparisonTable(),
        ],
      ),
    );
  }

  Widget _buildCarsHeader() {
    return Container(
      height: 200,
      child: Row(
        children: [
          // عمود الخصائص
          Container(
            width: 120,
            padding: const EdgeInsets.all(8),
            child: const Center(
              child: Text(
                'الخصائص',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // أعمدة السيارات
          ..._selectedCars.map((car) => Expanded(
                child: _buildCarColumn(car),
              )),
        ],
      ),
    );
  }

  Widget _buildCarColumn(CarModel car) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // صورة السيارة
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                color: Colors.grey[200],
              ),
              child: car.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      child: CachedNetworkImage(
                        imageUrl: car.images.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.directions_car, size: 40),
                        ),
                      ),
                    )
                  : const Icon(Icons.directions_car, size: 40),
            ),
          ),
          // معلومات السيارة
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${car.brand} ${car.model}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    car.sellerName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // زر الإزالة
          Container(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _removeCarFromComparison(car),
              child: const Icon(Icons.close, size: 16),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    final comparisonData = _getComparisonData();

    return Column(
      children: comparisonData.map((row) => _buildComparisonRow(row)).toList(),
    );
  }

  Widget _buildComparisonRow(Map<String, dynamic> rowData) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // عمود الخاصية
          Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            child: Text(
              rowData['property'],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          // أعمدة القيم
          ...List.generate(_selectedCars.length, (index) {
            final value = rowData['values'][index];
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  value?.toString() ?? '-',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getValueColor(
                        rowData['property'], value, rowData['values']),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getComparisonData() {
    return [
      {
        'property': 'الماركة',
        'values': _selectedCars.map((car) => car.brand).toList(),
      },
      {
        'property': 'الموديل',
        'values': _selectedCars.map((car) => car.model).toList(),
      },
      {
        'property': 'سنوات التصنيع',
        'values': _selectedCars
            .map((car) => car.manufacturingYears.isEmpty
                ? '-'
                : '${car.manufacturingYears.first}-${car.manufacturingYears.last}')
            .toList(),
      },
      {
        'property': 'اللون',
        'values': _selectedCars.map((car) => car.color ?? '-').toList(),
      },
      {
        'property': 'المدينة',
        'values': _selectedCars.map((car) => car.city).toList(),
      },
      {
        'property': 'البائع',
        'values': _selectedCars.map((car) => car.sellerName).toList(),
      },
      {
        'property': 'رقم الهيكل',
        'values': _selectedCars
            .map((car) => car.vinNumber != null ? 'متوفر' : 'غير متوفر')
            .toList(),
      },
      {
        'property': 'عدد الصور',
        'values': _selectedCars.map((car) => car.images.length).toList(),
      },
      {
        'property': 'تاريخ الإضافة',
        'values': _selectedCars
            .map((car) =>
                '${car.createdAt.day}/${car.createdAt.month}/${car.createdAt.year}')
            .toList(),
      },
    ];
  }

  Color? _getValueColor(
      String property, dynamic value, List<dynamic> allValues) {
    // تلوين القيم حسب المقارنة
    switch (property) {
      case 'عدد الصور':
        if (value is int) {
          final maxImages =
              allValues.whereType<int>().reduce((a, b) => a > b ? a : b);
          return value == maxImages ? Colors.green : null;
        }
        break;
      case 'رقم الهيكل':
        return value == 'متوفر' ? Colors.green : Colors.orange;
      default:
        return null;
    }
    return null;
  }

  void _addCarToComparison() {
    // هنا يمكن فتح شاشة اختيار السيارة
    // أو عرض قائمة السيارات المتاحة
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة سيارة'),
        content: const Text('هذه الميزة قيد التطوير'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _removeCarFromComparison(CarModel car) {
    setState(() {
      _selectedCars.remove(car);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إزالة ${car.brand} ${car.model} من المقارنة'),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {
            setState(() {
              _selectedCars.add(car);
            });
          },
        ),
      ),
    );
  }
}
