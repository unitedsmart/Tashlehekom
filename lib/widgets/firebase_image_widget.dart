import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Widget محسن لعرض الصور من Firebase Storage مع تحسينات الأداء
class FirebaseImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showShimmer;
  final Duration fadeInDuration;
  final Duration placeholderFadeInDuration;

  const FirebaseImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.showShimmer = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderFadeInDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    // التحقق من صحة الرابط
    if (imageUrl.isEmpty || !_isValidUrl(imageUrl)) {
      return _buildErrorWidget();
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      placeholderFadeInDuration: placeholderFadeInDuration,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: 1920,
      maxHeightDiskCache: 1080,
    );

    // إضافة BorderRadius إذا كان محدداً
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// بناء placeholder مع shimmer effect
  Widget _buildPlaceholder() {
    Widget placeholderWidget = Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );

    // إضافة shimmer effect إذا كان مفعلاً
    if (showShimmer) {
      placeholderWidget = Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          color: Colors.white,
        ),
      );
    }

    return placeholderWidget;
  }

  /// بناء error widget
  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.grey[400],
            size: (height != null && height! > 100) ? 48 : 32,
          ),
          if (height != null && height! > 80) ...[
            const SizedBox(height: 8),
            Text(
              'فشل تحميل الصورة',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// التحقق من صحة الرابط
  bool _isValidUrl(String url) {
    return url.startsWith('http://') || 
           url.startsWith('https://') ||
           url.startsWith('gs://'); // Firebase Storage URLs
  }
}

/// Widget لعرض صور السيارات مع carousel
class CarImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final bool showIndicators;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Function(int)? onPageChanged;

  const CarImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 250,
    this.showIndicators = true,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.onPageChanged,
  });

  @override
  State<CarImageCarousel> createState() => _CarImageCarouselState();
}

class _CarImageCarouselState extends State<CarImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Auto play إذا كان مفعلاً
    if (widget.autoPlay && widget.imageUrls.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (mounted && widget.autoPlay) {
        final nextIndex = (_currentIndex + 1) % widget.imageUrls.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: widget.height,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.directions_car,
            size: 64,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Image carousel
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPageChanged?.call(index);
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return FirebaseImageWidget(
                imageUrl: widget.imageUrls[index],
                width: double.infinity,
                height: widget.height,
                fit: BoxFit.cover,
              );
            },
          ),
        ),

        // Indicators
        if (widget.showIndicators && widget.imageUrls.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.imageUrls.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    entry.key,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Widget مبسط لعرض صورة واحدة للسيارة في البطاقات
class CarThumbnailWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const CarThumbnailWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return FirebaseImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      showShimmer: true,
      placeholder: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.directions_car,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}
