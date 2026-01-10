import 'package:uuid/uuid.dart';

/// نموذج المزاد
class AuctionModel {
  final String id;
  final String carId;
  final String sellerId;
  final String title;
  final String description;
  final double startingPrice;
  final double reservePrice;
  final double currentBid;
  final String? currentBidderId;
  final DateTime startTime;
  final DateTime endTime;
  final AuctionStatus status;
  final List<String> bidderIds;
  final int totalBids;
  final bool isLive;
  final String? liveStreamUrl;
  final Map<String, dynamic> settings;
  final DateTime createdAt;

  AuctionModel({
    required this.id,
    required this.carId,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.startingPrice,
    required this.reservePrice,
    required this.currentBid,
    this.currentBidderId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.bidderIds,
    required this.totalBids,
    required this.isLive,
    this.liveStreamUrl,
    required this.settings,
    required this.createdAt,
  });

  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    return AuctionModel(
      id: json['id'],
      carId: json['carId'],
      sellerId: json['sellerId'],
      title: json['title'],
      description: json['description'],
      startingPrice: json['startingPrice'].toDouble(),
      reservePrice: json['reservePrice'].toDouble(),
      currentBid: json['currentBid'].toDouble(),
      currentBidderId: json['currentBidderId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: AuctionStatus.values[json['status']],
      bidderIds: List<String>.from(json['bidderIds']),
      totalBids: json['totalBids'],
      isLive: json['isLive'],
      liveStreamUrl: json['liveStreamUrl'],
      settings: Map<String, dynamic>.from(json['settings']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'startingPrice': startingPrice,
      'reservePrice': reservePrice,
      'currentBid': currentBid,
      'currentBidderId': currentBidderId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.index,
      'bidderIds': bidderIds,
      'totalBids': totalBids,
      'isLive': isLive,
      'liveStreamUrl': liveStreamUrl,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum AuctionStatus {
  scheduled,
  active,
  ended,
  cancelled,
  sold,
}

/// نموذج المزايدة
class BidModel {
  final String id;
  final String auctionId;
  final String bidderId;
  final double amount;
  final BidType type;
  final DateTime timestamp;
  final bool isWinning;
  final String? notes;

  BidModel({
    required this.id,
    required this.auctionId,
    required this.bidderId,
    required this.amount,
    required this.type,
    required this.timestamp,
    required this.isWinning,
    this.notes,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'],
      auctionId: json['auctionId'],
      bidderId: json['bidderId'],
      amount: json['amount'].toDouble(),
      type: BidType.values[json['type']],
      timestamp: DateTime.parse(json['timestamp']),
      isWinning: json['isWinning'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auctionId': auctionId,
      'bidderId': bidderId,
      'amount': amount,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'isWinning': isWinning,
      'notes': notes,
    };
  }
}

enum BidType {
  manual,
  automatic,
  proxy,
}

/// نموذج البث المباشر للمزاد
class LiveAuctionStream {
  final String id;
  final String auctionId;
  final String streamUrl;
  final String chatRoomId;
  final int viewerCount;
  final bool isActive;
  final DateTime startedAt;
  final DateTime? endedAt;

  LiveAuctionStream({
    required this.id,
    required this.auctionId,
    required this.streamUrl,
    required this.chatRoomId,
    required this.viewerCount,
    required this.isActive,
    required this.startedAt,
    this.endedAt,
  });
}

/// نموذج إعدادات المزاد التلقائي
class AutoBidSettings {
  final String id;
  final String userId;
  final String auctionId;
  final double maxBid;
  final double increment;
  final bool isActive;
  final DateTime createdAt;

  AutoBidSettings({
    required this.id,
    required this.userId,
    required this.auctionId,
    required this.maxBid,
    required this.increment,
    required this.isActive,
    required this.createdAt,
  });
}

/// نموذج تقرير المزاد
class AuctionReport {
  final String id;
  final String auctionId;
  final int totalBids;
  final int uniqueBidders;
  final double finalPrice;
  final String? winnerId;
  final Duration duration;
  final Map<String, int> bidderActivity;
  final List<BidModel> topBids;
  final DateTime generatedAt;

  AuctionReport({
    required this.id,
    required this.auctionId,
    required this.totalBids,
    required this.uniqueBidders,
    required this.finalPrice,
    this.winnerId,
    required this.duration,
    required this.bidderActivity,
    required this.topBids,
    required this.generatedAt,
  });
}
