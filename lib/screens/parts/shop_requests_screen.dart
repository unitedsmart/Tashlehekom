import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/models/part_request_model.dart';
import 'package:tashlehekomv2/models/offer_model.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/services/part_request_service.dart';

/// شاشة الطلبات لأصحاب التشاليح
class ShopRequestsScreen extends StatefulWidget {
  const ShopRequestsScreen({super.key});

  @override
  State<ShopRequestsScreen> createState() => _ShopRequestsScreenState();
}

class _ShopRequestsScreenState extends State<ShopRequestsScreen> {
  final _partRequestService = PartRequestService();
  String? _selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات قطع الغيار'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showCityFilter,
          ),
        ],
      ),
      body: StreamBuilder<List<PartRequest>>(
        stream: _partRequestService.getActiveRequests(city: _selectedCity),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) => _buildRequestCard(requests[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات نشطة',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          if (_selectedCity != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _selectedCity = null),
              child: const Text('إزالة الفلتر'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestCard(PartRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Part name
            Text(
              request.partName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Car info
            Row(
              children: [
                const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${request.carBrand} ${request.carModel}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                if (request.carYear != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      request.carYear!,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),

            // City
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(request.city, style: TextStyle(color: Colors.grey[600])),
              ],
            ),

            // Description
            if (request.partDescription != null) ...[
              const SizedBox(height: 8),
              Text(
                request.partDescription!,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                // Offers count
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${request.offersCount} عرض',
                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                  ),
                ),
                const Spacer(),
                // Send offer button
                ElevatedButton.icon(
                  onPressed: () => _showSendOfferDialog(request),
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('إرسال عرض'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCityFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'فلترة حسب المدينة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('جميع المدن'),
              selected: _selectedCity == null,
              onTap: () {
                setState(() => _selectedCity = null);
                Navigator.pop(context);
              },
            ),
            ...['الرياض', 'جدة', 'الدمام', 'مكة المكرمة', 'المدينة المنورة']
                .map((city) => ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text(city),
                      selected: _selectedCity == city,
                      onTap: () {
                        setState(() => _selectedCity = city);
                        Navigator.pop(context);
                      },
                    )),
          ],
        ),
      ),
    );
  }

  void _showSendOfferDialog(PartRequest request) {
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final warrantyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إرسال عرض - ${request.partName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'السعر (ريال)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'وصف العرض (اختياري)',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: warrantyController,
                decoration: const InputDecoration(
                  labelText: 'الضمان (اختياري)',
                  hintText: 'مثال: 6 أشهر',
                  prefixIcon: Icon(Icons.security),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => _submitOffer(
              request,
              priceController.text,
              descController.text,
              warrantyController.text,
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOffer(
    PartRequest request,
    String priceText,
    String description,
    String warranty,
  ) async {
    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى إدخال سعر صحيح'), backgroundColor: Colors.red),
      );
      return;
    }

    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    Navigator.pop(context);

    final offer = Offer(
      id: '',
      requestId: request.id,
      shopId: user.id,
      shopName: user.username,
      shopPhone: user.phoneNumber,
      isVerified: user.isApproved,
      price: price,
      description: description.isEmpty ? null : description,
      warranty: warranty.isEmpty ? null : warranty,
      createdAt: DateTime.now(),
    );

    await _partRequestService.createOffer(offer);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال عرضك بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
