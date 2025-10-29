import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/disease_result_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// ALL-IN-ONE Disease Detection Service for Rice Disease App
/// Handles API calls, Firebase integration, and cloud storage
class DiseaseDetectionService {
  // ============================================================================
  // 🌐 API CONFIGURATION - CHANGE THESE FOR DEPLOYMENT
  // ============================================================================
  
  /// Production API URL (Render.com deployment)
  static const String _productionUrl = 'https://rice-disease-detection-app-1.onrender.com';
  
  /// Local development API URL
  static const String _localUrl = 'http://192.168.182.140:5000';
  
  /// Switch between production and local API  
  static const bool _useProductionAPI = true; // Set to true for cloud deployment
  
  /// Demo mode for testing UI without API calls
  static const bool _useRealAPI = true; // Set to false for demo mode
  
  // ============================================================================
  // 🚀 COMPUTED PROPERTIES
  // ============================================================================
  
  /// Get the current base URL based on configuration
  static String get _baseUrl => _useProductionAPI ? _productionUrl : _localUrl;
  
  /// API endpoints
  static const String _healthEndpoint = '/health';
  static const String _predictEndpoint = '/predict';
  static const String _diseasesEndpoint = '/diseases';
  static const String _modelInfoEndpoint = '/model-info';
  
  /// Timeout configurations
  static const Duration _shortTimeout = Duration(seconds: 30);
  static const Duration _longTimeout = Duration(minutes: 2); // For first API wake-up
  
  // ============================================================================
  // 🔧 FIREBASE CONFIGURATION
  // ============================================================================
  
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // ============================================================================
  // 🎯 MAIN API METHODS
  // ============================================================================
  
  /// Wake up the API server (important for Render.com free tier)
  static Future<bool> wakeUpAPI() async {
    try {
      print('🚀 Waking up API server...');
      final response = await http.get(
        Uri.parse('$_baseUrl$_healthEndpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_longTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API server is awake and ready!');
        print('   Model loaded: ${data['model_loaded']}');
        return data['model_loaded'] == true;
      }
      return false;
    } catch (e) {
      print('❌ API wake-up failed: $e');
      return false;
    }
  }
  
