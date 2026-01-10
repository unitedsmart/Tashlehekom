#!/usr/bin/env python3
"""
Script to create app icon for Tashlehekom app
Creates a simple but professional icon with car and parts theme
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    # Create different sizes for Android
    sizes = [
        (192, 192),  # xxxhdpi
        (144, 144),  # xxhdpi  
        (96, 96),    # xhdpi
        (72, 72),    # hdpi
        (48, 48),    # mdpi
    ]
    
    for width, height in sizes:
        # Create image with transparent background
        img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # Background circle with gradient effect
        center = (width // 2, height // 2)
        radius = min(width, height) // 2 - 4
        
        # Draw background circle (green theme)
        draw.ellipse([center[0] - radius, center[1] - radius, 
                     center[0] + radius, center[1] + radius], 
                    fill=(76, 175, 80, 255), outline=(56, 142, 60, 255), width=2)
        
        # Draw car silhouette
        car_width = width * 0.6
        car_height = height * 0.3
        car_x = (width - car_width) // 2
        car_y = (height - car_height) // 2
        
        # Car body
        draw.rounded_rectangle([car_x, car_y, car_x + car_width, car_y + car_height], 
                              radius=car_height//4, fill=(255, 255, 255, 255))
        
        # Car windows
        window_margin = car_width * 0.15
        window_height = car_height * 0.4
        draw.rounded_rectangle([car_x + window_margin, car_y + 2, 
                               car_x + car_width - window_margin, car_y + window_height], 
                              radius=2, fill=(200, 200, 200, 255))
        
        # Car wheels
        wheel_radius = car_height * 0.25
        wheel_y = car_y + car_height - wheel_radius//2
        
        # Left wheel
        draw.ellipse([car_x + car_width * 0.2 - wheel_radius//2, wheel_y - wheel_radius//2,
                     car_x + car_width * 0.2 + wheel_radius//2, wheel_y + wheel_radius//2], 
                    fill=(64, 64, 64, 255))
        
        # Right wheel  
        draw.ellipse([car_x + car_width * 0.8 - wheel_radius//2, wheel_y - wheel_radius//2,
                     car_x + car_width * 0.8 + wheel_radius//2, wheel_y + wheel_radius//2], 
                    fill=(64, 64, 64, 255))
        
        # Add small parts/tools icons around the car
        part_size = width * 0.08
        
        # Wrench icon (simplified)
        wrench_x = center[0] - radius * 0.7
        wrench_y = center[1] - radius * 0.5
        draw.rectangle([wrench_x, wrench_y, wrench_x + part_size//4, wrench_y + part_size], 
                      fill=(255, 193, 7, 255))
        draw.ellipse([wrench_x - part_size//8, wrench_y - part_size//8,
                     wrench_x + part_size//4 + part_size//8, wrench_y + part_size//8], 
                    fill=(255, 193, 7, 255))
        
        # Gear icon (simplified)
        gear_x = center[0] + radius * 0.6
        gear_y = center[1] + radius * 0.4
        draw.ellipse([gear_x, gear_y, gear_x + part_size, gear_y + part_size], 
                    fill=(255, 152, 0, 255))
        draw.ellipse([gear_x + part_size//4, gear_y + part_size//4, 
                     gear_x + part_size*3//4, gear_y + part_size*3//4], 
                    fill=(255, 255, 255, 255))
        
        # Save the icon
        folder_name = get_folder_name(width)
        folder_path = f"android/app/src/main/res/{folder_name}"
        os.makedirs(folder_path, exist_ok=True)
        
        img.save(f"{folder_path}/ic_launcher.png", "PNG")
        print(f"Created icon: {folder_path}/ic_launcher.png ({width}x{height})")

def get_folder_name(size):
    """Get Android drawable folder name based on size"""
    if size >= 192:
        return "mipmap-xxxhdpi"
    elif size >= 144:
        return "mipmap-xxhdpi"
    elif size >= 96:
        return "mipmap-xhdpi"
    elif size >= 72:
        return "mipmap-hdpi"
    else:
        return "mipmap-mdpi"

if __name__ == "__main__":
    try:
        create_app_icon()
        print("\n✅ App icons created successfully!")
        print("Icons saved in android/app/src/main/res/mipmap-* folders")
    except ImportError:
        print("❌ PIL (Pillow) library not found.")
        print("Please install it with: pip install Pillow")
    except Exception as e:
        print(f"❌ Error creating icons: {e}")
