#!/usr/bin/env python3
"""
Create proper rice leaf test images for the app
"""

from PIL import Image, ImageDraw, ImageFilter
import numpy as np
import random

def create_realistic_healthy_rice_leaf():
    """Create a realistic healthy rice leaf image"""
    print("🌱 Creating realistic healthy rice leaf...")
    
    # Base green color for healthy rice
    img = Image.new('RGB', (400, 600), color=(34, 139, 34))
    draw = ImageDraw.Draw(img)
    
    # Rice leaf is long and narrow
    # Create leaf shape
    leaf_points = [
        (180, 50),   # Top point
        (220, 50),   # Top point
        (240, 100),  # Upper right
        (250, 200),  # Mid right
        (245, 300),  # Lower mid right
        (240, 400),  # Lower right
        (230, 500),  # Bottom right
        (200, 550),  # Bottom point
        (170, 500),  # Bottom left
        (160, 400),  # Lower left
        (155, 300),  # Lower mid left
        (160, 200),  # Mid left
        (170, 100),  # Upper left
    ]
    
    # Draw leaf shape
    draw.polygon(leaf_points, fill=(50, 160, 50))
    
    # Add leaf veins (parallel lines typical of rice)
    for i in range(170, 230, 8):
        draw.line([(i, 60), (i, 540)], fill=(40, 140, 40), width=2)
    
    # Add central vein (midrib)
    draw.line([(200, 50), (200, 550)], fill=(35, 130, 35), width=3)
    
    # Add some natural variation
    for _ in range(20):
        x = random.randint(165, 235)
        y = random.randint(60, 540)
        draw.ellipse([x-2, y-2, x+2, y+2], fill=(45, 150, 45))
    
    # Apply slight blur for realism
    img = img.filter(ImageFilter.GaussianBlur(radius=0.5))
    
    img.save('healthy_rice_leaf.jpg', 'JPEG', quality=90)
    return 'healthy_rice_leaf.jpg'

