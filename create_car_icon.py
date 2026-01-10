#!/usr/bin/env python3
"""
إنشاء أيقونة سيارة لتطبيق تشليحكم
"""

from PIL import Image, ImageDraw
import os

def create_car_icon():
    """إنشاء أيقونة سيارة بتصميم جميل"""
    
    # إنشاء صورة بحجم 1024x1024 (حجم عالي الجودة)
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # ألوان التصميم
    car_color = '#2E7D32'      # أخضر داكن للسيارة
    wheel_color = '#424242'    # رمادي داكن للعجلات
    window_color = '#81C784'   # أخضر فاتح للنوافذ
    light_color = '#FFF59D'    # أصفر فاتح للأضواء
    
    # حساب المقاييس
    center_x = size // 2
    center_y = size // 2
    car_width = int(size * 0.7)
    car_height = int(size * 0.4)
    
    # رسم جسم السيارة الرئيسي
    car_left = center_x - car_width // 2
    car_right = center_x + car_width // 2
    car_top = center_y - car_height // 2
    car_bottom = center_y + car_height // 2
    
    # رسم الجسم الرئيسي للسيارة (مستطيل مدور)
    draw.rounded_rectangle(
        [car_left, car_top, car_right, car_bottom],
        radius=30,
        fill=car_color
    )
    
    # رسم مقدمة السيارة (منحنية)
    hood_width = int(car_width * 0.3)
    hood_left = car_right - hood_width
    draw.rounded_rectangle(
        [hood_left, car_top + 20, car_right + 20, car_bottom - 20],
        radius=25,
        fill=car_color
    )
    
    # رسم النوافذ
    window_margin = 40
    window_left = car_left + window_margin
    window_right = car_right - window_margin - 60
    window_top = car_top + window_margin
    window_bottom = car_bottom - window_margin
    
    # النافذة الأمامية
    draw.rounded_rectangle(
        [window_left, window_top, window_left + 120, window_bottom],
        radius=15,
        fill=window_color
    )
    
    # النافذة الخلفية
    draw.rounded_rectangle(
        [window_right - 120, window_top, window_right, window_bottom],
        radius=15,
        fill=window_color
    )
    
    # رسم العجلات
    wheel_radius = 60
    wheel_y = car_bottom - 20
    
    # العجلة الأمامية
    front_wheel_x = car_left + 80
    draw.ellipse(
        [front_wheel_x - wheel_radius, wheel_y - wheel_radius,
         front_wheel_x + wheel_radius, wheel_y + wheel_radius],
        fill=wheel_color
    )
    
    # العجلة الخلفية
    rear_wheel_x = car_right - 80
    draw.ellipse(
        [rear_wheel_x - wheel_radius, wheel_y - wheel_radius,
         rear_wheel_x + wheel_radius, wheel_y + wheel_radius],
        fill=wheel_color
    )
    
    # رسم الأضواء الأمامية
    light_radius = 25
    light_y = center_y
    light_x = car_right + 10
    
    # الضوء الأمامي العلوي
    draw.ellipse(
        [light_x - light_radius, light_y - 40 - light_radius,
         light_x + light_radius, light_y - 40 + light_radius],
        fill=light_color
    )
    
    # الضوء الأمامي السفلي
    draw.ellipse(
        [light_x - light_radius, light_y + 40 - light_radius,
         light_x + light_radius, light_y + 40 + light_radius],
        fill=light_color
    )
    
    # إضافة تفاصيل إضافية
    # خط تحت السيارة (ظل)
    shadow_y = car_bottom + 10
    draw.ellipse(
        [car_left + 50, shadow_y, car_right - 50, shadow_y + 20],
        fill=(0, 0, 0, 50)  # ظل شفاف
    )
    
    return img

