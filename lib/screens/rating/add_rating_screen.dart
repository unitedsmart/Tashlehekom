import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:tashlehekomv2/models/rating_model.dart';
import 'package:tashlehekomv2/providers/auth_provider.dart';
import 'package:tashlehekomv2/services/database_service.dart';

class AddRatingScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;

  const AddRatingScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  State<AddRatingScreen> createState() => _AddRatingScreenState();
}

class _AddRatingScreenState extends State<AddRatingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  double _responseSpeedRating = 3.0;
  double _cleanlinessRating = 3.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييم البائع'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seller info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تقييم البائع',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.sellerName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Response speed rating
              Text(
                'سرعة الرد',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'كيف تقيم سرعة رد البائع على استفساراتك؟',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Center(
                child: RatingBar.builder(
                  initialRating: _responseSpeedRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _responseSpeedRating = rating;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Cleanliness rating
              Text(
                'مستوى النظافة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'كيف تقيم مستوى نظافة القطع المعروضة؟',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Center(
                child: RatingBar.builder(
                  initialRating: _cleanlinessRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _cleanlinessRating = rating;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Overall rating display
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 32),
                      const SizedBox(width: 8),
                      Text(
                        'التقييم الإجمالي: ${((_responseSpeedRating + _cleanlinessRating) / 2).toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Comment field
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'تعليق (اختياري)',
                  hintText: 'شاركنا تجربتك مع هذا البائع...',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 500,
              ),
              
              const SizedBox(height: 32),
              
              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRating,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('إرسال التقييم'),
              ),
              
              const SizedBox(height: 16),
              
              // Rating guidelines
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'إرشادات التقييم',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('• كن صادقاً وعادلاً في تقييمك'),
                    const Text('• ركز على تجربتك الفعلية مع البائع'),
                    const Text('• تجنب التعليقات المسيئة أو غير المناسبة'),
                    const Text('• التقييم يساعد المشترين الآخرين في اتخاذ قرارهم'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRating() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تسجيل الدخول لإضافة تقييم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final rating = RatingModel(
        id: const Uuid().v4(),
        sellerId: widget.sellerId,
        buyerId: authProvider.currentUser!.id,
        responseSpeed: _responseSpeedRating,
        cleanliness: _cleanlinessRating,
        comment: _commentController.text.isEmpty ? null : _commentController.text,
        createdAt: DateTime.now(),
      );

      await DatabaseService.instance.createRating(rating);
      
      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال التقييم بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ في إرسال التقييم'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
