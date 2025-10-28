import 'dart:io';
import 'lib/services/rice_disease_api_service.dart';

void main() async {
  print('🔍 Testing Flutter App Direct Connection...');
  print('=' * 60);
  
  // Test 1: Health check using Flutter service
  print('1️⃣ Testing Health Check...');
  try {
    final healthResponse = await RiceDiseaseApiService.checkHealth();
    print('✅ Health Success: ${healthResponse.success}');
    if (healthResponse.success) {
      print('✅ Status: ${healthResponse.data?.status}');
      print('✅ Model Loaded: ${healthResponse.data?.modelLoaded}');
    } else {
      print('❌ Health Error: ${healthResponse.error}');
    }
  } catch (e) {
    print('❌ Health Exception: $e');
  }
  
  // Test 2: Predict with the healthy rice leaf image
  print('\n2️⃣ Testing Prediction with healthy_rice_leaf.jpg...');
  try {
    final imageFile = File('healthy_rice_leaf.jpg');
    
    if (await imageFile.exists()) {
      print('✅ Image file exists: ${imageFile.path}');
      print('✅ Image size: ${await imageFile.length()} bytes');
      
      // Make the prediction
      final predictionResponse = await RiceDiseaseApiService.predictFromFile(imageFile);
      
      print('📡 Response Success: ${predictionResponse.success}');
      
      if (predictionResponse.success && predictionResponse.data != null) {
        final prediction = predictionResponse.data!.prediction;
        
        print('🎯 FLUTTER APP RESULTS:');
        print('   Disease: ${prediction.disease}');
        print('   Confidence: ${prediction.confidence.toStringAsFixed(3)}');
        print('   Confidence Level: ${prediction.confidenceLevel}');
        print('   Disease Type: ${prediction.diseaseType}');
        print('   Reliability: ${prediction.reliability}');
        print('   Treatment: ${prediction.treatment.substring(0, 50)}...');
        
        print('\n📊 Top Predictions:');
        for (int i = 0; i < predictionResponse.data!.topPredictions.length && i < 3; i++) {
          final topPred = predictionResponse.data!.topPredictions[i];
          print('   ${i+1}. ${topPred.disease}: ${topPred.confidence.toStringAsFixed(3)}');
        }
        
        // Check if this matches our backend test
        if (prediction.disease == 'Healthy Rice Leaf') {
          print('\n✅ PERFECT! Flutter app gets correct result: Healthy Rice Leaf');
        } else {
          print('\n❌ PROBLEM! Flutter app gets: ${prediction.disease}');
          print('   Expected: Healthy Rice Leaf');
          print('   This suggests an issue in Flutter API service or backend response parsing');
        }
        
      } else {
        print('❌ Prediction Failed!');
        print('❌ Error: ${predictionResponse.error}');
      }
      
    } else {
      print('❌ Image file not found: ${imageFile.path}');
    }
    
  } catch (e) {
    print('❌ Prediction Exception: $e');
  }
  
  // Test 3: Test with diseased image
  print('\n3️⃣ Testing with diseased_rice_leaf.jpg...');
  try {
    final imageFile = File('diseased_rice_leaf.jpg');
    
    if (await imageFile.exists()) {
      final predictionResponse = await RiceDiseaseApiService.predictFromFile(imageFile);
      
      if (predictionResponse.success && predictionResponse.data != null) {
        final prediction = predictionResponse.data!.prediction;
        print('🎯 Diseased Image Result: ${prediction.disease}');
        print('   Confidence: ${prediction.confidence.toStringAsFixed(3)}');
        
        if (prediction.disease.toLowerCase().contains('healthy')) {
          print('❌ PROBLEM! Diseased image detected as healthy');
        } else {
          print('✅ CORRECT! Diseased image detected as disease');
        }
      } else {
        print('❌ Diseased image prediction failed: ${predictionResponse.error}');
      }
    }
  } catch (e) {
    print('❌ Diseased image test failed: $e');
  }
  
  print('\n' + '=' * 60);
  print('🎯 Flutter Direct Test Complete!');
  print('\nIf Flutter app gives different results than backend:');
  print('1. Check network connectivity');
  print('2. Verify API URL is correct');
  print('3. Check response parsing in Flutter');
  print('4. Look for JSON parsing errors');
}