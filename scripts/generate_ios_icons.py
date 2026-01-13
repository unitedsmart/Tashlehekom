"""
Generate iOS app icons from source image
"""
from PIL import Image
import os

# Source image path
SOURCE_IMAGE = "myphoto/new_app_icon_1024.png"

# iOS icon sizes (name, size)
IOS_ICON_SIZES = [
    ("Icon-App-20x20@1x.png", 20),
    ("Icon-App-20x20@2x.png", 40),
    ("Icon-App-20x20@3x.png", 60),
    ("Icon-App-29x29@1x.png", 29),
    ("Icon-App-29x29@2x.png", 58),
    ("Icon-App-29x29@3x.png", 87),
    ("Icon-App-40x40@1x.png", 40),
    ("Icon-App-40x40@2x.png", 80),
    ("Icon-App-40x40@3x.png", 120),
    ("Icon-App-60x60@2x.png", 120),
    ("Icon-App-60x60@3x.png", 180),
    ("Icon-App-76x76@1x.png", 76),
    ("Icon-App-76x76@2x.png", 152),
    ("Icon-App-83.5x83.5@2x.png", 167),
    ("Icon-App-1024x1024@1x.png", 1024),
]

# Output directory
OUTPUT_DIR = "ios/Runner/Assets.xcassets/AppIcon.appiconset"

def generate_icons():
    """Generate all iOS icons from source image"""
    # Check if source exists
    if not os.path.exists(SOURCE_IMAGE):
        print(f"Error: Source image not found: {SOURCE_IMAGE}")
        return False
    
    # Open source image
    source = Image.open(SOURCE_IMAGE)
    print(f"Source image: {source.size[0]}x{source.size[1]}")
    
    # Generate each size
    for filename, size in IOS_ICON_SIZES:
        output_path = os.path.join(OUTPUT_DIR, filename)
        
        # Resize with high quality
        resized = source.resize((size, size), Image.Resampling.LANCZOS)
        
        # Convert to RGB if necessary (remove alpha for iOS)
        if resized.mode == 'RGBA':
            # Create white background
            background = Image.new('RGB', resized.size, (255, 255, 255))
            background.paste(resized, mask=resized.split()[3])
            resized = background
        elif resized.mode != 'RGB':
            resized = resized.convert('RGB')
        
        # Save
        resized.save(output_path, 'PNG')
        print(f"Created: {filename} ({size}x{size})")
    
    print(f"\n✅ Generated {len(IOS_ICON_SIZES)} icons successfully!")
    return True

if __name__ == "__main__":
    generate_icons()

