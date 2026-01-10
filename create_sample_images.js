const fs = require('fs');
const path = require('path');

// Create a simple SVG to PNG converter function
function createCarImage(carName, color, width = 400, height = 300) {
    const svg = `
<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <linearGradient id="carGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" style="stop-color:${color};stop-opacity:1" />
            <stop offset="100%" style="stop-color:${getDarkerColor(color)};stop-opacity:1" />
        </linearGradient>
    </defs>
    
    <!-- Background -->
    <rect width="100%" height="100%" fill="#f0f0f0"/>
    
    <!-- Car Body -->
    <ellipse cx="200" cy="180" rx="150" ry="60" fill="url(#carGradient)" stroke="#333" stroke-width="2"/>
    
    <!-- Car Top -->
    <ellipse cx="200" cy="140" rx="100" ry="40" fill="url(#carGradient)" stroke="#333" stroke-width="2"/>
    
    <!-- Wheels -->
    <circle cx="120" cy="220" r="25" fill="#333" stroke="#666" stroke-width="3"/>
    <circle cx="280" cy="220" r="25" fill="#333" stroke="#666" stroke-width="3"/>
    <circle cx="120" cy="220" r="15" fill="#888"/>
    <circle cx="280" cy="220" r="15" fill="#888"/>
    
    <!-- Windows -->
    <ellipse cx="200" cy="140" rx="80" ry="25" fill="#87CEEB" opacity="0.7"/>
    
    <!-- Headlights -->
    <circle cx="70" cy="170" r="12" fill="#FFFF99" stroke="#333" stroke-width="1"/>
    <circle cx="330" cy="170" r="12" fill="#FFFF99" stroke="#333" stroke-width="1"/>
    
    <!-- Car Name -->
    <text x="200" y="50" font-family="Arial, sans-serif" font-size="24" font-weight="bold" text-anchor="middle" fill="#333">${carName}</text>
    
    <!-- Brand Logo Area -->
    <rect x="180" y="160" width="40" height="20" fill="#fff" stroke="#333" stroke-width="1" rx="5"/>
    <text x="200" y="175" font-family="Arial, sans-serif" font-size="12" text-anchor="middle" fill="#333">LOGO</text>
</svg>`;
    
    return svg;
}

function createPartImage(partName, width = 400, height = 300) {
    const svg = `
<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <linearGradient id="partGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" style="stop-color:#4CAF50;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#2E7D32;stop-opacity:1" />
        </linearGradient>
    </defs>
    
    <!-- Background -->
    <rect width="100%" height="100%" fill="#f8f8f8"/>
    
    <!-- Part Shape (Generic) -->
    <rect x="100" y="100" width="200" height="100" fill="url(#partGradient)" stroke="#333" stroke-width="2" rx="10"/>
    
    <!-- Details -->
    <circle cx="150" cy="150" r="20" fill="#666" stroke="#333" stroke-width="2"/>
    <circle cx="250" cy="150" r="20" fill="#666" stroke="#333" stroke-width="2"/>
    
    <!-- Bolts -->
    <circle cx="120" cy="120" r="5" fill="#333"/>
    <circle cx="280" cy="120" r="5" fill="#333"/>
    <circle cx="120" cy="180" r="5" fill="#333"/>
    <circle cx="280" cy="180" r="5" fill="#333"/>
    
    <!-- Part Name -->
    <text x="200" y="50" font-family="Arial, sans-serif" font-size="20" font-weight="bold" text-anchor="middle" fill="#333">${partName}</text>
    
    <!-- Part Number -->
    <text x="200" y="250" font-family="Arial, sans-serif" font-size="14" text-anchor="middle" fill="#666">قطعة أصلية</text>
    
    <!-- Quality Badge -->
    <circle cx="350" cy="50" r="30" fill="#FF9800" stroke="#F57C00" stroke-width="2"/>
    <text x="350" y="55" font-family="Arial, sans-serif" font-size="12" font-weight="bold" text-anchor="middle" fill="#fff">A+</text>
</svg>`;
    
    return svg;
}

function getDarkerColor(color) {
    const colors = {
        '#FFFFFF': '#E0E0E0', // White to Light Gray
        '#000000': '#333333', // Black to Dark Gray
        '#C0C0C0': '#A0A0A0', // Silver to Darker Silver
        '#FF0000': '#CC0000', // Red to Dark Red
        '#F0F8FF': '#D0D8DF'  // Pearl White to Light Blue Gray
    };
    return colors[color] || '#666666';
}

// Car data
const cars = [
    { name: 'تويوتا كامري 2020', color: '#FFFFFF', filename: 'car1_1.svg' },
    { name: 'هوندا أكورد 2019', color: '#000000', filename: 'car2_1.svg' },
    { name: 'نيسان التيما 2021', color: '#C0C0C0', filename: 'car3_1.svg' },
    { name: 'هيونداي إلنترا 2018', color: '#FF0000', filename: 'car4_1.svg' },
    { name: 'لكزس ES 2022', color: '#F0F8FF', filename: 'car5_1.svg' }
];

