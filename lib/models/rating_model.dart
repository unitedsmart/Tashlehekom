class RatingModel {
  final String id;
  final String sellerId;
  final String buyerId;
  final double responseSpeed; // سرعة الرد
  final double cleanliness; // مستوى النظافة
  final String? comment;
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.responseSpeed,
    required this.cleanliness,
    this.comment,
    required this.createdAt,
  });

  double get averageRating => (responseSpeed + cleanliness) / 2;

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      id: map['id'],
      sellerId: map['seller_id'],
      buyerId: map['buyer_id'],
      responseSpeed: map['response_speed'].toDouble(),
      cleanliness: map['cleanliness'].toDouble(),
      comment: map['comment'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seller_id': sellerId,
      'buyer_id': buyerId,
      'response_speed': responseSpeed,
      'cleanliness': cleanliness,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
