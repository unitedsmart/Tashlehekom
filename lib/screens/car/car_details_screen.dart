import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tashlehekomv2/models/car_model.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/screens/auth/login_screen.dart';
import 'package:tashlehekomv2/widgets/rating_display.dart';
import 'package:tashlehekomv2/widgets/firebase_image_widget.dart';
import 'package:tashlehekomv2/services/database_service.dart';
import 'package:tashlehekomv2/services/favorites_service.dart';
import 'package:tashlehekomv2/services/firebase_firestore_service.dart';

class CarDetailsScreen extends StatefulWidget {
  final CarModel car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final isFavorite = await _favoritesService.isFavorite(
        authProvider.currentUser!.id,
        widget.car.id,
      );
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      bool success;
      if (_isFavorite) {
        success = await _favoritesService.removeFromFavorites(
          authProvider.currentUser!.id,
          widget.car.id,
        );
      } else {
        success = await _favoritesService.addToFavorites(
          authProvider.currentUser!.id,
          widget.car.id,
        );
      }

      if (success && mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite
                ? 'تم إضافة السيارة للمفضلة'
                : 'تم إزالة السيارة من المفضلة'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ، يرجى المحاولة مرة أخرى'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.car.brand} ${widget.car.model}'),
        actions: [
          Consumer<FirebaseAuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.currentUser == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: _isLoadingFavorite
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : null,
                      ),
                onPressed: _isLoadingFavorite ? null : _toggleFavorite,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            if (widget.car.images.isNotEmpty) ...[
              CarImageCarousel(
                imageUrls: widget.car.images,
                height: 250,
                showIndicators: true,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
              ),
            ],

            // Car details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    '${widget.car.brand} ${widget.car.model}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Details card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تفاصيل السيارة',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('الماركة', widget.car.brand),
                          _buildDetailRow('الموديل', widget.car.model),
                          _buildDetailRow(
                            'سنة الصنع',
                            widget.car.manufacturingYears.join(', '),
                          ),
                          if (widget.car.color != null)
                            _buildDetailRow('اللون', widget.car.color!),
                          _buildDetailRow('المدينة', widget.car.city),
                          _buildDetailRow(
                            'تاريخ الإضافة',
                            _formatDate(widget.car.createdAt),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Seller info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'معلومات البائع',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                widget.car.sellerName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                widget.car.city,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Rating display
                  RatingDisplay(
                    sellerId: widget.car.sellerId,
                    sellerName: widget.car.sellerName,
                  ),

                  const SizedBox(height: 24),

                  // Contact buttons (only for logged in users)
                  Consumer<FirebaseAuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.currentUser == null) {
                        return Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'يجب تسجيل الدخول للتواصل مع البائع',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('تسجيل الدخول'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Call button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _makePhoneCall(widget.car.sellerId),
                              icon: const Icon(Icons.phone),
                              label: const Text('اتصال'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // WhatsApp button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _openWhatsApp(widget.car.sellerId),
                              icon: const Icon(Icons.chat, color: Colors.green),
                              label: const Text('واتساب'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: const BorderSide(color: Colors.green),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Location button
                          if (widget.car.latitude != null &&
                              widget.car.longitude != null)
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: () => _openLocation(),
                                icon: const Icon(Icons.location_on),
                                label: const Text('عرض الموقع'),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  Future<void> _makePhoneCall(String sellerId) async {
    try {
      // الحصول على بيانات البائع من Firebase
      final seller = await FirebaseFirestoreService().getUser(sellerId);

      if (!mounted) return;

      if (seller != null && seller.phoneNumber.isNotEmpty) {
        final phoneNumber = seller.phoneNumber;
        final uri = Uri.parse('tel:$phoneNumber');

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('لا يمكن فتح تطبيق الهاتف'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('رقم الهاتف غير متوفر'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء محاولة الاتصال'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String sellerId) async {
    try {
      // الحصول على بيانات البائع من Firebase
      final seller = await FirebaseFirestoreService().getUser(sellerId);

      if (!mounted) return;

      if (seller != null && seller.phoneNumber.isNotEmpty) {
        // تنسيق رقم الهاتف للواتساب (إزالة الصفر الأول وإضافة رمز البلد)
        String phoneNumber = seller.phoneNumber;
        if (phoneNumber.startsWith('0')) {
          phoneNumber = '966${phoneNumber.substring(1)}';
        } else if (phoneNumber.startsWith('+966')) {
          phoneNumber = phoneNumber.substring(1);
        }

        final message =
            'مرحباً، أنا مهتم بسيارة ${widget.car.brand} ${widget.car.model}';
        final uri = Uri.parse(
          'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
        );

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('لا يمكن فتح تطبيق الواتساب'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('رقم الهاتف غير متوفر'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء محاولة فتح الواتساب'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openLocation() async {
    // if (widget.car.latitude != null && widget.car.longitude != null) {
    //   final uri = Uri.parse(
    //     'https://www.google.com/maps/search/?api=1&query=${widget.car.latitude},${widget.car.longitude}',
    //   );

    //   if (await canLaunchUrl(uri)) {
    //     await launchUrl(uri, mode: LaunchMode.externalApplication);
    //   } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة الخرائط ستكون متاحة قريباً'),
        backgroundColor: Colors.blue,
      ),
    );
    //   }
    // }
  }
}
