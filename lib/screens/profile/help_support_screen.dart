import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Help Section
          _buildSectionCard(
            context,
            title: 'Quick Help',
            icon: Icons.help_outline,
            children: [
              _buildHelpTile(
                icon: Icons.camera_alt,
                title: 'How to take good photos',
                subtitle: 'Tips for better disease detection',
                onTap: () => _showPhotoTipsDialog(context),
              ),
              _buildHelpTile(
                icon: Icons.visibility,
                title: 'Understanding results',
                subtitle: 'How to interpret predictions',
                onTap: () => _showResultsHelpDialog(context),
              ),
              _buildHelpTile(
                icon: Icons.agriculture,
                title: 'Disease information',
                subtitle: 'Learn about rice diseases',
                onTap: () => _showDiseaseInfoDialog(context),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // FAQ Section
          _buildSectionCard(
            context,
            title: 'Frequently Asked Questions',
            icon: Icons.quiz,
            children: [
              _buildFAQTile(
                question: 'Why is my prediction confidence low?',
                answer: 'Low confidence can be due to poor image quality, unclear symptoms, or early-stage disease. Try taking a clearer photo with better lighting.',
              ),
              _buildFAQTile(
                question: 'Can I use photos from my gallery?',
                answer: 'Yes! You can select images from your gallery or take new photos with the camera.',
              ),
              _buildFAQTile(
                question: 'How accurate is the detection?',
                answer: 'Our AI model has been trained on thousands of rice leaf images and achieves high accuracy. However, always consult with agricultural experts for important decisions.',
              ),
              _buildFAQTile(
                question: 'What should I do after detection?',
                answer: 'Follow the treatment recommendations provided. For severe cases or uncertain results, consult with local agricultural extension services.',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Contact Support Section
          _buildSectionCard(
            context,
            title: 'Contact Support',
            icon: Icons.support_agent,
            children: [
              _buildContactTile(
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'support@ricediseasedetector.com',
                onTap: () => _launchEmail(),
              ),
              _buildContactTile(
                icon: Icons.phone,
                title: 'Phone Support',
                subtitle: '+1 (555) 123-4567',
                onTap: () => _launchPhone(),
              ),
              _buildContactTile(
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Available 24/7',
                onTap: () => _showChatDialog(context),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Resources Section
          _buildSectionCard(
            context,
            title: 'Additional Resources',
            icon: Icons.library_books,
            children: [
              _buildResourceTile(
                icon: Icons.video_library,
                title: 'Video Tutorials',
                subtitle: 'Watch how-to videos',
                onTap: () => _launchURL('https://youtube.com'),
              ),
              _buildResourceTile(
                icon: Icons.article,
                title: 'User Manual',
                subtitle: 'Complete app guide',
                onTap: () => _showUserManual(context),
              ),
              _buildResourceTile(
                icon: Icons.bug_report,
                title: 'Report a Bug',
                subtitle: 'Help us improve the app',
                onTap: () => _showBugReportDialog(context),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Emergency Contact
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
                  Icons.emergency,
                  color: AppTheme.warningOrange,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Emergency Agricultural Support',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningOrange,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'For urgent crop issues, contact your local agricultural extension office immediately.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _launchPhone(emergency: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Emergency Helpline'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildFAQTile({
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer),
        ),
      ],
    );
  }

  Widget _buildContactTile({
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
    );
  }

  Widget _buildResourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: onTap,
    );
  }

  void _showPhotoTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Tips'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('For best results:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Use natural daylight or bright lighting'),
              Text('• Focus on the leaf with clear symptoms'),
              Text('• Fill the frame with the leaf'),
              Text('• Avoid shadows and reflections'),
              Text('• Hold the camera steady'),
              Text('• Take multiple photos if unsure'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showResultsHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Understanding Results'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Confidence Levels:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• High (80%+): Very reliable prediction'),
              Text('• Medium (60-80%): Good prediction'),
              Text('• Low (<60%): Needs expert verification'),
              SizedBox(height: 12),
              Text('Colors:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Green: Healthy or low severity'),
              Text('• Orange: Moderate severity'),
              Text('• Red: High severity or urgent'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDiseaseInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rice Disease Information'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Our app detects 8 major rice diseases:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Bacterial Leaf Blight'),
              Text('• Brown Spot'),
              Text('• Leaf Blast'),
              Text('• Leaf Scald'),
              Text('• Narrow Brown Leaf Spot'),
              Text('• Rice Hispa'),
              Text('• Sheath Blight'),
              Text('• Healthy Rice Leaf'),
              SizedBox(height: 12),
              Text('Each detection includes treatment recommendations and severity assessment.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text('Live chat feature is coming soon! For immediate assistance, please use email or phone support.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showUserManual(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Manual'),
        content: const Text('The complete user manual will be available in the next update. For now, use the quick help tips and FAQ.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const Text('To report a bug, please email us at support@ricediseasedetector.com with:\n\n• Description of the issue\n• Steps to reproduce\n• Screenshots if applicable\n• Your device information'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail(subject: 'Bug Report');
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _launchEmail({String? subject}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@ricediseasedetector.com',
      queryParameters: {
        'subject': subject ?? 'Support Request',
      },
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone({bool emergency = false}) async {
    final String phoneNumber = emergency ? '+1-800-CROP-HELP' : '+1-555-123-4567';
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}