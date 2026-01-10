from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    # إنشاء أيقونة بناءً على الصورة المرسلة
    # خلفية بيضاء مع شعار ES (العربية السعودية)
    
    # إنشاء الأيقونة الأساسية
    size = 512
    img = Image.new('RGBA', (size, size), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)
    
    # رسم دائرة خلفية بيضاء
    margin = 20
    draw.ellipse([margin, margin, size-margin, size-margin], 
                fill=(255, 255, 255, 255), outline=(200, 200, 200, 255), width=3)
    
    # رسم النص "ES" بخط كبير وأنيق
    try:
        # محاولة استخدام خط عربي إذا كان متوفراً
        font_size = 180
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        font = ImageFont.load_default()
    
    # رسم "ES" في المنتصف
    text = "ES"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 20
    
    # رسم النص بلون أزرق داكن
    draw.text((x, y), text, fill=(41, 84, 144, 255), font=font)
    
    # إضافة نص صغير "United Saudi" أسفل ES
    try:
        small_font = ImageFont.truetype("arial.ttf", 32)
    except:
        small_font = ImageFont.load_default()
    
    subtitle = "United Saudi"
    bbox = draw.textbbox((0, 0), subtitle, font=small_font)
    subtitle_width = bbox[2] - bbox[0]
    
    x_sub = (size - subtitle_width) // 2
    y_sub = y + text_height + 20
    
    draw.text((x_sub, y_sub), subtitle, fill=(100, 100, 100, 255), font=small_font)
    
    # حفظ الأيقونة
    if not os.path.exists('assets/images'):
        os.makedirs('assets/images')
    
    img.save('assets/images/app_icon.png', 'PNG')
    
    # إنشاء أحجام مختلفة للأندرويد
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    for folder, icon_size in android_sizes.items():
        folder_path = f'android/app/src/main/res/{folder}'
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)
        
        # تغيير حجم الأيقونة
        resized_img = img.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        resized_img.save(f'{folder_path}/ic_launcher.png', 'PNG')
        
        # إنشاء أيقونة foreground للـ adaptive icons
        resized_img.save(f'{folder_path}/ic_launcher_foreground.png', 'PNG')
    
    print("✅ تم إنشاء الأيقونة الجديدة بنجاح!")
    print("📁 الملفات المحفوظة:")
    print("   - assets/images/app_icon.png")
    for folder in android_sizes.keys():
        print(f"   - android/app/src/main/res/{folder}/ic_launcher.png")

if __name__ == "__main__":
    create_app_icon()