  /// Check API health status
  static Future<Map<String, dynamic>?> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_healthEndpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_shortTimeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Health check failed: $e');
      return null;
    }
  }
  
  /// Get all supported diseases
  static Future<List<Map<String, dynamic>>?> getDiseases() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_diseasesEndpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_shortTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['diseases']);
      }
      return null;
    } catch (e) {
      print('Get diseases failed: $e');
      return null;
    }
  }
  
  /// Get model information
  static Future<Map<String, dynamic>?> getModelInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_modelInfoEndpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_shortTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['model_info'];
      }
      return null;
    } catch (e) {
      print('Get model info failed: $e');
      return null;
    }
  }
  
  // ============================================================================
  // 🤖 DISEASE DETECTION METHODS
  // ============================================================================
  
  /// Detect disease from image bytes with full cloud integration
  static Future<DiseaseResult?> detectDiseaseFromBytes(
    Uint8List imageBytes, {
    String? userId,
    bool saveToCloud = true,
  }) async {
    try {
      // Return demo result if in demo mode
      if (!_useRealAPI) {
        return _generateDemoResult();
      }
      
      // Wake up API if using production (Render.com goes to sleep)
      if (_useProductionAPI) {
        print('⏰ Checking if API needs wake-up...');
        bool isAwake = await wakeUpAPI();
        if (!isAwake) {
          throw Exception('API server is not responding');
        }
      }
      
      // Convert image to base64
      final base64Image = base64Encode(imageBytes);
      
      // Make prediction request
      print('🔮 Making prediction request...');
      final response = await http.post(
        Uri.parse('$_baseUrl$_predictEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image_base64': base64Image}),
      ).timeout(_longTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Create disease result
        final result = DiseaseResult.fromApiResponse(data);
        
        // Save to cloud if requested
        if (saveToCloud && userId != null) {
          await _saveResultToCloud(result, imageBytes, userId);
        }
        
        print('✅ Disease detection successful: ${result.disease}');
        return result;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Prediction failed');
      }
      
    } catch (e) {
      print('❌ Disease detection failed: $e');
      
      // Fallback to demo mode on error
      if (_useRealAPI) {
        print('🔄 Falling back to demo mode...');
        return _generateDemoResult();
      }
      return null;
    }
  }
  
  /// Detect disease from file
  static Future<DiseaseResult?> detectDiseaseFromFile(
    File imageFile, {
    String? userId,
    bool saveToCloud = true,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      return await detectDiseaseFromBytes(
        imageBytes,
        userId: userId,
        saveToCloud: saveToCloud,
      );
    } catch (e) {
      print('Failed to read image file: $e');
      return null;
    }
  }
  
  // ============================================================================
  // ☁️ CLOUD STORAGE & FIREBASE METHODS
  // ============================================================================
  
  /// Save detection result to Firebase Cloud
  static Future<void> _saveResultToCloud(
    DiseaseResult result,
    Uint8List imageBytes,
    String userId,
  ) async {
    try {
      print('☁️ Saving to cloud...');
      
      // Upload image to Firebase Storage
      final imageUrl = await _uploadImageToStorage(imageBytes, userId);
      
      // Save result to Firestore
      await _firestore.collection('detection_results').add({
        'userId': userId,
        'disease': result.disease,
        'confidence': result.confidence,
        'diseaseType': result.diseaseType,
        'treatment': result.treatment,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'allPredictions': result.allPredictions,
        'topPredictions': result.topPredictions,
      });
      
      print('✅ Result saved to cloud successfully');
    } catch (e) {
      print('❌ Failed to save to cloud: $e');
      // Don't throw error - app should work even if cloud save fails
    }
  }
  
  /// Upload image to Firebase Storage
  static Future<String> _uploadImageToStorage(Uint8List imageBytes, String userId) async {
    final fileName = 'detection_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('user_images/$userId/$fileName');
    
    await ref.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    
    return await ref.getDownloadURL();
  }
  
  /// Get user's detection history from cloud
  static Future<List<DiseaseResult>> getDetectionHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('detection_results')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DiseaseResult.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('Failed to get detection history: $e');
      return [];
    }
  }
  
  /// Get detection statistics for user
  static Future<Map<String, dynamic>> getDetectionStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('detection_results')
          .where('userId', isEqualTo: userId)
          .get();
      
      final results = snapshot.docs.map((doc) => doc.data()).toList();
      
      // Calculate statistics
      final totalDetections = results.length;
      final diseaseCount = results.where((r) => r['diseaseType'] == 'disease').length;
      final healthyCount = results.where((r) => r['diseaseType'] == 'healthy').length;
      
      // Disease frequency
      Map<String, int> diseaseFrequency = {};
      for (var result in results) {
        final disease = result['disease'] as String;
        diseaseFrequency[disease] = (diseaseFrequency[disease] ?? 0) + 1;
      }
      
      return {
        'totalDetections': totalDetections,
        'diseaseCount': diseaseCount,
        'healthyCount': healthyCount,
        'diseaseFrequency': diseaseFrequency,
        'lastDetection': results.isNotEmpty ? results.first['timestamp'] : null,
      };
    } catch (e) {
      print('Failed to get detection stats: $e');
      return {};
    }
  }
  
  // ============================================================================
  // 🎭 DEMO MODE METHODS
  // ============================================================================
  
  /// Generate demo result for testing
  static DiseaseResult _generateDemoResult() {
    final diseases = [
      'Healthy Rice Leaf',
      'Bacterial Leaf Blight',
      'Brown Spot',
      'Leaf Blast',
      'Rice Hispa',
    ];
    
    final randomDisease = (diseases..shuffle()).first;
    final confidence = 0.75 + (0.25 * (DateTime.now().millisecond / 1000));
    
    return DiseaseResult(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      disease: randomDisease,
      confidence: confidence,
      diseaseType: randomDisease.toLowerCase().contains('healthy') ? 'healthy' : 'disease',
      treatment: _getDemoTreatment(randomDisease),
      timestamp: DateTime.now(),
      imageUrl: null,
      allPredictions: _generateDemoPredictions(randomDisease, confidence),
      topPredictions: _generateTopPredictions(randomDisease, confidence),
    );
  }
  
  static String _getDemoTreatment(String disease) {
    final treatments = {
      'Healthy Rice Leaf': 'Continue current management practices. Regular monitoring recommended.',
      'Bacterial Leaf Blight': 'Apply copper-based bactericides. Improve field drainage.',
      'Brown Spot': 'Apply fungicides like Mancozeb. Improve soil fertility.',
      'Leaf Blast': 'Apply systemic fungicides like Tricyclazole. Use resistant varieties.',
      'Rice Hispa': 'Apply insecticides like Chlorpyrifos. Use pheromone traps.',
    };
    return treatments[disease] ?? 'Consult agricultural expert for treatment.';
  }
  
  static Map<String, double> _generateDemoPredictions(String topDisease, double topConfidence) {
    return {
      topDisease: topConfidence,
      'Healthy Rice Leaf': 0.1,
      'Bacterial Leaf Blight': 0.05,
      'Brown Spot': 0.05,
      'Leaf Blast': 0.05,
    };
  }
  
  static List<Map<String, dynamic>> _generateTopPredictions(String topDisease, double topConfidence) {
    return [
      {'disease': topDisease, 'confidence': topConfidence},
      {'disease': 'Healthy Rice Leaf', 'confidence': 0.1},
      {'disease': 'Bacterial Leaf Blight', 'confidence': 0.05},
    ];
  }
  
  // ============================================================================
  // 🔧 UTILITY METHODS
  // ============================================================================
  
  /// Test complete system connectivity
  static Future<Map<String, bool>> testSystemConnectivity() async {
    final results = <String, bool>{};
    
    // Test API connectivity
    results['api_health'] = await checkHealth() != null;
    
    // Test Firebase connectivity
    try {
      await _firestore.collection('test').limit(1).get();
      results['firebase_firestore'] = true;
    } catch (e) {
      results['firebase_firestore'] = false;
    }
    
    try {
      await _storage.ref().child('test').getDownloadURL();
      results['firebase_storage'] = true;
    } catch (e) {
      results['firebase_storage'] = false;
    }
    
    return results;
  }
  
  /// Get current configuration info
  static Map<String, dynamic> getConfigInfo() {
    return {
      'baseUrl': _baseUrl,
      'useProductionAPI': _useProductionAPI,
      'useRealAPI': _useRealAPI,
      'shortTimeout': _shortTimeout.inSeconds,
      'longTimeout': _longTimeout.inSeconds,
    };
  }
}