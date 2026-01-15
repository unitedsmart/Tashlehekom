import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/models/part_request_model.dart';
import 'package:tashlehekomv2/models/offer_model.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/services/part_request_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestOffersScreen extends StatefulWidget {
  final PartRequest request;

  const RequestOffersScreen({super.key, required this.request});

  @override
  State<RequestOffersScreen> createState() => _RequestOffersScreenState();
}

class _RequestOffersScreenState extends State<RequestOffersScreen> {
  final _partRequestService = PartRequestService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العروض المستلمة'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Request info header
          _buildRequestHeader(),

          // Offers list
          Expanded(
            child: StreamBuilder<List<Offer>>(
              stream: _partRequestService.getRequestOffers(widget.request.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final offers = snapshot.data ?? [];

                if (offers.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: offers.length,
                  itemBuilder: (context, index) =>
                      _buildOfferCard(offers[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.request.partName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.request.carBrand} ${widget.request.carModel}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد عروض بعد',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'انتظر عروض التشاليح...',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.store, color: Colors.green[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            offer.shopName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (offer.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: Colors.blue, size: 18),
                          ],
                        ],
                      ),
                      if (offer.isVerified)
                        Text(
                          'تشليح موثق',
                          style:
                              TextStyle(color: Colors.blue[600], fontSize: 12),
                        ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(offer.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offer.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(offer.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Price
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '${offer.price.toStringAsFixed(0)} ريال',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            // Description
            if (offer.description != null && offer.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(offer.description!,
                  style: TextStyle(color: Colors.grey[700])),
            ],

            // Warranty
            if (offer.warranty != null && offer.warranty!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.security, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('ضمان: ${offer.warranty}',
                      style: TextStyle(color: Colors.orange[700])),
                ],
              ),
            ],

            // Delivery info
            if (offer.deliveryInfo != null &&
                offer.deliveryInfo!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.local_shipping,
                      size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('التوصيل: ${offer.deliveryInfo}',
                      style: TextStyle(color: Colors.blue[700])),
                ],
              ),
            ],

            // Actions
            if (offer.status == OfferStatus.pending &&
                widget.request.status == PartRequestStatus.active) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptOffer(offer),
                      icon: const Icon(Icons.check),
                      label: const Text('قبول العرض'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _callShop(offer.shopPhone),
                    icon: const Icon(Icons.phone, color: Colors.green),
                  ),
                  IconButton(
                    onPressed: () => _whatsappShop(offer.shopPhone),
                    icon: const Icon(Icons.message, color: Colors.green),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OfferStatus status) {
    switch (status) {
      case OfferStatus.pending:
        return Colors.orange;
      case OfferStatus.accepted:
        return Colors.green;
      case OfferStatus.rejected:
        return Colors.red;
      case OfferStatus.expired:
        return Colors.grey;
    }
  }

  Future<void> _acceptOffer(Offer offer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد قبول العرض'),
        content: Text(
            'هل تريد قبول عرض ${offer.shopName} بقيمة ${offer.price} ريال؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('قبول'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider =
          Provider.of<FirebaseAuthProvider>(context, listen: false);
      final customerName = authProvider.currentUser?.name ?? 'العميل';
      await _partRequestService.acceptOffer(
        offer.id,
        widget.request.id,
        customerName: customerName,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم قبول العرض بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _callShop(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _whatsappShop(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
