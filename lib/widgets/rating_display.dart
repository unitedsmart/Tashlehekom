import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/models/rating_model.dart';
import 'package:tashlehekomv2/providers/user_provider.dart';
import 'package:tashlehekomv2/screens/rating/add_rating_screen.dart';

class RatingDisplay extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  final bool showAddRatingButton;

  const RatingDisplay({
    super.key,
    required this.sellerId,
    required this.sellerName,
    this.showAddRatingButton = true,
  });

  @override
  State<RatingDisplay> createState() => _RatingDisplayState();
}

class _RatingDisplayState extends State<RatingDisplay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false)
          .loadRatingsForSeller(widget.sellerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final ratings = userProvider.ratings
            .where((rating) => rating.sellerId == widget.sellerId)
            .toList();
        
        final averageRating = userProvider.getAverageRating(widget.sellerId);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'التقييمات',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (widget.showAddRatingButton)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddRatingScreen(
                                sellerId: widget.sellerId,
                                sellerName: widget.sellerName,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('أضف تقييم'),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                if (ratings.isEmpty) ...[
                  // No ratings yet
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'لا توجد تقييمات بعد',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'كن أول من يقيم هذا البائع',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Average rating
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[700],
                              ),
                            ),
                            RatingBarIndicator(
                              rating: averageRating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction: Axis.horizontal,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${ratings.length} تقييم',
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Rating breakdown
                  _buildRatingBreakdown(ratings),
                  
                  const SizedBox(height: 16),
                  
                  // Individual ratings
                  Text(
                    'آراء العملاء',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  ...ratings.take(3).map((rating) => _buildRatingItem(rating)),
                  
                  if (ratings.length > 3)
                    TextButton(
                      onPressed: () {
                        _showAllRatings(context, ratings);
                      },
                      child: Text('عرض جميع التقييمات (${ratings.length})'),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingBreakdown(List<RatingModel> ratings) {
    final responseSpeedAvg = ratings.map((r) => r.responseSpeed).reduce((a, b) => a + b) / ratings.length;
    final cleanlinessAvg = ratings.map((r) => r.cleanliness).reduce((a, b) => a + b) / ratings.length;

    return Column(
      children: [
        _buildRatingBreakdownItem('سرعة الرد', responseSpeedAvg),
        const SizedBox(height: 8),
        _buildRatingBreakdownItem('مستوى النظافة', cleanlinessAvg),
      ],
    );
  }

  Widget _buildRatingBreakdownItem(String label, double rating) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: rating / 5,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingItem(RatingModel rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingBarIndicator(
                rating: rating.averageRating,
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 16.0,
                direction: Axis.horizontal,
              ),
              const Spacer(),
              Text(
                _formatDate(rating.createdAt),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          if (rating.comment != null) ...[
            const SizedBox(height: 8),
            Text(
              rating.comment!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
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

  void _showAllRatings(BuildContext context, List<RatingModel> ratings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'جميع التقييمات (${ratings.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: ratings.length,
                  itemBuilder: (context, index) {
                    return _buildRatingItem(ratings[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
