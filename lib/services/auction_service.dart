import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/auction_model.dart';
import '../models/car_model.dart';

class AuctionService {
  static const String _baseUrl = 'https://api.tashlehekom.com/auctions';
  static const String _wsUrl = 'wss://api.tashlehekom.com/auctions/ws';

  /// إنشاء مزاد جديد
  static Future<AuctionModel> createAuction({
    required String carId,
    required String sellerId,
    required String title,
    required String description,
    required double startingPrice,
    required double reservePrice,
    required DateTime startTime,
    required DateTime endTime,
    required bool isLive,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final auction = AuctionModel(
        id: 'auction_${DateTime.now().millisecondsSinceEpoch}',
        carId: carId,
        sellerId: sellerId,
        title: title,
        description: description,
        startingPrice: startingPrice,
        reservePrice: reservePrice,
        currentBid: startingPrice,
        currentBidderId: null,
        startTime: startTime,
        endTime: endTime,
        status: AuctionStatus.scheduled,
        bidderIds: [],
        totalBids: 0,
        isLive: isLive,
        liveStreamUrl: isLive ? 'https://stream.tashlehekom.com/auction_${DateTime.now().millisecondsSinceEpoch}' : null,
        settings: settings ?? _getDefaultSettings(),
        createdAt: DateTime.now(),
      );

      // محاكاة حفظ في قاعدة البيانات
      await Future.delayed(const Duration(seconds: 1));
      
      return auction;
    } catch (e) {
      throw Exception('فشل في إنشاء المزاد: $e');
    }
  }

  /// الحصول على المزادات النشطة
  static Future<List<AuctionModel>> getActiveAuctions() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // محاكاة بيانات المزادات
      List<AuctionModel> auctions = [];
      final random = Random();
      
      for (int i = 0; i < 10; i++) {
        auctions.add(AuctionModel(
          id: 'auction_$i',
          carId: 'car_$i',
          sellerId: 'seller_$i',
          title: 'مزاد سيارة ${['تويوتا كامري', 'هوندا أكورد', 'نيسان التيما'][i % 3]}',
          description: 'سيارة في حالة ممتازة للبيع بالمزاد',
          startingPrice: 30000 + random.nextDouble() * 50000,
          reservePrice: 40000 + random.nextDouble() * 60000,
          currentBid: 35000 + random.nextDouble() * 55000,
          currentBidderId: random.nextBool() ? 'bidder_${random.nextInt(100)}' : null,
          startTime: DateTime.now().subtract(Duration(hours: random.nextInt(24))),
          endTime: DateTime.now().add(Duration(hours: 1 + random.nextInt(48))),
          status: AuctionStatus.active,
          bidderIds: List.generate(random.nextInt(20), (index) => 'bidder_$index'),
          totalBids: random.nextInt(50),
          isLive: random.nextBool(),
          liveStreamUrl: random.nextBool() ? 'https://stream.tashlehekom.com/auction_$i' : null,
          settings: _getDefaultSettings(),
          createdAt: DateTime.now().subtract(Duration(days: random.nextInt(7))),
        ));
      }
      
