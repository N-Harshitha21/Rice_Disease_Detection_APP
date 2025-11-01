import 'dart:convert';
import 'package:uuid/uuid.dart';

class DiseaseResult {
  final String id;
  final String disease;
  final double confidence;
  final String diseaseType; // 'healthy' or 'disease'
  final String treatment;
  final DateTime timestamp;
  final String? imageUrl;
  final Map<String, double> allPredictions;
  final List<Map<String, dynamic>> topPredictions;

  DiseaseResult({
    String? id,
    required this.disease,
    required this.confidence,
    required this.diseaseType,
    required this.treatment,
    DateTime? timestamp,
    this.imageUrl,
    required this.allPredictions,
    required this.topPredictions,
  }) : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  // Create from API response
  factory DiseaseResult.fromApiResponse(Map<String, dynamic> data) {
    final prediction = data['prediction'] as Map<String, dynamic>;
    
    // Handle both demo and production API response formats
    Map<String, double> allPreds = {};
    if (data['all_predictions'] != null) {
      allPreds = Map<String, double>.from(data['all_predictions']);
    }
    
    // Convert top_predictions to proper format
    List<Map<String, dynamic>> topPreds = [];
    if (data['top_predictions'] != null) {
      final rawTopPreds = data['top_predictions'] as List;
      topPreds = rawTopPreds.map((pred) => {
        'disease': pred['disease'] ?? pred['diseaseName'] ?? 'Unknown',
        'confidence': (pred['confidence'] ?? 0.0).toDouble(),
        'disease_type': pred['disease_type'] ?? pred['diseaseType'] ?? 'unknown',
      }).toList();
    }
    
    return DiseaseResult(
      disease: prediction['disease'] ?? 'Unknown',
      confidence: (prediction['confidence'] ?? 0.0).toDouble(),
      diseaseType: prediction['disease_type'] ?? 'disease',
      treatment: prediction['treatment'] ?? 'Consult agricultural expert',
      allPredictions: allPreds,
      topPredictions: topPreds,
      timestamp: DateTime.now(),
    );
  }

  // Create from Firestore
  factory DiseaseResult.fromFirestore(Map<String, dynamic> data, String docId) {
    return DiseaseResult(
      id: docId,
      disease: data['disease'] ?? 'Unknown',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      diseaseType: data['diseaseType'] ?? 'disease',
      treatment: data['treatment'] ?? 'Consult agricultural expert',
      imageUrl: data['imageUrl'],
      allPredictions: Map<String, double>.from(data['allPredictions'] ?? {}),
      topPredictions: List<Map<String, dynamic>>.from(data['topPredictions'] ?? []),
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'disease': disease,
      'confidence': confidence,
      'diseaseType': diseaseType,
      'treatment': treatment,
      'imageUrl': imageUrl,
      'allPredictions': allPredictions,
      'topPredictions': topPredictions,
      'timestamp': timestamp,
    };
  }

  // Check if disease is healthy
  bool get isHealthy => diseaseType == 'healthy' || disease.toLowerCase().contains('healthy');

  // Get formatted confidence percentage
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  // Get confidence level
  String get confidenceLevel {
    if (confidence >= 0.9) return 'Very High';
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.7) return 'Medium';
    if (confidence >= 0.6) return 'Low';
    return 'Very Low';
  }

  // Get severity color
  String get severityColor {
    if (isHealthy) return 'green';
    if (confidence >= 0.8) return 'red';
    if (confidence >= 0.6) return 'orange';
    return 'yellow';
  }
}

// Keep the old model for backward compatibility
class DiseaseResultModel {
  final String id;
  final String predictedDisease;
  final double confidence;
  final String confidenceLevel;
  final List<PredictionResult> topPredictions;
  final String imagePath;
  final DateTime timestamp;
  final String recommendation;
  final List<String> treatmentSteps;

