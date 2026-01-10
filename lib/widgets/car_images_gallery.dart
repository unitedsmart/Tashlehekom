import 'dart:io';

import 'package:flutter/material.dart';

import '../widgets/image_upload_widget.dart';

/// معرض صور السيارة مع إمكانية الإضافة والتعديل
class CarImagesGallery extends StatefulWidget {
  final String carId;
  final List<String> initialImages;
  final Function(List<String> images) onImagesChanged;
  final bool isEditable;
  final int maxImages;

  const CarImagesGallery({
    super.key,
    required this.carId,
    required this.initialImages,
    required this.onImagesChanged,
    this.isEditable = true,
    this.maxImages = 6,
  });

  @override
  State<CarImagesGallery> createState() => _CarImagesGalleryState();
}

class _CarImagesGalleryState extends State<CarImagesGallery> {
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  /// تحديث صورة في موضع معين
  void _updateImage(int index, String imageUrl) {
    setState(() {
      if (index < _images.length) {
        _images[index] = imageUrl;
      } else {
        _images.add(imageUrl);
      }
    });
    widget.onImagesChanged(_images);
  }

  /// حذف صورة من موضع معين
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onImagesChanged(_images);
  }

  /// عرض الصورة بحجم كامل
  void _showFullImage(String imageUrl, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, color: Colors.white, size: 48),
                                  SizedBox(height: 8),
                                  Text(
                                    'خطأ في تحميل الصورة',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Image.file(
                          File(imageUrl),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, color: Colors.white, size: 48),
                                  SizedBox(height: 8),
                                  Text(
                                    'خطأ في تحميل الصورة',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
              if (widget.isEditable)
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(index);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// عرض تأكيد الحذف
  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف الصورة'),
          content: const Text('هل أنت متأكد من حذف هذه الصورة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _removeImage(index);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'صور السيارة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // شبكة الصور
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: widget.isEditable 
              ? (_images.length < widget.maxImages ? _images.length + 1 : _images.length)
              : _images.length,
          itemBuilder: (context, index) {
            // إذا كان الفهرس أكبر من عدد الصور، عرض ويدجت الإضافة
            if (index >= _images.length) {
              return ImageUploadWidget(
                carId: widget.carId,
                imageIndex: index,
                onImageUploaded: (imageUrl) => _updateImage(index, imageUrl),
              );
            }

            // عرض الصورة الموجودة
            final imageUrl = _images[index];
            return GestureDetector(
              onTap: () => _showFullImage(imageUrl, index),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.error, color: Colors.red),
                                  ),
                                );
                              },
                            )
                          : Image.file(
                              File(imageUrl),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.error, color: Colors.red),
                                  ),
                                );
                              },
                            ),
                    ),
                    
                    // زر التعديل في وضع التحرير
                    if (widget.isEditable)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: ImageUploadWidget(
                            carId: widget.carId,
                            imageIndex: index,
                            initialImageUrl: imageUrl,
                            onImageUploaded: (newImageUrl) => _updateImage(index, newImageUrl),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        
        // معلومات إضافية
        if (widget.isEditable)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'يمكنك إضافة حتى ${widget.maxImages} صور (${_images.length}/${widget.maxImages})',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }
}