def create_foreground_icon():
    """إنشاء أيقونة المقدمة للـ Adaptive Icon"""
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # نفس التصميم لكن بحجم أصغر ومتمركز
    car_color = '#2E7D32'
    wheel_color = '#424242'
    window_color = '#81C784'
    light_color = '#FFF59D'
    
    # تصغير الحجم للـ foreground
    scale = 0.6
    center_x = size // 2
    center_y = size // 2
    car_width = int(size * 0.7 * scale)
    car_height = int(size * 0.4 * scale)
    
    # نفس منطق الرسم لكن بحجم مصغر
    car_left = center_x - car_width // 2
    car_right = center_x + car_width // 2
    car_top = center_y - car_height // 2
    car_bottom = center_y + car_height // 2
    
    # رسم السيارة المصغرة
    draw.rounded_rectangle(
        [car_left, car_top, car_right, car_bottom],
        radius=int(30 * scale),
        fill=car_color
    )
    
    # مقدمة السيارة
    hood_width = int(car_width * 0.3)
    hood_left = car_right - hood_width
    draw.rounded_rectangle(
        [hood_left, car_top + int(20 * scale), car_right + int(20 * scale), car_bottom - int(20 * scale)],
        radius=int(25 * scale),
        fill=car_color
    )
    
    # النوافذ
    window_margin = int(40 * scale)
    window_left = car_left + window_margin
    window_right = car_right - window_margin - int(60 * scale)
    window_top = car_top + window_margin
    window_bottom = car_bottom - window_margin
    
    draw.rounded_rectangle(
        [window_left, window_top, window_left + int(120 * scale), window_bottom],
        radius=int(15 * scale),
        fill=window_color
    )
    
    draw.rounded_rectangle(
        [window_right - int(120 * scale), window_top, window_right, window_bottom],
        radius=int(15 * scale),
        fill=window_color
    )
    
    # العجلات
    wheel_radius = int(60 * scale)
    wheel_y = car_bottom - int(20 * scale)
    
    front_wheel_x = car_left + int(80 * scale)
    draw.ellipse(
        [front_wheel_x - wheel_radius, wheel_y - wheel_radius,
         front_wheel_x + wheel_radius, wheel_y + wheel_radius],
        fill=wheel_color
    )
    
    rear_wheel_x = car_right - int(80 * scale)
    draw.ellipse(
        [rear_wheel_x - wheel_radius, wheel_y - wheel_radius,
         rear_wheel_x + wheel_radius, wheel_y + wheel_radius],
        fill=wheel_color
    )
    
    # الأضواء
    light_radius = int(25 * scale)
    light_y = center_y
    light_x = car_right + int(10 * scale)
    
    draw.ellipse(
        [light_x - light_radius, light_y - int(40 * scale) - light_radius,
         light_x + light_radius, light_y - int(40 * scale) + light_radius],
        fill=light_color
    )
    
    draw.ellipse(
        [light_x - light_radius, light_y + int(40 * scale) - light_radius,
         light_x + light_radius, light_y + int(40 * scale) + light_radius],
        fill=light_color
    )
    
    return img

def main():
    """الدالة الرئيسية"""
    print("🚗 إنشاء أيقونة سيارة لتطبيق تشليحكم...")
    
    # إنشاء مجلد assets/images إذا لم يكن موجود
    os.makedirs('assets/images', exist_ok=True)
    
    # إنشاء الأيقونة الرئيسية
    print("📱 إنشاء الأيقونة الرئيسية...")
    main_icon = create_car_icon()
    main_icon.save('assets/images/app_icon.png', 'PNG')
    print("✅ تم حفظ: assets/images/app_icon.png")
    
    # إنشاء أيقونة المقدمة
    print("🎨 إنشاء أيقونة المقدمة...")
    foreground_icon = create_foreground_icon()
    foreground_icon.save('assets/images/app_icon_foreground.png', 'PNG')
    print("✅ تم حفظ: assets/images/app_icon_foreground.png")
    
    print("🎉 تم إنشاء جميع الأيقونات بنجاح!")
    print("🔧 الخطوة التالية: تشغيل flutter packages pub run flutter_launcher_icons:main")

if __name__ == "__main__":
    main()
