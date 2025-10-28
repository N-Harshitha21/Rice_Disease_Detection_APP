#!/usr/bin/env python3
"""
Script to extract key information from your Kaggle notebook
Run this to get the details needed for the Flask API setup
"""

import json
import re

def extract_notebook_info(notebook_path):
    """Extract key information from Jupyter notebook"""
    try:
        with open(notebook_path, 'r', encoding='utf-8') as f:
            notebook_data = json.load(f)
        
        print("🔍 Analyzing your Kaggle notebook...")
        print("=" * 50)
        
        # Extract all code cells
        code_cells = []
        for cell in notebook_data.get('cells', []):
            if cell.get('cell_type') == 'code':
                source = ''.join(cell.get('source', []))
                if source.strip():
                    code_cells.append(source)
        
        # Find model architecture
        print("\n📊 MODEL ARCHITECTURE:")
        model_patterns = [
            r'model\s*=.*Sequential',
            r'model\s*=.*Model',
            r'from.*models.*import',
            r'tf\.keras\.Sequential',
            r'applications\.\w+',
            r'VGG\d+|ResNet\d+|MobileNet|DenseNet|EfficientNet'
        ]
        
        for i, cell in enumerate(code_cells):
            for pattern in model_patterns:
                matches = re.findall(pattern, cell, re.IGNORECASE)
                if matches:
                    print(f"Cell {i+1}: {matches}")
        
        # Find class names
        print("\n🏷️ CLASS NAMES:")
        class_patterns = [
            r'class_names\s*=\s*\[(.*?)\]',
            r'classes\s*=\s*\[(.*?)\]',
            r'labels\s*=\s*\[(.*?)\]',
            r'train_generator\.class_indices',
            r'\.class_names'
        ]
        
        for i, cell in enumerate(code_cells):
            for pattern in class_patterns:
                matches = re.findall(pattern, cell, re.DOTALL | re.IGNORECASE)
                if matches:
                    print(f"Cell {i+1}: {matches}")
        
        # Find image preprocessing
        print("\n🖼️ IMAGE PREPROCESSING:")
        preprocess_patterns = [
            r'resize\(\s*\((\d+),\s*(\d+)\)',
            r'target_size\s*=\s*\((\d+),\s*(\d+)\)',
            r'img_height\s*=\s*(\d+)',
            r'img_width\s*=\s*(\d+)',
            r'rescale\s*=\s*([\d\.\/]+)',
            r'\/\s*255',
            r'preprocess_input'
        ]
        
        for i, cell in enumerate(code_cells):
            for pattern in preprocess_patterns:
                matches = re.findall(pattern, cell, re.IGNORECASE)
                if matches:
                    print(f"Cell {i+1}: {pattern} -> {matches}")
        
        # Find model saving
        print("\n💾 MODEL SAVING:")
        save_patterns = [
            r'model\.save\([\'\"](.*?)[\'\"]',
            r'save_model\([^,]*,\s*[\'\"](.*?)[\'\"]',
            r'\.h5[\'\"]\)',
            r'ModelCheckpoint.*[\'\"](.*?)[\'\"]'
        ]
        
        for i, cell in enumerate(code_cells):
            for pattern in save_patterns:
                matches = re.findall(pattern, cell, re.IGNORECASE)
                if matches:
                    print(f"Cell {i+1}: Model saved as -> {matches}")
        
        # Find model compilation
        print("\n⚙️ MODEL COMPILATION:")
        compile_patterns = [
            r'model\.compile\((.*?)\)',
            r'optimizer\s*=\s*[\'\"](.*?)[\'\"]',
            r'loss\s*=\s*[\'\"](.*?)[\'\"]',
            r'metrics\s*=\s*\[(.*?)\]'
        ]
        
        for i, cell in enumerate(code_cells):
            for pattern in compile_patterns:
                matches = re.findall(pattern, cell, re.DOTALL | re.IGNORECASE)
                if matches and len(str(matches[0])) < 200:  # Avoid very long matches
                    print(f"Cell {i+1}: {pattern} -> {matches}")
        
        print("\n" + "=" * 50)
        print("✅ Analysis complete!")
        print("\n💡 Next steps:")
        print("1. Look for the model file (.h5) in your Kaggle outputs")
        print("2. Note the class names and preprocessing steps above")
        print("3. Use this info to customize the Flask API template")
        
    except Exception as e:
        print(f"❌ Error reading notebook: {e}")
        print("\n🔧 Alternative approach:")
        print("1. Open your notebook in Jupyter Lab/VS Code")
        print("2. Look for these sections manually:")
        print("   - Model definition (Sequential, Model, etc.)")
        print("   - Class names/labels list")
        print("   - Image preprocessing (resize, rescale)")
        print("   - Model saving (.h5 file)")

if __name__ == "__main__":
    notebook_path = "Rice_leaf_disease_dataset_using the Deep_Learning.ipynb"
    extract_notebook_info(notebook_path)