def create_realistic_diseased_rice_leaf():
    """Create a realistic diseased rice leaf (Brown Spot)"""
    print("🦠 Creating realistic diseased rice leaf (Brown Spot)...")
    
    # Base yellow-green color for diseased rice
    img = Image.new('RGB', (400, 600), color=(120, 140, 60))
    draw = ImageDraw.Draw(img)
    
    # Same leaf shape as healthy
    leaf_points = [
        (180, 50), (220, 50), (240, 100), (250, 200), (245, 300),
        (240, 400), (230, 500), (200, 550), (170, 500), (160, 400),
        (155, 300), (160, 200), (170, 100)
    ]
    
    # Draw leaf shape with diseased color
    draw.polygon(leaf_points, fill=(140, 160, 70))
    
    # Add leaf veins
    for i in range(170, 230, 8):
        draw.line([(i, 60), (i, 540)], fill=(110, 130, 50), width=2)
    
    # Add central vein
    draw.line([(200, 50), (200, 550)], fill=(100, 120, 45), width=3)
    
    # Add brown spots (characteristic of Brown Spot disease)
    spot_colors = [(101, 67, 33), (139, 69, 19), (160, 82, 45)]
    
    for _ in range(15):
        x = random.randint(170, 230)
        y = random.randint(100, 500)
        size = random.randint(8, 20)
        color = random.choice(spot_colors)
        
        # Draw circular brown spots
        draw.ellipse([x-size//2, y-size//2, x+size//2, y+size//2], fill=color)
        
        # Add yellow halo around spots
        halo_size = size + 6
        draw.ellipse([x-halo_size//2, y-halo_size//2, x+halo_size//2, y+halo_size//2], 
                    outline=(200, 200, 100), width=2)
    
    # Add some yellowing areas
    for _ in range(8):
        x = random.randint(165, 235)
        y = random.randint(80, 520)
        size = random.randint(15, 30)
        draw.ellipse([x-size//2, y-size//2, x+size//2, y+size//2], 
                    fill=(180, 180, 80))
    
    # Apply slight blur
    img = img.filter(ImageFilter.GaussianBlur(radius=0.5))
    
    img.save('diseased_rice_leaf.jpg', 'JPEG', quality=90)
    return 'diseased_rice_leaf.jpg'

def create_bacterial_blight_leaf():
    """Create a rice leaf with Bacterial Leaf Blight"""
    print("🦠 Creating Bacterial Leaf Blight rice leaf...")
    
    # Yellowish base for bacterial infection
    img = Image.new('RGB', (400, 600), color=(140, 140, 80))
    draw = ImageDraw.Draw(img)
    
    # Leaf shape
    leaf_points = [
        (180, 50), (220, 50), (240, 100), (250, 200), (245, 300),
        (240, 400), (230, 500), (200, 550), (170, 500), (160, 400),
        (155, 300), (160, 200), (170, 100)
    ]
    
    draw.polygon(leaf_points, fill=(160, 160, 90))
    
    # Add veins
    for i in range(170, 230, 8):
        draw.line([(i, 60), (i, 540)], fill=(130, 130, 70), width=2)
    
    # Add central vein
    draw.line([(200, 50), (200, 550)], fill=(120, 120, 60), width=3)
    
    # Add characteristic water-soaked lesions
    for _ in range(12):
        x = random.randint(175, 225)
        y = random.randint(100, 500)
        width = random.randint(20, 40)
        height = random.randint(8, 15)
        
        # Water-soaked appearance (darker, wet-looking)
        draw.ellipse([x-width//2, y-height//2, x+width//2, y+height//2], 
                    fill=(100, 120, 60))
        
        # Yellow halo
        draw.ellipse([x-width//2-3, y-height//2-3, x+width//2+3, y+height//2+3], 
                    outline=(200, 200, 100), width=3)
    
    img = img.filter(ImageFilter.GaussianBlur(radius=0.5))
    img.save('bacterial_blight_leaf.jpg', 'JPEG', quality=90)
    return 'bacterial_blight_leaf.jpg'

def test_created_images():
    """Test the created images with the API"""
    print("\n🧪 Testing created images with API...")
    
    import requests
    
    images = [
        ('healthy_rice_leaf.jpg', 'Healthy Rice Leaf'),
        ('diseased_rice_leaf.jpg', 'Brown Spot or other disease'),
        ('bacterial_blight_leaf.jpg', 'Bacterial Leaf Blight')
    ]
    
    for img_path, expected in images:
        print(f"\n📸 Testing {img_path} (expecting: {expected})...")
        
        try:
            url = "http://localhost:5000/predict"
            with open(img_path, 'rb') as f:
                files = {'image': f}
                response = requests.post(url, files=files, timeout=15)
            
            if response.status_code == 200:
                result = response.json()
                print(f"✅ Prediction: {result['prediction']['disease']}")
                print(f"✅ Confidence: {result['prediction']['confidence']:.3f}")
                print(f"✅ Type: {result['prediction']['disease_type']}")
                
                # Check if prediction makes sense
                if 'healthy' in expected.lower() and 'healthy' in result['prediction']['disease'].lower():
                    print("🎉 CORRECT: Healthy leaf detected correctly!")
                elif 'healthy' not in expected.lower() and 'healthy' not in result['prediction']['disease'].lower():
                    print("🎉 CORRECT: Disease detected correctly!")
                else:
                    print("⚠️  Unexpected result")
                    
            else:
                print(f"❌ API Error: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Error: {e}")

def main():
    print("🌾 Creating Realistic Rice Leaf Test Images...")
    print("=" * 60)
    
    # Create test images
    healthy_img = create_realistic_healthy_rice_leaf()
    diseased_img = create_realistic_diseased_rice_leaf()
    blight_img = create_bacterial_blight_leaf()
    
    print(f"\n✅ Created test images:")
    print(f"   📁 {healthy_img} - Use this to test healthy detection")
    print(f"   📁 {diseased_img} - Use this to test disease detection")
    print(f"   📁 {blight_img} - Use this to test bacterial blight")
    
    # Test with API
    test_created_images()
    
    print(f"\n" + "=" * 60)
    print("🎯 Test Images Created Successfully!")
    print("\n📱 How to use in your Flutter app:")
    print("1. Copy these .jpg files to your phone")
    print("2. Open your rice disease app")
    print("3. Click 'Gallery' instead of camera")
    print("4. Select these test images")
    print("5. Analyze and verify results!")
    
    print(f"\n🎉 Your app should now work perfectly with proper rice images!")

if __name__ == "__main__":
    main()