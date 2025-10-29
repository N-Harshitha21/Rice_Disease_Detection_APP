#!/bin/bash
echo "🚀 Starting Rice Disease Detection API on Render.com"
echo "📁 Current directory: $(pwd)"
echo "📊 Available files:"
ls -la *.h5 || echo "No .h5 files found"

echo "🐍 Python version: $(python --version)"
echo "📦 TensorFlow version:"
python -c "import tensorflow as tf; print(f'TensorFlow: {tf.__version__}')" || echo "TensorFlow not available"

echo "🔥 Starting Gunicorn server..."
exec gunicorn --bind 0.0.0.0:$PORT rice_disease_api:app --timeout 300 --workers 1 --preload
