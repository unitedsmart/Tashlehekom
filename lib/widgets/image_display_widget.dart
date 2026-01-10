import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageDisplayWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ImageDisplayWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Check if it's a placeholder
    if (_isPlaceholder(imageUrl)) {
      return _buildPlaceholder(imageUrl);
    }

    // Check if it's an SVG asset
    if (imageUrl.startsWith('assets/') && imageUrl.endsWith('.svg')) {
      return SvgPicture.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) => placeholder ?? _defaultPlaceholder(),
      );
    }

    // Check if it's a network image
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _defaultErrorWidget(),
      );
    }

    // Default to asset image
    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _defaultErrorWidget(),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        size: 64,
        color: Colors.grey,
      ),
    );
  }

  bool _isPlaceholder(String imageUrl) {
    return imageUrl.contains('placeholder') ||
        imageUrl.startsWith('car_placeholder') ||
        imageUrl.startsWith('part_placeholder');
  }

  Widget _buildPlaceholder(String placeholderType) {
    IconData icon;
    Color color;
    String label;

    // Car placeholders
    if (placeholderType.contains('car_placeholder')) {
      icon = Icons.directions_car;
      label = 'سيارة';

      if (placeholderType.contains('white')) {
        color = Colors.grey[100]!;
      } else if (placeholderType.contains('black')) {
        color = Colors.grey[800]!;
      } else if (placeholderType.contains('silver')) {
        color = Colors.grey[400]!;
      } else if (placeholderType.contains('red')) {
        color = Colors.red[300]!;
      } else if (placeholderType.contains('pearl')) {
        color = Colors.blue[50]!;
      } else {
        color = Colors.grey[300]!;
      }
    }
    // Parts placeholders
    else if (placeholderType.contains('part_placeholder')) {
      color = Colors.orange[100]!;
      label = 'قطعة غيار';

      if (placeholderType.contains('engine')) {
        icon = Icons.settings;
      } else if (placeholderType.contains('transmission')) {
        icon = Icons.build_circle;
      } else if (placeholderType.contains('seats')) {
        icon = Icons.chair;
      } else if (placeholderType.contains('screen')) {
        icon = Icons.tablet_android;
      } else if (placeholderType.contains('ac')) {
        icon = Icons.ac_unit;
      } else if (placeholderType.contains('wheels')) {
        icon = Icons.tire_repair;
      } else {
        icon = Icons.build;
      }
    }
    // Default
    else {
      icon = Icons.image;
      color = Colors.grey[300]!;
      label = 'صورة';
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: (height != null && height! > 100) ? 48 : 32,
            color: Colors.grey[600],
          ),
          if (height != null && height! > 80)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
