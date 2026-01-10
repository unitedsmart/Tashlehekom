import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';
import '../widgets/car_card.dart';
import '../widgets/search_filter_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    final carProvider = Provider.of<CarProvider>(context, listen: false);
    if (carProvider.cities.isEmpty) carProvider.loadCities();
    if (carProvider.carBrands.isEmpty) carProvider.loadCarBrands();
    if (carProvider.cars.isEmpty) carProvider.loadCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SearchFilterBar(),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<CarProvider>(
                builder: (context, carProvider, child) {
                  if (carProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  }
                  final cars = carProvider.cars;
                  if (cars.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('لا توجد نتائج',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('جرب تغيير الفلاتر أو كلمات البحث',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return CarCard(
                        car: car,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('تم اختيار ${car.brand} ${car.model}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
