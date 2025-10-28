import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/disease_detection_provider.dart';
import '../../utils/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DiseaseDetectionProvider>(
        builder: (context, provider, child) {
          final stats = provider.getDetectionStatistics();
          
          if (stats['totalDetections'] == 0) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No statistics available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Statistics will appear here after you start detecting rice diseases',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                Row(
                  children: [
                    Expanded(child: _buildStatCard(
                      'Total Detections',
                      stats['totalDetections'].toString(),
                      Icons.analytics,
                      AppTheme.primaryGreen,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard(
                      'Healthy Plants',
                      stats['healthyCount'].toString(),
                      Icons.eco,
                      AppTheme.successGreen,
                    )),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(child: _buildStatCard(
                      'Diseased Plants',
                      stats['diseasedCount'].toString(),
                      Icons.warning,
                      AppTheme.errorRed,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard(
                      'Avg. Confidence',
                      '${(stats['averageConfidence'] * 100).toStringAsFixed(1)}%',
                      Icons.speed,
                      AppTheme.warningOrange,
                    )),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Most Common Disease
                _buildSectionHeader('Most Common Detection'),
                const SizedBox(height: 8),
                _buildMostCommonDiseaseCard(stats['mostCommonDisease']),
                
                const SizedBox(height: 24),
                
                // Disease Distribution
                _buildSectionHeader('Disease Distribution'),
                const SizedBox(height: 8),
                _buildDiseaseDistribution(stats['diseaseDistribution']),
                
                const SizedBox(height: 24),
                
                // Health Summary
                _buildSectionHeader('Health Summary'),
                const SizedBox(height: 8),
                _buildHealthSummary(stats),
                
                const SizedBox(height: 24),
                
                // Confidence Analysis
                _buildSectionHeader('Confidence Analysis'),
                const SizedBox(height: 8),
                _buildConfidenceAnalysis(provider.detectionHistory),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildMostCommonDiseaseCard(String disease) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getDiseaseColor(disease).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getDiseaseIcon(disease),
                color: _getDiseaseColor(disease),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disease,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDiseaseDescription(disease),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseDistribution(Map<String, int> distribution) {
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...sortedEntries.map((entry) {
              final percentage = (entry.value / distribution.values.reduce((a, b) => a + b) * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(_getDiseaseColor(entry.key)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSummary(Map<String, dynamic> stats) {
    final total = stats['totalDetections'];
    final healthy = stats['healthyCount'];
    final diseased = stats['diseasedCount'];
    final healthPercentage = total > 0 ? (healthy / total * 100) : 0.0;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${healthPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: healthPercentage >= 70 ? AppTheme.successGreen : 
                                 healthPercentage >= 50 ? AppTheme.warningOrange : AppTheme.errorRed,
                        ),
                      ),
                      const Text('Healthy Plants', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: healthPercentage / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              healthPercentage >= 70 ? AppTheme.successGreen :
                              healthPercentage >= 50 ? AppTheme.warningOrange : AppTheme.errorRed,
                            ),
                            strokeWidth: 6,
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          healthPercentage >= 70 ? Icons.sentiment_very_satisfied :
                          healthPercentage >= 50 ? Icons.sentiment_neutral : Icons.sentiment_dissatisfied,
                          color: healthPercentage >= 70 ? AppTheme.successGreen :
                                 healthPercentage >= 50 ? AppTheme.warningOrange : AppTheme.errorRed,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${(100 - healthPercentage).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorRed,
                        ),
                      ),
                      const Text('Need Treatment', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getHealthAdvice(healthPercentage),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceAnalysis(List history) {
    if (history.isEmpty) return const SizedBox.shrink();
    
    int highConfidence = 0;
    int mediumConfidence = 0;
    int lowConfidence = 0;
    
    for (final result in history) {
      if (result.confidence >= 0.8) {
        highConfidence++;
      } else if (result.confidence >= 0.6) {
        mediumConfidence++;
      } else {
        lowConfidence++;
      }
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildConfidenceRow('High Confidence (≥80%)', highConfidence, AppTheme.successGreen, history.length),
            const SizedBox(height: 8),
            _buildConfidenceRow('Medium Confidence (60-79%)', mediumConfidence, AppTheme.warningOrange, history.length),
            const SizedBox(height: 8),
            _buildConfidenceRow('Low Confidence (<60%)', lowConfidence, AppTheme.errorRed, history.length),
            const SizedBox(height: 16),
            Text(
              'Recommendation: ${_getConfidenceRecommendation(highConfidence, history.length)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceRow(String label, int count, Color color, int total) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(
          '$count (${percentage.toStringAsFixed(1)}%)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getDiseaseColor(String disease) {
    if (disease.toLowerCase().contains('healthy')) return AppTheme.successGreen;
    if (disease.toLowerCase().contains('blight') || disease.toLowerCase().contains('blast')) return AppTheme.errorRed;
    if (disease.toLowerCase().contains('spot') || disease.toLowerCase().contains('scald')) return AppTheme.warningOrange;
    return AppTheme.primaryGreen;
  }

  IconData _getDiseaseIcon(String disease) {
    if (disease.toLowerCase().contains('healthy')) return Icons.eco;
    if (disease.toLowerCase().contains('blight')) return Icons.warning;
    if (disease.toLowerCase().contains('blast')) return Icons.flash_on;
    if (disease.toLowerCase().contains('spot')) return Icons.circle;
    if (disease.toLowerCase().contains('hispa')) return Icons.bug_report;
    return Icons.local_hospital;
  }

  String _getDiseaseDescription(String disease) {
    if (disease.toLowerCase().contains('healthy')) return 'Plants are in good condition';
    if (disease.toLowerCase().contains('blight')) return 'Bacterial infection requiring immediate attention';
    if (disease.toLowerCase().contains('blast')) return 'Fungal disease that can cause significant damage';
    if (disease.toLowerCase().contains('spot')) return 'Fungal infection affecting leaf health';
    if (disease.toLowerCase().contains('hispa')) return 'Insect pest causing leaf damage';
    return 'Requires agricultural expert consultation';
  }

  String _getHealthAdvice(double healthPercentage) {
    if (healthPercentage >= 80) {
      return 'Excellent! Your plants are mostly healthy. Continue good practices.';
    } else if (healthPercentage >= 60) {
      return 'Good health status. Monitor diseased plants and apply treatments.';
    } else if (healthPercentage >= 40) {
      return 'Moderate concerns. Increase monitoring and consider preventive measures.';
    } else {
      return 'High alert! Many plants need treatment. Consult agricultural expert.';
    }
  }

  String _getConfidenceRecommendation(int highConfidence, int total) {
    final percentage = total > 0 ? (highConfidence / total * 100) : 0.0;
    
    if (percentage >= 80) {
      return 'Excellent detection accuracy. Trust the recommendations.';
    } else if (percentage >= 60) {
      return 'Good accuracy. Consider expert verification for low confidence results.';
    } else {
      return 'Consider taking clearer photos and consulting experts for verification.';
    }
  }
}