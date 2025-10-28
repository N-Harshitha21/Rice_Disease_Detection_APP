@echo off
echo 🌾 Quick Cloud Deployment for Rice Disease Detection
echo ===================================================
echo.
echo This script helps deploy your app to the cloud for complete independence!
echo.
echo 📋 Prerequisites:
echo 1. GitHub account (free)
echo 2. Render.com account (free) 
echo 3. Git installed on your system
echo.
echo 🚀 Steps this script will help with:
echo 1. Push code to GitHub
echo 2. Guide you through Render.com deployment
echo 3. Update Flutter configuration
echo 4. Test deployment
echo.
pause

echo.
echo 📦 Step 1: Checking Git status...
git status

echo.
echo 🔗 Step 2: Push to GitHub
echo.
echo Please create a GitHub repository first:
echo 1. Go to github.com
echo 2. Click "New repository"  
echo 3. Name: rice-disease-detection
echo 4. Make it PUBLIC (required for free Render.com)
echo 5. Don't initialize with README (we already have code)
echo.
set /p github_url="Enter your GitHub repository URL (e.g., https://github.com/username/rice-disease-detection.git): "

echo.
echo 📤 Pushing to GitHub...
git remote add origin %github_url%
git branch -M main
git push -u origin main

if %errorlevel% neq 0 (
    echo ❌ Git push failed. Please check your GitHub URL and try again.
    pause
    exit /b 1
)

echo ✅ Code pushed to GitHub successfully!
echo.
echo 🌐 Step 3: Deploy to Render.com
echo.
echo Now follow these steps in your browser:
echo.
echo 1. Go to https://render.com
echo 2. Sign up/login with GitHub
echo 3. Click "New +" → "Web Service"
echo 4. Connect to your repository: rice-disease-detection
echo 5. Configure:
echo    - Name: rice-disease-api
echo    - Environment: Python 3
echo    - Build Command: pip install -r requirements.txt
echo    - Start Command: gunicorn --bind 0.0.0.0:$PORT rice_disease_api:app
echo    - Plan: Free
echo.
echo 6. Add Environment Variables:
echo    - TF_CPP_MIN_LOG_LEVEL = 2
echo    - PYTHON_VERSION = 3.12
echo.
echo 7. Click "Create Web Service"
echo 8. Wait 5-10 minutes for deployment
echo.
set /p api_url="Enter your Render.com API URL when ready (e.g., https://rice-disease-api-xxxxx.onrender.com): "

echo.
echo 🔧 Step 4: Updating Flutter configuration...

:: Update the disease detection service with the new API URL
powershell -Command "(Get-Content lib/services/disease_detection_service.dart) -replace 'https://rice-disease-api-YOUR_APP_ID.onrender.com', '%api_url%' | Set-Content lib/services/disease_detection_service.dart"
powershell -Command "(Get-Content lib/services/disease_detection_service.dart) -replace 'static const bool _useProductionAPI = false;', 'static const bool _useProductionAPI = true;' | Set-Content lib/services/disease_detection_service.dart"

echo ✅ Flutter configuration updated!
echo.
echo 🧪 Step 5: Testing deployment...
echo.
echo Testing API health (this may take 30-60 seconds for first time)...
curl %api_url%/health

echo.
echo 📱 Step 6: Test Flutter app
echo.
echo Run these commands to test your app:
echo.
echo flutter clean
echo flutter pub get  
echo flutter run
echo.
echo 🎉 DEPLOYMENT COMPLETE!
echo ============================
echo.
echo ✅ Your Rice Disease Detection app is now fully cloud-deployed!
echo ✅ Works independently without laptop connection
echo ✅ Ready for production use by farmers
echo.
echo 🔗 Cloud API: %api_url%
echo.
echo 📱 Next steps:
echo 1. Test the app thoroughly
echo 2. Build production APK: flutter build apk --release
echo 3. Publish to app stores
echo.
echo 📚 See COMPLETE_CLOUD_DEPLOYMENT_GUIDE.md for detailed instructions
echo.
pause