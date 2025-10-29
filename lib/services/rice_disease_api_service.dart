import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Service class for Rice Disease Detection API
class RiceDiseaseApiService {
  // API Configuration - Smart URL switching for production/development
  static const String _productionUrl = 'https://rice-disease-detection-app-1.onrender.com';
  static const String _developmentUrl = 'http://192.168.182.140:5000';
  static const String _localUrl = 'http://localhost:5000'; // For local testing
  static const bool _useProductionAPI = true; // Will automatically fallback to local if cloud fails
  
  /// Get the current base URL based on configuration
  static String get baseUrl => _useProductionAPI ? _productionUrl : _localUrl;
  static const String predictEndpoint = '/predict';
  static const String healthEndpoint = '/health';
  static const String diseasesEndpoint = '/diseases';
  static const String modelInfoEndpoint = '/model-info';
  
  // Timeout configurations for cloud deployment
  static const Duration _shortTimeout = Duration(seconds: 30);
  static const Duration _longTimeout = Duration(minutes: 2); // For cloud wake-up
  
  /// Get appropriate timeout based on operation type
  static Duration get timeoutDuration => _useProductionAPI ? _longTimeout : _shortTimeout;
  
  /// Test API connectivity with smart fallback
  static Future<String?> _findWorkingAPI() async {
    final urlsToTry = [
      _productionUrl,  // Try cloud first for global access
      _localUrl,       // Fallback to local for development
      _developmentUrl, // Last resort
    ];
    
    for (String url in urlsToTry) {
      try {
        print('🔍 Testing API at: $url');
        final response = await http.get(
          Uri.parse('$url$healthEndpoint'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(_shortTimeout);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['model_loaded'] == true) {
            print('✅ Found working API with loaded model: $url');
            return url;
          } else {
            print('⚠️ API responding but model not loaded: $url');
          }
        }
      } catch (e) {
        print('❌ API not accessible: $url - $e');
      }
    }
    
    return null;
  }

  /// Wake up the API server (important for cloud free tier)
  static Future<bool> wakeUpAPI() async {
    try {
      if (_useProductionAPI) {
        print('🚀 Waking up cloud API server...');
        final response = await http.get(
          Uri.parse('$_productionUrl$healthEndpoint'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(_longTimeout);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('✅ Cloud API server is awake!');
          return data['model_loaded'] == true;
        }
      }
      return false;
    } catch (e) {
      print('❌ API wake-up failed: $e');
      return false;
    }
  }

  /// Check API health status
  static Future<ApiResponse<HealthStatus>> checkHealth() async {
    try {
      // Wake up API if using production cloud
      if (_useProductionAPI) {
        bool isAwake = await wakeUpAPI();
        if (!isAwake) {
          return ApiResponse.error('Cloud API server is not responding');
        }
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl$healthEndpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_shortTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(HealthStatus.fromJson(data));
      } else {
        return ApiResponse.error('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Connection failed: $e');
    }
  }
  
  /// Predict disease from image file
  static Future<ApiResponse<PredictionResult>> predictFromFile(File imageFile) async {
    try {
      // Check file size (max 16MB)
      final fileSize = await imageFile.length();
      if (fileSize > 16 * 1024 * 1024) {
        return ApiResponse.error('File too large. Maximum size is 16MB.');
      }
      
      // Find working API endpoint
      print('🔍 Finding available API server...');
      String? workingUrl = await _findWorkingAPI();
      
      if (workingUrl == null) {
        return ApiResponse.error('No working API server found. Please ensure the API is running.');
      }
      
      print('🔮 Making prediction request to: $workingUrl$predictEndpoint');
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$workingUrl$predictEndpoint'),
      );
      
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      // Send request
      final streamedResponse = await request.send().timeout(_longTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Prediction successful: ${data['prediction']['disease']}');
        return ApiResponse.success(PredictionResult.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        print('❌ Prediction failed: ${errorData['error']}');
        return ApiResponse.error(errorData['error'] ?? 'Prediction failed');
      }
    } catch (e) {
      print('❌ Prediction exception: $e');
      return ApiResponse.error('Prediction failed: $e');
    }
  }
  
  /// Predict disease from base64 image
  static Future<ApiResponse<PredictionResult>> predictFromBase64(String base64Image) async {
    try {
      // Wake up API if using production cloud
      if (_useProductionAPI) {
        print('⏰ Ensuring cloud API is awake for base64 prediction...');
        bool isAwake = await wakeUpAPI();
        if (!isAwake) {
          return ApiResponse.error('Cloud API server is not responding. Please try again.');
        }
      }
      
      print('🔮 Making base64 prediction request to: $baseUrl$predictEndpoint');
      
      final response = await http.post(
        Uri.parse('$baseUrl$predictEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image_base64': base64Image}),
      ).timeout(_longTimeout);
      
      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Base64 prediction successful: ${data['prediction']['disease']}');
        return ApiResponse.success(PredictionResult.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        print('❌ Base64 prediction failed: ${errorData['error']}');
        return ApiResponse.error(errorData['error'] ?? 'Prediction failed');
      }
    } catch (e) {
      print('❌ Base64 prediction exception: $e');
      return ApiResponse.error('Prediction failed: $e');
    }
  }
  
  /// Predict disease from Uint8List (camera/gallery image)
  static Future<ApiResponse<PredictionResult>> predictFromBytes(Uint8List imageBytes) async {
    try {
      // Convert to base64
      final base64Image = base64Encode(imageBytes);
      return await predictFromBase64(base64Image);
    } catch (e) {
      return ApiResponse.error('Image processing failed: $e');
    }
  }
  
  /// Get all supported diseases information
  static Future<ApiResponse<List<DiseaseInfo>>> getDiseases() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$diseasesEndpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_shortTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final diseases = (data['diseases'] as List)
            .map((disease) => DiseaseInfo.fromJson(disease))
            .toList();
        return ApiResponse.success(diseases);
      } else {
        return ApiResponse.error('Failed to fetch diseases: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Failed to fetch diseases: $e');
    }
  }
  
  /// Get model information
  static Future<ApiResponse<ModelInfo>> getModelInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$modelInfoEndpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_shortTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(ModelInfo.fromJson(data['model_info']));
      } else {
        return ApiResponse.error('Failed to fetch model info: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Failed to fetch model info: $e');
    }
  }
  
  /// Get current configuration info for debugging
  static Map<String, dynamic> getConfigInfo() {
    return {
      'baseUrl': baseUrl,
      'useProductionAPI': _useProductionAPI,
      'productionUrl': _productionUrl,
      'developmentUrl': _developmentUrl,
      'shortTimeout': _shortTimeout.inSeconds,
      'longTimeout': _longTimeout.inSeconds,
    };
  }
  
  /// Test complete system connectivity
  static Future<Map<String, bool>> testConnectivity() async {
    final results = <String, bool>{};
    
    // Test health endpoint
    final healthResponse = await checkHealth();
    results['health'] = healthResponse.success;
    
    // Test diseases endpoint
    final diseasesResponse = await getDiseases();
    results['diseases'] = diseasesResponse.success;
    
    // Test model info endpoint
    final modelResponse = await getModelInfo();
    results['model_info'] = modelResponse.success;
    
    return results;
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  
  ApiResponse.success(this.data) : success = true, error = null;
  ApiResponse.error(this.error) : success = false, data = null;
}