  DiseaseResultModel({
    String? id,
    required this.predictedDisease,
    required this.confidence,
    required this.confidenceLevel,
    required this.topPredictions,
    required this.imagePath,
    DateTime? timestamp,
    required this.recommendation,
    required this.treatmentSteps,
  }) : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  // Create a copy with updated fields
  DiseaseResultModel copyWith({
    String? id,
    String? predictedDisease,
    double? confidence,
    String? confidenceLevel,
    List<PredictionResult>? topPredictions,
    String? imagePath,
    DateTime? timestamp,
    String? recommendation,
    List<String>? treatmentSteps,
  }) {
    return DiseaseResultModel(
      id: id ?? this.id,
      predictedDisease: predictedDisease ?? this.predictedDisease,
      confidence: confidence ?? this.confidence,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      topPredictions: topPredictions ?? this.topPredictions,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      recommendation: recommendation ?? this.recommendation,
      treatmentSteps: treatmentSteps ?? this.treatmentSteps,
    );
  }

  // Convert to JSON
  String toJson() {
    return jsonEncode({
      'id': id,
      'predictedDisease': predictedDisease,
      'confidence': confidence,
      'confidenceLevel': confidenceLevel,
      'topPredictions': topPredictions.map((p) => p.toMap()).toList(),
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'recommendation': recommendation,
      'treatmentSteps': treatmentSteps,
    });
  }

  // Create from JSON
  factory DiseaseResultModel.fromJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return DiseaseResultModel.fromMap(data);
  }

  // Create from Map
  factory DiseaseResultModel.fromMap(Map<String, dynamic> data) {
    return DiseaseResultModel(
      id: data['id'] ?? const Uuid().v4(),
      predictedDisease: data['predictedDisease'] ?? '',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      confidenceLevel: data['confidenceLevel'] ?? '',
      topPredictions: (data['topPredictions'] as List<dynamic>?)
          ?.map((p) => PredictionResult.fromMap(p as Map<String, dynamic>))
          .toList() ?? [],
      imagePath: data['imagePath'] ?? '',
      timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      recommendation: data['recommendation'] ?? '',
      treatmentSteps: List<String>.from(data['treatmentSteps'] ?? []),
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'predictedDisease': predictedDisease,
      'confidence': confidence,
      'confidenceLevel': confidenceLevel,
      'topPredictions': topPredictions.map((p) => p.toMap()).toList(),
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'recommendation': recommendation,
      'treatmentSteps': treatmentSteps,
    };
  }

  // Get severity based on confidence
  String get severity {
    if (confidence >= 0.9) return 'Critical';
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.7) return 'Moderate';
    if (confidence >= 0.6) return 'Low';
    return 'Very Low';
  }

  // Check if disease is healthy
  bool get isHealthy => predictedDisease.toLowerCase().contains('healthy');

  // Get formatted confidence percentage
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  @override
  String toString() {
    return 'DiseaseResultModel(id: $id, predictedDisease: $predictedDisease, confidence: $confidence, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiseaseResultModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

class PredictionResult {
  final String diseaseName;
  final double confidence;
  final int rank;

  PredictionResult({
    required this.diseaseName,
    required this.confidence,
    required this.rank,
  });

  // Create from Map
  factory PredictionResult.fromMap(Map<String, dynamic> data) {
    return PredictionResult(
      diseaseName: data['diseaseName'] ?? '',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      rank: data['rank'] ?? 0,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'diseaseName': diseaseName,
      'confidence': confidence,
      'rank': rank,
    };
  }

  // Get formatted confidence percentage
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  @override
  String toString() {
    return 'PredictionResult(diseaseName: $diseaseName, confidence: $confidence, rank: $rank)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PredictionResult && 
           other.diseaseName == diseaseName && 
           other.confidence == confidence &&
           other.rank == rank;
  }

  @override
  int get hashCode {
    return diseaseName.hashCode ^ confidence.hashCode ^ rank.hashCode;
  }
}