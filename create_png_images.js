const fs = require('fs');
const path = require('path');

// Create a simple HTML canvas to PNG converter function
function createCarImageHTML(carName, color, width = 400, height = 300) {
    return `
<!DOCTYPE html>
<html>
<head>
    <style>
        body { margin: 0; padding: 20px; font-family: Arial, sans-serif; }
        .car-container { 
            width: ${width}px; 
            height: ${height}px; 
            background: linear-gradient(135deg, #f0f0f0, #e0e0e0);
            border: 2px solid #ccc;
            border-radius: 10px;
            position: relative;
            overflow: hidden;
        }
        .car-body {
            position: absolute;
            top: 120px;
            left: 50px;
            width: 300px;
            height: 120px;
            background: linear-gradient(135deg, ${color}, ${getDarkerColor(color)});
            border-radius: 60px;
            border: 3px solid #333;
        }
        .car-top {
            position: absolute;
            top: 80px;
            left: 100px;
            width: 200px;
            height: 80px;
            background: linear-gradient(135deg, ${color}, ${getDarkerColor(color)});
            border-radius: 40px;
            border: 3px solid #333;
        }
        .wheel {
            position: absolute;
            width: 50px;
            height: 50px;
            background: #333;
            border-radius: 50%;
            border: 6px solid #666;
        }
        .wheel-left { top: 195px; left: 70px; }
        .wheel-right { top: 195px; left: 280px; }
        .wheel-center {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 30px;
            height: 30px;
            background: #888;
            border-radius: 50%;
        }
        .window {
            position: absolute;
            top: 85px;
            left: 120px;
            width: 160px;
            height: 50px;
            background: rgba(135, 206, 235, 0.7);
            border-radius: 25px;
        }
        .headlight {
            position: absolute;
            width: 24px;
            height: 24px;
            background: #FFFF99;
            border-radius: 50%;
            border: 2px solid #333;
        }
        .headlight-left { top: 145px; left: 20px; }
        .headlight-right { top: 145px; left: 356px; }
        .car-name {
            position: absolute;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 24px;
            font-weight: bold;
            color: #333;
            text-align: center;
        }
        .logo {
            position: absolute;
            top: 135px;
            left: 180px;
            width: 40px;
            height: 20px;
            background: white;
            border: 2px solid #333;
            border-radius: 5px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            color: #333;
        }
    </style>
</head>
<body>
    <div class="car-container">
        <div class="car-name">${carName}</div>
        <div class="car-body"></div>
        <div class="car-top"></div>
        <div class="window"></div>
        <div class="wheel wheel-left"><div class="wheel-center"></div></div>
        <div class="wheel wheel-right"><div class="wheel-center"></div></div>
        <div class="headlight headlight-left"></div>
        <div class="headlight headlight-right"></div>
        <div class="logo">LOGO</div>
    </div>
</body>
</html>`;
}

function createPartImageHTML(partName, width = 400, height = 300) {
    return `
<!DOCTYPE html>
<html>
<head>
    <style>
        body { margin: 0; padding: 20px; font-family: Arial, sans-serif; }
        .part-container { 
            width: ${width}px; 
            height: ${height}px; 
            background: linear-gradient(135deg, #f8f8f8, #e8e8e8);
            border: 2px solid #ccc;
            border-radius: 10px;
            position: relative;
            overflow: hidden;
        }
        .part-body {
            position: absolute;
            top: 100px;
            left: 100px;
            width: 200px;
            height: 100px;
            background: linear-gradient(135deg, #4CAF50, #2E7D32);
            border: 3px solid #333;
            border-radius: 10px;
        }
        .part-detail {
            position: absolute;
            width: 40px;
            height: 40px;
            background: #666;
            border: 3px solid #333;
            border-radius: 50%;
        }
        .detail-left { top: 130px; left: 130px; }
        .detail-right { top: 130px; left: 230px; }
        .bolt {
            position: absolute;
            width: 10px;
            height: 10px;
            background: #333;
            border-radius: 50%;
        }
        .bolt1 { top: 120px; left: 120px; }
        .bolt2 { top: 120px; left: 280px; }
        .bolt3 { top: 180px; left: 120px; }
        .bolt4 { top: 180px; left: 280px; }
        .part-name {
            position: absolute;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 20px;
            font-weight: bold;
            color: #333;
            text-align: center;
        }
        .part-subtitle {
            position: absolute;
            top: 250px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 14px;
            color: #666;
            text-align: center;
        }
        .quality-badge {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 60px;
            height: 60px;
            background: #FF9800;
            border: 4px solid #F57C00;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            font-weight: bold;
            color: white;
        }
    </style>
</head>
<body>
    <div class="part-container">
        <div class="part-name">${partName}</div>
        <div class="part-body"></div>
        <div class="part-detail detail-left"></div>
        <div class="part-detail detail-right"></div>
        <div class="bolt bolt1"></div>
        <div class="bolt bolt2"></div>
        <div class="bolt bolt3"></div>
        <div class="bolt bolt4"></div>
        <div class="part-subtitle">قطعة أصلية</div>
        <div class="quality-badge">A+</div>
    </div>
</body>
</html>`;
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
    { name: 'تويوتا كامري 2020', color: '#FFFFFF', filename: 'car1_1.html' },
    { name: 'هوندا أكورد 2019', color: '#000000', filename: 'car2_1.html' },
    { name: 'نيسان التيما 2021', color: '#C0C0C0', filename: 'car3_1.html' },
    { name: 'هيونداي إلنترا 2018', color: '#FF0000', filename: 'car4_1.html' },
    { name: 'لكزس ES 2022', color: '#F0F8FF', filename: 'car5_1.html' }
];

// Parts data
const parts = [
    { name: 'محرك كامل', filename: 'part1_1.html' },
    { name: 'علبة فتيس', filename: 'part2_1.html' },
    { name: 'مقاعد جلد', filename: 'part3_1.html' },
    { name: 'شاشة نافيجيشن', filename: 'part4_1.html' },
    { name: 'كمبروسر مكيف', filename: 'part5_1.html' },
    { name: 'جنوط أصلية', filename: 'part6_1.html' }
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

// Generate car HTML files
cars.forEach(car => {
    const html = createCarImageHTML(car.name, car.color);
    fs.writeFileSync(path.join(carsDir, car.filename), html);
    
    // Create a second HTML for each car
    const filename2 = car.filename.replace('_1.html', '_2.html');
    const html2 = createCarImageHTML(car.name + ' - منظر جانبي', car.color);
    fs.writeFileSync(path.join(carsDir, filename2), html2);
    
    console.log(`Created car HTML: ${car.filename} and ${filename2}`);
});

// Generate parts HTML files
parts.forEach(part => {
    const html = createPartImageHTML(part.name);
    fs.writeFileSync(path.join(partsDir, part.filename), html);
    
    // Create a second HTML for each part
    const filename2 = part.filename.replace('_1.html', '_2.html');
    const html2 = createPartImageHTML(part.name + ' - تفاصيل');
    fs.writeFileSync(path.join(partsDir, filename2), html2);
    
    console.log(`Created part HTML: ${part.filename} and ${filename2}`);
});

console.log('All HTML files created successfully!');
console.log('Note: These are HTML files for preview. For production, convert to PNG images.');
console.log('You can open these HTML files in a browser and take screenshots to create PNG images.');
