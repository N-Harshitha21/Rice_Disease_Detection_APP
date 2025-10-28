@echo off
echo 🌾 Starting Rice Disease Detection Backend...
echo ==========================================

echo 📋 Running setup check...
python setup_backend.py

echo.
echo 🚀 Starting Flask API server...
python rice_disease_api.py

pause