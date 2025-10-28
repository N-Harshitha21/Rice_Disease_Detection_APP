import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Service class for Rice Disease Detection API
class RiceDiseaseApiService {
  // API Configuration
  static const String baseUrl = 'http://192.168.182.140:5000'; // Main API server
  static const String predictEndpoint = '/predict';
  static const String healthEndpoint = '/health';
  static const String diseasesEndpoint = '/diseases';
  static const String modelInfoEndpoint = '/model-info';
  
  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  /// Check API health status
  static Future<ApiResponse<HealthStatus>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$healthEndpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);
      
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
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$predictEndpoint'),
      );
      
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      // Send request
      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(PredictionResult.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(errorData['error'] ?? 'Prediction failed');
      }
    } catch (e) {
      return ApiResponse.error('Prediction failed: $e');
    }
  }
  
  /// Predict disease from base64 image
  static Future<ApiResponse<PredictionResult>> predictFromBase64(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$predictEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image_base64': base64Image}),
      ).timeout(timeoutDuration);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(PredictionResult.fromJson(data));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(errorData['error'] ?? 'Prediction failed');
      }
    } catch (e) {
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
      ).timeout(timeoutDuration);
      
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
      ).timeout(timeoutDuration);
      
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