/// Health status model
class HealthStatus {
  final String status;
  final bool modelLoaded;
  final String timestamp;
  
  HealthStatus({
    required this.status,
    required this.modelLoaded,
    required this.timestamp,
  });
  
  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] ?? '',
      modelLoaded: json['model_loaded'] ?? false,
      timestamp: json['timestamp'] ?? '',
    );
  }
}

/// Prediction result model
class PredictionResult {
  final bool success;
  final Prediction prediction;
  final List<TopPrediction> topPredictions;
  final Map<String, double> allPredictions;
  final String timestamp;
  
  PredictionResult({
    required this.success,
    required this.prediction,
    required this.topPredictions,
    required this.allPredictions,
    required this.timestamp,
  });
  
  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      success: json['success'] ?? false,
      prediction: Prediction.fromJson(json['prediction'] ?? {}),
      topPredictions: (json['top_predictions'] as List? ?? [])
          .map((pred) => TopPrediction.fromJson(pred))
          .toList(),
      allPredictions: Map<String, double>.from(
        (json['all_predictions'] as Map? ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

/// Individual prediction model
class Prediction {
  final String disease;
  final String diseaseType;
  final double confidence;
  final String confidenceLevel;
  final String reliability;
  final String treatment;
  final bool isValidInput;
  
  Prediction({
    required this.disease,
    required this.diseaseType,
    required this.confidence,
    required this.confidenceLevel,
    required this.reliability,
    required this.treatment,
    required this.isValidInput,
  });
  
  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      disease: json['disease'] ?? '',
      diseaseType: json['disease_type'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      confidenceLevel: json['confidence_level'] ?? '',
      reliability: json['reliability'] ?? '',
      treatment: json['treatment'] ?? '',
      isValidInput: json['is_valid_input'] ?? true,
    );
  }
}

/// Top prediction model
class TopPrediction {
  final String disease;
  final double confidence;
  
  TopPrediction({
    required this.disease,
    required this.confidence,
  });
  
  factory TopPrediction.fromJson(Map<String, dynamic> json) {
    return TopPrediction(
      disease: json['disease'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Disease information model
class DiseaseInfo {
  final String name;
  final String type;
  final String treatment;
  
  DiseaseInfo({
    required this.name,
    required this.type,
    required this.treatment,
  });
  
  factory DiseaseInfo.fromJson(Map<String, dynamic> json) {
    return DiseaseInfo(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      treatment: json['treatment'] ?? '',
    );
  }
}

/// Model information model
class ModelInfo {
  final String architecture;
  final List<int> inputSize;
  final int numClasses;
  final List<String> classes;
  final String modelFile;
  final int parameters;
  
  ModelInfo({
    required this.architecture,
    required this.inputSize,
    required this.numClasses,
    required this.classes,
    required this.modelFile,
    required this.parameters,
  });
  
  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      architecture: json['architecture'] ?? '',
      inputSize: List<int>.from(json['input_size'] ?? []),
      numClasses: json['num_classes'] ?? 0,
      classes: List<String>.from(json['classes'] ?? []),
      modelFile: json['model_file'] ?? '',
      parameters: json['parameters'] ?? 0,
    );
  }
}