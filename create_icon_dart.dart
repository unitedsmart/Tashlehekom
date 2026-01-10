import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚗 إنشاء أيقونة سيارة لتطبيق تشليحكم...');
  
  // إنشاء الأيقونة الرئيسية
  await createMainIcon();
  
  // إنشاء أيقونة المقدمة
  await createForegroundIcon();
  
  print('✅ تم إنشاء جميع الأيقونات بنجاح!');
}

Future<void> createMainIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(1024, 1024);
  
  // رسم خلفية دائرية خضراء
  final backgroundPaint = Paint()
    ..color = const Color(0xFF4CAF50)
    ..style = PaintingStyle.fill;
  
  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2),
    480,
    backgroundPaint,
  );
  
  // رسم السيارة
  drawCar(canvas, size, 1.0);
  
  // تحويل إلى صورة
  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  
  // حفظ الملف
  final file = File('assets/images/app_icon.png');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(byteData!.buffer.asUint8List());
  
  print('✅ تم حفظ: assets/images/app_icon.png');
}

Future<void> createForegroundIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(1024, 1024);
  
  // رسم السيارة بحجم أصغر للمقدمة
  drawCar(canvas, size, 0.7);
  
  // تحويل إلى صورة
  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  
  // حفظ الملف
  final file = File('assets/images/app_icon_foreground.png');
  await file.writeAsBytes(byteData!.buffer.asUint8List());
  
  print('✅ تم حفظ: assets/images/app_icon_foreground.png');
}

void drawCar(Canvas canvas, Size size, double scale) {
  final centerX = size.width / 2;
  final centerY = size.height / 2;
  
  // ألوان التصميم
  final carPaint = Paint()
    ..color = const Color(0xFF2E7D32)
    ..style = PaintingStyle.fill;
  
  final wheelPaint = Paint()
    ..color = const Color(0xFF424242)
    ..style = PaintingStyle.fill;
  
  final windowPaint = Paint()
    ..color = const Color(0xFF81C784)
    ..style = PaintingStyle.fill;
  
  final lightPaint = Paint()
    ..color = const Color(0xFFFFF59D)
    ..style = PaintingStyle.fill;
  
  // حساب المقاييس
  final carWidth = 600 * scale;
  final carHeight = 200 * scale;
  final carLeft = centerX - carWidth / 2;
  final carRight = centerX + carWidth / 2;
  final carTop = centerY - carHeight / 2;
  final carBottom = centerY + carHeight / 2;
  
  // رسم جسم السيارة الرئيسي
  final carRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(carLeft, carTop, carWidth, carHeight),
    Radius.circular(30 * scale),
  );
  canvas.drawRRect(carRect, carPaint);
  
  // رسم مقدمة السيارة
  final hoodWidth = 120 * scale;
  final hoodRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(carRight - 20 * scale, carTop + 20 * scale, hoodWidth, carHeight - 40 * scale),
    Radius.circular(25 * scale),
  );
  canvas.drawRRect(hoodRect, carPaint);
  
  // رسم النوافذ
  final windowMargin = 30 * scale;
  final windowWidth = 100 * scale;
  final windowHeight = carHeight - 2 * windowMargin;
  
  // النافذة الأمامية
  final frontWindowRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(carLeft + windowMargin, carTop + windowMargin, windowWidth, windowHeight),
    Radius.circular(15 * scale),
  );
  canvas.drawRRect(frontWindowRect, windowPaint);
  
  // النافذة الخلفية
  final rearWindowRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(carRight - windowMargin - windowWidth - 60 * scale, carTop + windowMargin, windowWidth, windowHeight),
    Radius.circular(15 * scale),
  );
  canvas.drawRRect(rearWindowRect, windowPaint);
  
  // رسم العجلات
  final wheelRadius = 50 * scale;
  final wheelY = carBottom + 30 * scale;
  
  // العجلة الأمامية
  final frontWheelX = carLeft + 100 * scale;
  canvas.drawCircle(Offset(frontWheelX, wheelY), wheelRadius, wheelPaint);
  
  // العجلة الخلفية
  final rearWheelX = carRight - 100 * scale;
  canvas.drawCircle(Offset(rearWheelX, wheelY), wheelRadius, wheelPaint);
  
  // رسم الأضواء الأمامية
  final lightRadius = 20 * scale;
  final lightX = carRight + hoodWidth - 10 * scale;
  
  // الضوء الأمامي العلوي
  canvas.drawCircle(Offset(lightX, centerY - 30 * scale), lightRadius, lightPaint);
  
  // الضوء الأمامي السفلي
  canvas.drawCircle(Offset(lightX, centerY + 30 * scale), lightRadius, lightPaint);
  
  // رسم الأضواء الخلفية
  final redLightPaint = Paint()
    ..color = const Color(0xFFF44336)
    ..style = PaintingStyle.fill;
  
  final rearLightX = carLeft - 10 * scale;
  final rearLightRadius = 15 * scale;
  
  // الضوء الخلفي العلوي
  canvas.drawCircle(Offset(rearLightX, centerY - 30 * scale), rearLightRadius, redLightPaint);
  
  // الضوء الخلفي السفلي
  canvas.drawCircle(Offset(rearLightX, centerY + 30 * scale), rearLightRadius, redLightPaint);
}
