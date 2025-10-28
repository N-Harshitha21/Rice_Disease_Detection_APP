import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo and Title
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rice Disease Detector',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          'About This App',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Rice Disease Detector is an AI-powered mobile application designed to help farmers and agricultural professionals identify rice plant diseases quickly and accurately. Using advanced machine learning techniques, our app can detect 8 major rice diseases from simple leaf photographs.',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Key Features',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem('🔬', 'AI-powered disease detection'),
                    _buildFeatureItem('📱', 'Easy-to-use mobile interface'),
                    _buildFeatureItem('📊', 'Detailed confidence scoring'),
                    _buildFeatureItem('💊', 'Treatment recommendations'),
                    _buildFeatureItem('📈', 'Detection history tracking'),
                    _buildFeatureItem('🌐', 'Offline capability'),
                    _buildFeatureItem('🔒', 'Secure data storage'),
                    _buildFeatureItem('🆓', 'Free to use'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Supported Diseases
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Supported Diseases',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDiseaseItem('Bacterial Leaf Blight'),
                    _buildDiseaseItem('Brown Spot'),
                    _buildDiseaseItem('Healthy Rice Leaf'),
                    _buildDiseaseItem('Leaf Blast'),
                    _buildDiseaseItem('Leaf Scald'),
                    _buildDiseaseItem('Narrow Brown Leaf Spot'),
                    _buildDiseaseItem('Rice Hispa'),
                    _buildDiseaseItem('Sheath Blight'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Technology
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.computer, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Technology',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTechItem('🧠', 'TensorFlow Machine Learning'),
                    _buildTechItem('📱', 'Flutter Cross-Platform Framework'),
                    _buildTechItem('🔥', 'Firebase Backend Services'),
                    _buildTechItem('🏗️', 'MobileNetV2 Architecture'),
                    _buildTechItem('☁️', 'Cloud Storage Integration'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Development Team
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.group, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Development Team',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Developed by a dedicated team of agricultural technology specialists and machine learning engineers committed to supporting farmers worldwide.',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contact and Links
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contact_mail, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Contact & Links',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildLinkItem(
                      icon: Icons.email,
                      title: 'Email Support',
                      subtitle: 'support@ricediseasedetector.com',
                      onTap: () => _launchEmail(),
                    ),
                    _buildLinkItem(
                      icon: Icons.web,
                      title: 'Website',
                      subtitle: 'www.ricediseasedetector.com',
                      onTap: () => _launchURL('https://ricediseasedetector.com'),
                    ),
                    _buildLinkItem(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      subtitle: 'View our privacy policy',
                      onTap: () => _showPrivacyPolicy(context),
                    ),
                    _buildLinkItem(
                      icon: Icons.gavel,
                      title: 'Terms of Service',
                      subtitle: 'View terms and conditions',
                      onTap: () => _showTermsOfService(context),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warningOrange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.warningOrange,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Important Disclaimer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warningOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This app provides AI-based predictions for educational and assistance purposes. Always consult with qualified agricultural professionals for important farming decisions. The developers are not liable for any agricultural or financial losses.',
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Copyright
            Text(
              '© 2025 Rice Disease Detector. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildDiseaseItem(String disease) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(child: Text(disease)),
        ],
      ),
    );
  }

  Widget _buildTechItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.launch, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@ricediseasedetector.com',
      queryParameters: {
        'subject': 'Rice Disease Detector - General Inquiry',
      },
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Rice Disease Detector Privacy Policy\n\n'
            'Last updated: January 2025\n\n'
            '1. Information We Collect\n'
            '• Images you capture or upload for disease detection\n'
            '• Detection results and history\n'
            '• Account information (email, user ID)\n'
            '• Usage analytics and app performance data\n\n'
            '2. How We Use Your Information\n'
            '• To provide disease detection services\n'
            '• To improve our AI models\n'
            '• To sync your data across devices\n'
            '• To provide customer support\n\n'
            '3. Data Security\n'
            '• All data is encrypted in transit and at rest\n'
            '• We use Firebase for secure data storage\n'
            '• Images are processed securely and not shared\n\n'
            '4. Your Rights\n'
            '• You can delete your account and data anytime\n'
            '• You can export your detection history\n'
            '• You can contact us for data inquiries\n\n'
            'For the complete privacy policy, visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchURL('https://ricediseasedetector.com/privacy');
            },
            child: const Text('Full Policy'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Rice Disease Detector Terms of Service\n\n'
            'Last updated: January 2025\n\n'
            '1. Acceptance of Terms\n'
            'By using this app, you agree to these terms.\n\n'
            '2. Service Description\n'
            'We provide AI-based rice disease detection for educational and assistance purposes.\n\n'
            '3. User Responsibilities\n'
            '• Use the app responsibly and ethically\n'
            '• Do not upload inappropriate content\n'
            '• Consult professionals for important decisions\n\n'
            '4. Disclaimer\n'
            '• Results are AI predictions, not professional diagnosis\n'
            '• We are not liable for agricultural or financial losses\n'
            '• Always seek expert advice for critical decisions\n\n'
            '5. Privacy\n'
            'Your privacy is important to us. See our Privacy Policy for details.\n\n'
            'For complete terms, visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchURL('https://ricediseasedetector.com/terms');
            },
            child: const Text('Full Terms'),
          ),
        ],
      ),
    );
  }
}