// Parts data
const parts = [
    { name: 'محرك كامل', filename: 'part1_1.svg' },
    { name: 'علبة فتيس', filename: 'part2_1.svg' },
    { name: 'مقاعد جلد', filename: 'part3_1.svg' },
    { name: 'شاشة نافيجيشن', filename: 'part4_1.svg' },
    { name: 'كمبروسر مكيف', filename: 'part5_1.svg' },
    { name: 'جنوط أصلية', filename: 'part6_1.svg' }
];

// Create directories
const carsDir = path.join('assets', 'images', 'cars');
const partsDir = path.join('assets', 'images', 'parts');

if (!fs.existsSync(carsDir)) {
    fs.mkdirSync(carsDir, { recursive: true });
}

if (!fs.existsSync(partsDir)) {
    fs.mkdirSync(partsDir, { recursive: true });
}

// Generate car images
cars.forEach(car => {
    const svg = createCarImage(car.name, car.color);
    fs.writeFileSync(path.join(carsDir, car.filename), svg);
    
    // Create a second image for each car
    const filename2 = car.filename.replace('_1.svg', '_2.svg');
    const svg2 = createCarImage(car.name + ' - منظر جانبي', car.color);
    fs.writeFileSync(path.join(carsDir, filename2), svg2);
    
    console.log(`Created car images: ${car.filename} and ${filename2}`);
});

// Generate parts images
parts.forEach(part => {
    const svg = createPartImage(part.name);
    fs.writeFileSync(path.join(partsDir, part.filename), svg);
    
    // Create a second image for each part
    const filename2 = part.filename.replace('_1.svg', '_2.svg');
    const svg2 = createPartImage(part.name + ' - تفاصيل');
    fs.writeFileSync(path.join(partsDir, filename2), svg2);
    
    console.log(`Created part images: ${part.filename} and ${filename2}`);
});

// Create header banner
const headerSvg = `
<svg width="800" height="200" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <linearGradient id="headerGradient" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" style="stop-color:#1976D2;stop-opacity:1" />
            <stop offset="50%" style="stop-color:#2196F3;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#03A9F4;stop-opacity:1" />
        </linearGradient>
    </defs>
    
    <!-- Background -->
    <rect width="100%" height="100%" fill="url(#headerGradient)"/>
    
    <!-- Cars silhouettes -->
    <ellipse cx="150" cy="120" rx="80" ry="30" fill="#fff" opacity="0.2"/>
    <ellipse cx="150" cy="100" rx="50" ry="20" fill="#fff" opacity="0.2"/>
    
    <ellipse cx="400" cy="120" rx="80" ry="30" fill="#fff" opacity="0.2"/>
    <ellipse cx="400" cy="100" rx="50" ry="20" fill="#fff" opacity="0.2"/>
    
    <ellipse cx="650" cy="120" rx="80" ry="30" fill="#fff" opacity="0.2"/>
    <ellipse cx="650" cy="100" rx="50" ry="20" fill="#fff" opacity="0.2"/>
    
    <!-- Main Text -->
    <text x="400" y="60" font-family="Arial, sans-serif" font-size="36" font-weight="bold" text-anchor="middle" fill="#fff">تشليحكم</text>
    <text x="400" y="90" font-family="Arial, sans-serif" font-size="18" text-anchor="middle" fill="#fff">أفضل مكان لبيع وشراء السيارات وقطع الغيار</text>
    
    <!-- Decorative elements -->
    <circle cx="100" cy="50" r="20" fill="#fff" opacity="0.1"/>
    <circle cx="700" cy="50" r="20" fill="#fff" opacity="0.1"/>
    <circle cx="100" cy="150" r="15" fill="#fff" opacity="0.1"/>
    <circle cx="700" cy="150" r="15" fill="#fff" opacity="0.1"/>
</svg>`;

fs.writeFileSync(path.join('assets', 'images', 'header_banner.svg'), headerSvg);

// Create app logo
const logoSvg = `
<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <linearGradient id="logoGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" style="stop-color:#FF9800;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#F57C00;stop-opacity:1" />
        </linearGradient>
    </defs>
    
    <!-- Background Circle -->
    <circle cx="100" cy="100" r="90" fill="url(#logoGradient)" stroke="#E65100" stroke-width="4"/>
    
    <!-- Car Icon -->
    <ellipse cx="100" cy="120" rx="50" ry="20" fill="#fff"/>
    <ellipse cx="100" cy="105" rx="35" ry="15" fill="#fff"/>
    
    <!-- Wheels -->
    <circle cx="75" cy="135" r="8" fill="#333"/>
    <circle cx="125" cy="135" r="8" fill="#333"/>
    
    <!-- Text -->
    <text x="100" y="70" font-family="Arial, sans-serif" font-size="20" font-weight="bold" text-anchor="middle" fill="#fff">تشليحكم</text>
    <text x="100" y="165" font-family="Arial, sans-serif" font-size="12" text-anchor="middle" fill="#fff">TASHLEHEKOM</text>
</svg>`;

fs.writeFileSync(path.join('assets', 'images', 'logo.svg'), logoSvg);

console.log('All images created successfully!');
console.log('Created:');
console.log('- 10 car images (2 for each car)');
console.log('- 12 parts images (2 for each part)');
console.log('- 1 header banner');
console.log('- 1 app logo');
