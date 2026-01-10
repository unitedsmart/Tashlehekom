import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/services/firebase_firestore_service.dart';
import 'package:tashlehekomv2/models/car_model.dart';
import 'package:tashlehekomv2/services/favorites_service.dart';
import 'package:tashlehekomv2/widgets/car_card.dart';
import 'package:tashlehekomv2/screens/car/car_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // إعادة بناء الـ StreamBuilder
            },
          ),
        ],
      ),
      body: Consumer<FirebaseAuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'يجب تسجيل الدخول أولاً',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<List<CarModel>>(
            future: _firestoreService
                .getUserFavorites(authProvider.currentUser!.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'خطأ في تحميل البيانات: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {}); // إعادة بناء الـ FutureBuilder
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              final favoriteCars = snapshot.data ?? [];

              if (favoriteCars.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد سيارات مفضلة',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ابدأ بإضافة السيارات التي تعجبك للمفضلة',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {}); // إعادة بناء الـ FutureBuilder
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: favoriteCars.length,
                  itemBuilder: (context, index) {
                    final car = favoriteCars[index];
                    return CarCard(
                      car: car,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CarDetailsScreen(car: car),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