      return auctions;
    } catch (e) {
      throw Exception('فشل في جلب المزادات: $e');
    }
  }

  /// وضع مزايدة
  static Future<BidModel> placeBid({
    required String auctionId,
    required String bidderId,
    required double amount,
    BidType type = BidType.manual,
    String? notes,
  }) async {
    try {
      // التحقق من صحة المزايدة
      await _validateBid(auctionId, amount);
      
      final bid = BidModel(
        id: 'bid_${DateTime.now().millisecondsSinceEpoch}',
        auctionId: auctionId,
        bidderId: bidderId,
        amount: amount,
        type: type,
        timestamp: DateTime.now(),
        isWinning: true, // سيتم تحديثها بناءً على المزايدات الأخرى
        notes: notes,
      );

      // محاكاة حفظ المزايدة
      await Future.delayed(const Duration(milliseconds: 500));
      
      // إشعار المزايدين الآخرين
      await _notifyOtherBidders(auctionId, bidderId, amount);
      
      return bid;
    } catch (e) {
      throw Exception('فشل في وضع المزايدة: $e');
    }
  }

  /// الحصول على تاريخ المزايدات
  static Future<List<BidModel>> getAuctionBids(String auctionId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      List<BidModel> bids = [];
      final random = Random();
      
      for (int i = 0; i < 20; i++) {
        bids.add(BidModel(
          id: 'bid_${auctionId}_$i',
          auctionId: auctionId,
          bidderId: 'bidder_${random.nextInt(50)}',
          amount: 30000 + (i * 1000) + random.nextDouble() * 500,
          type: BidType.values[random.nextInt(BidType.values.length)],
          timestamp: DateTime.now().subtract(Duration(minutes: 60 - (i * 3))),
          isWinning: i == 19, // آخر مزايدة هي الرابحة
          notes: random.nextBool() ? 'مزايدة تلقائية' : null,
        ));
      }
      
      return bids.reversed.toList();
    } catch (e) {
      throw Exception('فشل في جلب المزايدات: $e');
    }
  }

  /// إعداد المزايدة التلقائية
  static Future<AutoBidSettings> setupAutoBid({
    required String userId,
    required String auctionId,
    required double maxBid,
    required double increment,
  }) async {
    try {
      final settings = AutoBidSettings(
        id: 'auto_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        auctionId: auctionId,
        maxBid: maxBid,
        increment: increment,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      
      return settings;
    } catch (e) {
      throw Exception('فشل في إعداد المزايدة التلقائية: $e');
    }
  }

  /// بدء البث المباشر للمزاد
  static Future<LiveAuctionStream> startLiveStream(String auctionId) async {
    try {
      final stream = LiveAuctionStream(
        id: 'stream_${DateTime.now().millisecondsSinceEpoch}',
        auctionId: auctionId,
        streamUrl: 'https://stream.tashlehekom.com/auction_$auctionId',
        chatRoomId: 'chat_$auctionId',
        viewerCount: 0,
        isActive: true,
        startedAt: DateTime.now(),
      );

      await Future.delayed(const Duration(seconds: 1));
      
      return stream;
    } catch (e) {
      throw Exception('فشل في بدء البث المباشر: $e');
    }
  }

  /// إنهاء المزاد
  static Future<AuctionReport> endAuction(String auctionId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final random = Random();
      final bids = await getAuctionBids(auctionId);
      
      final report = AuctionReport(
        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
        auctionId: auctionId,
        totalBids: bids.length,
        uniqueBidders: bids.map((b) => b.bidderId).toSet().length,
        finalPrice: bids.isNotEmpty ? bids.first.amount : 0,
        winnerId: bids.isNotEmpty ? bids.first.bidderId : null,
        duration: const Duration(hours: 24),
        bidderActivity: {
          'bidder_1': 5,
          'bidder_2': 3,
          'bidder_3': 8,
        },
        topBids: bids.take(5).toList(),
        generatedAt: DateTime.now(),
      );
      
      return report;
    } catch (e) {
      throw Exception('فشل في إنهاء المزاد: $e');
    }
  }

  /// التحقق من صحة المزايدة
  static Future<void> _validateBid(String auctionId, double amount) async {
    // محاكاة التحقق من القواعد
    await Future.delayed(const Duration(milliseconds: 100));
    
    // قواعد التحقق:
    // 1. المزاد نشط
    // 2. المبلغ أعلى من المزايدة الحالية
    // 3. المستخدم مؤهل للمزايدة
    
    if (amount < 1000) {
      throw Exception('المبلغ أقل من الحد الأدنى');
    }
  }

  /// إشعار المزايدين الآخرين
  static Future<void> _notifyOtherBidders(
    String auctionId,
    String bidderId,
    double amount,
  ) async {
    // محاكاة إرسال الإشعارات
    await Future.delayed(const Duration(milliseconds: 200));
    print('تم إشعار المزايدين الآخرين بالمزايدة الجديدة: $amount');
  }

  /// الإعدادات الافتراضية للمزاد
  static Map<String, dynamic> _getDefaultSettings() {
    return {
      'bidIncrement': 500.0,
      'extendTimeOnBid': 300, // 5 دقائق
      'maxBidExtensions': 3,
      'allowAutoBid': true,
      'requireDeposit': false,
      'depositAmount': 0.0,
      'allowProxyBid': true,
      'notifyOnOutbid': true,
      'showBidderNames': false,
      'allowBidRetraction': false,
    };
  }

  /// الحصول على إحصائيات المزاد
  static Future<Map<String, dynamic>> getAuctionStats(String auctionId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final random = Random();
      
      return {
        'totalViews': 150 + random.nextInt(500),
        'uniqueViewers': 50 + random.nextInt(100),
        'watchlistAdds': 20 + random.nextInt(50),
        'averageBidTime': '2.5 دقيقة',
        'bidFrequency': '${3 + random.nextInt(7)} مزايدات/ساعة',
        'topBidderCountry': 'السعودية',
        'peakViewingTime': '20:00 - 22:00',
      };
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات المزاد: $e');
    }
  }

  /// البحث في المزادات
  static Future<List<AuctionModel>> searchAuctions({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    AuctionStatus? status,
    bool? isLive,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // محاكاة البحث
      final allAuctions = await getActiveAuctions();
      
      return allAuctions.where((auction) {
        if (query != null && !auction.title.contains(query)) return false;
        if (minPrice != null && auction.currentBid < minPrice) return false;
        if (maxPrice != null && auction.currentBid > maxPrice) return false;
        if (status != null && auction.status != status) return false;
        if (isLive != null && auction.isLive != isLive) return false;
        return true;
      }).toList();
    } catch (e) {
      throw Exception('فشل في البحث: $e');
    }
  }
}
