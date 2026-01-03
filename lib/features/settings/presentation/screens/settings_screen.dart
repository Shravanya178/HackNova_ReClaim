import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account'),
            _buildSettingsCard([
              _buildSettingsTile(icon: Icons.person_outline, title: 'Edit Profile', subtitle: 'Update your personal information', onTap: () {}),
              _buildSettingsTile(icon: Icons.school_outlined, title: 'Campus Info', subtitle: 'VESIT Mumbai • Information Technology', onTap: () {}),
              _buildSettingsTile(icon: Icons.verified_outlined, title: 'Verify Account', subtitle: 'Verify with college email', trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4.r)),
                child: Text('Verified', style: TextStyle(color: Colors.green.shade700, fontSize: 11.sp, fontWeight: FontWeight.w600)),
              )),
            ]),
            
            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSettingsCard([
              _buildSwitchTile(icon: Icons.notifications_outlined, title: 'Push Notifications', subtitle: 'Receive notifications on your device', value: _notificationsEnabled, onChanged: (v) => setState(() => _notificationsEnabled = v)),
              _buildSwitchTile(icon: Icons.email_outlined, title: 'Email Notifications', subtitle: 'Receive updates via email', value: _emailNotifications, onChanged: (v) => setState(() => _emailNotifications = v)),
              _buildSettingsTile(icon: Icons.tune, title: 'Notification Preferences', subtitle: 'Customize what you get notified about', onTap: () {}),
            ]),
            
            // Appearance Section
            _buildSectionHeader('Appearance'),
            _buildSettingsCard([
              _buildSwitchTile(icon: Icons.dark_mode_outlined, title: 'Dark Mode', subtitle: 'Use dark theme', value: _darkMode, onChanged: (v) => setState(() => _darkMode = v)),
              _buildDropdownTile(icon: Icons.language, title: 'Language', value: _selectedLanguage, options: ['English', 'Hindi', 'Marathi'], onChanged: (v) => setState(() => _selectedLanguage = v!)),
            ]),
            
            // Privacy Section
            _buildSectionHeader('Privacy & Security'),
            _buildSettingsCard([
              _buildSettingsTile(icon: Icons.lock_outline, title: 'Change Password', subtitle: 'Update your account password', onTap: () {}),
              _buildSettingsTile(icon: Icons.visibility_outlined, title: 'Profile Visibility', subtitle: 'Control who can see your profile', onTap: () {}),
              _buildSettingsTile(icon: Icons.history, title: 'Activity Log', subtitle: 'View your recent activity', onTap: () {}),
            ]),
            
            // Data Section
            _buildSectionHeader('Data & Storage'),
            _buildSettingsCard([
              _buildSettingsTile(icon: Icons.download_outlined, title: 'Download My Data', subtitle: 'Export your account data', onTap: () {}),
              _buildSettingsTile(icon: Icons.delete_outline, title: 'Clear Cache', subtitle: 'Free up storage space', trailing: Text('24 MB', style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp)), onTap: () {}),
            ]),
            
            // Support Section
            _buildSectionHeader('Support'),
            _buildSettingsCard([
              _buildSettingsTile(icon: Icons.help_outline, title: 'Help Center', subtitle: 'Get help with ReClaim', onTap: () {}),
              _buildSettingsTile(icon: Icons.feedback_outlined, title: 'Send Feedback', subtitle: 'Help us improve the app', onTap: () {}),
              _buildSettingsTile(icon: Icons.bug_report_outlined, title: 'Report a Bug', subtitle: 'Let us know about issues', onTap: () {}),
            ]),
            
            // About Section
            _buildSectionHeader('About'),
            _buildSettingsCard([
              _buildSettingsTile(icon: Icons.info_outline, title: 'About ReClaim', subtitle: 'Version 1.0.0', onTap: () {}),
              _buildSettingsTile(icon: Icons.description_outlined, title: 'Terms of Service', subtitle: 'Read our terms', onTap: () {}),
              _buildSettingsTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', subtitle: 'How we handle your data', onTap: () {}),
              _buildSettingsTile(icon: Icons.article_outlined, title: 'Open Source Licenses', subtitle: 'Third-party libraries used', onTap: () {}),
            ]),
            
            SizedBox(height: 16.h),
            
            // Sign Out Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showSignOutDialog(),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: EdgeInsets.symmetric(vertical: 14.h)),
                ),
              ),
            ),
            
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
      child: Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade600, letterSpacing: 0.5)),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required String subtitle, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 40.w, height: 40.h,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(10.r)),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20.sp),
      ),
      title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return ListTile(
      leading: Container(
        width: 40.w, height: 40.h,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(10.r)),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20.sp),
      ),
      title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
    );
  }

  Widget _buildDropdownTile({required IconData icon, required String title, required String value, required List<String> options, required ValueChanged<String?> onChanged}) {
    return ListTile(
      leading: Container(
        width: 40.w, height: 40.h,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(10.r)),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20.sp),
      ),
      title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); context.go('/auth'); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}