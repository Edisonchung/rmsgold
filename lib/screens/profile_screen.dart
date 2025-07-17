// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _mfaEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.currentUser;
          
          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                
                // Account Information
                _buildAccountSection(user),
                const SizedBox(height: 24),
                
                // Security Settings
                _buildSecuritySection(),
                const SizedBox(height: 24),
                
                // Preferences
                _buildPreferencesSection(),
                const SizedBox(height: 24),
                
                // Support & Help
                _buildSupportSection(),
                const SizedBox(height: 24),
                
                // Logout Button
                _buildLogoutButton(auth),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.amber.shade700,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user.kycApproved ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: user.kycApproved ? Colors.green.shade300 : Colors.orange.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user.kycApproved ? Icons.verified : Icons.pending,
                    size: 16,
                    color: user.kycApproved ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.kycApproved ? 'KYC Verified' : 'KYC Pending',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: user.kycApproved ? Colors.green.shade700 : Colors.orange.shade700,
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

  Widget _buildAccountSection(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              icon: Icons.person,
              title: 'Full Name',
              subtitle: user.name,
              onTap: () => _editProfile('name'),
            ),
            _buildInfoTile(
              icon: Icons.email,
              title: 'Email Address',
              subtitle: user.email,
              onTap: () => _editProfile('email'),
            ),
            _buildInfoTile(
              icon: Icons.phone,
              title: 'Phone Number',
              subtitle: user.phone,
              onTap: () => _editProfile('phone'),
            ),
            _buildInfoTile(
              icon: Icons.calendar_today,
              title: 'Member Since',
              subtitle: '${user.joinDate.day}/${user.joinDate.month}/${user.joinDate.year}',
              showTrailing: false,
            ),
            if (!user.kycApproved)
              _buildInfoTile(
                icon: Icons.upload_file,
                title: 'Complete KYC Verification',
                subtitle: 'Upload your documents to start trading',
                onTap: () => _completeKYC(),
                titleColor: Colors.orange.shade700,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              icon: Icons.lock,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () => _changePassword(),
            ),
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or face recognition',
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
              },
            ),
            _buildSwitchTile(
              icon: Icons.security,
              title: 'Two-Factor Authentication',
              subtitle: 'Add an extra layer of security',
              value: _mfaEnabled,
              onChanged: (value) {
                setState(() {
                  _mfaEnabled = value;
                });
              },
            ),
            _buildInfoTile(
              icon: Icons.account_balance,
              title: 'Bank Account',
              subtitle: 'Manage linked bank accounts',
              onTap: () => _manageBankAccounts(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Receive price alerts and updates',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildInfoTile(
              icon: Icons.price_change,
              title: 'Price Alerts',
              subtitle: 'Set custom gold price alerts',
              onTap: () => _managePriceAlerts(),
            ),
            _buildInfoTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English (Malaysia)',
              onTap: () => _changeLanguage(),
            ),
            _buildInfoTile(
              icon: Icons.download,
              title: 'Download Statements',
              subtitle: 'Get your trading statements',
              onTap: () => _downloadStatements(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support & Help',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              icon: Icons.help_center,
              title: 'Help Center',
              subtitle: 'FAQs and user guides',
              onTap: () => _openHelpCenter(),
            ),
            _buildInfoTile(
              icon: Icons.chat,
              title: 'Live Chat Support',
              subtitle: '24/7 customer support',
              onTap: () => _startLiveChat(),
            ),
            _buildInfoTile(
              icon: Icons.phone,
              title: 'Call Support',
              subtitle: '+60 3-1234 5678',
              onTap: () => _callSupport(),
            ),
            _buildInfoTile(
              icon: Icons.feedback,
              title: 'Send Feedback',
              subtitle: 'Help us improve our service',
              onTap: () => _sendFeedback(),
            ),
            _buildInfoTile(
              icon: Icons.info,
              title: 'About RMS Gold',
              subtitle: 'Version 1.0.0',
              onTap: () => _showAbout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool showTrailing = true,
    Color? titleColor,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.amber.shade100,
        child: Icon(icon, color: Colors.amber.shade700),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: showTrailing && onTap != null 
        ? const Icon(Icons.chevron_right)
        : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.amber.shade100,
        child: Icon(icon, color: Colors.amber.shade700),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _confirmLogout(auth),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _editProfile(String field) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit $field - Feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _completeKYC() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete KYC Verification'),
        content: const Text(
          'To complete your KYC verification, please upload:\n\n'
          '• Front and back of your IC\n'
          '• A clear selfie photo\n'
          '• Proof of address (utility bill)\n\n'
          'This process usually takes 1-2 business days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('KYC upload feature - Coming soon'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Upload Documents'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Change password feature - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _manageBankAccounts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bank account management - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _managePriceAlerts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Price alerts feature - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _changeLanguage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Language settings - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _downloadStatements() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statement download - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help center - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _startLiveChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live chat support - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _callSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling support: +60 3-1234 5678'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback form - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'RMS Gold Account-i',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 RMS Gold. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'RMS Gold Account-i is a digital gold trading platform that enables you to buy, sell, and manage gold investments securely.',
        ),
      ],
    );
  }

  void _confirmLogout(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
