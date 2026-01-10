// إنشاء أيقونات ES باستخدام Node.js
const fs = require('fs');
const path = require('path');

// إنشاء SVG للأيقونة
function createIconSVG(size) {
    const fontSize = Math.floor(size * 0.32);
    const smallFontSize = Math.floor(size * 0.07);
    const strokeWidth = Math.max(1, Math.floor(size * 0.006));
    
    return `<?xml version="1.0" encoding="UTF-8"?>
<svg width="${size}" height="${size}" viewBox="0 0 ${size} ${size}" xmlns="http://www.w3.org/2000/svg">
  <!-- خلفية بيضاء مع دائرة -->
  <circle cx="${size/2}" cy="${size/2}" r="${size/2 - size*0.08}" fill="#ffffff" stroke="#e9ecef" stroke-width="2"/>
  
  <!-- النص الرئيسي ES -->
  <text x="${size/2}" y="${size/2 - size*0.06}" font-family="Arial, sans-serif" font-size="${fontSize}" font-weight="bold" 
        text-anchor="middle" dominant-baseline="middle" fill="#295490">ES</text>
  
  <!-- النص الفرعي (للأحجام الكبيرة فقط) -->
  ${size >= 96 ? `<text x="${size/2}" y="${size/2 + size*0.22}" font-family="Arial, sans-serif" font-size="${smallFontSize}" 
        text-anchor="middle" dominant-baseline="middle" fill="#6c757d">United Saudi</text>` : ''}
  
  <!-- خط تحت النص الرئيسي -->
  <line x1="${size * 0.32}" y1="${size/2 + size*0.06}" x2="${size * 0.68}" y2="${size/2 + size*0.06}" 
        stroke="#295490" stroke-width="${strokeWidth}"/>
</svg>`;
}

// إنشاء الأيقونات
const sizes = [
    { size: 48, folder: 'mipmap-mdpi' },
    { size: 72, folder: 'mipmap-hdpi' },
    { size: 96, folder: 'mipmap-xhdpi' },
    { size: 144, folder: 'mipmap-xxhdpi' },
    { size: 192, folder: 'mipmap-xxxhdpi' }
];

console.log('🎨 إنشاء أيقونات ES - United Saudi...');

sizes.forEach(({ size, folder }) => {
    const folderPath = path.join('android', 'app', 'src', 'main', 'res', folder);
    
    // إنشاء المجلد إذا لم يكن موجوداً
    if (!fs.existsSync(folderPath)) {
        fs.mkdirSync(folderPath, { recursive: true });
    }
    
    // إنشاء SVG
    const svgContent = createIconSVG(size);
    const svgPath = path.join(folderPath, 'ic_launcher.svg');
    
    fs.writeFileSync(svgPath, svgContent);
    console.log(`✅ تم إنشاء: ${svgPath}`);
});

console.log('🎊 تم إنشاء جميع الأيقونات بنجاح!');
console.log('📝 ملاحظة: الملفات بصيغة SVG - ستعمل مع معظم أنظمة Android الحديثة');
