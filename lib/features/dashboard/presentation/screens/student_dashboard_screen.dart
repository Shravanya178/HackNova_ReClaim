import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('ReClaim'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Badge(smallSize: 8, child: const Icon(Icons.notifications_outlined, color: Colors.white)),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text('SA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome back, Shravanya!', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                              Text('VESIT Mumbai • Information Technology', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.sp)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text('Discover materials and build sustainably', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.sp)),
                  ],
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Quick Stats
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, 'Materials', '12', Icons.inventory_2_outlined, Colors.blue)),
                  SizedBox(width: 10.w),
                  Expanded(child: _buildStatCard(context, 'CO₂ Saved', '4.2kg', Icons.eco_outlined, Colors.green)),
                  SizedBox(width: 10.w),
                  Expanded(child: _buildStatCard(context, 'Projects', '3', Icons.rocket_launch_outlined, Colors.orange)),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Quick Actions
              Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              SizedBox(height: 12.h),
              
              Row(
                children: [
                  Expanded(child: _buildActionCard(context, 'Discover', 'Find materials', Icons.map_outlined, Colors.blue, () => context.push('/student-dashboard/discovery'))),
                  SizedBox(width: 10.w),
                  Expanded(child: _buildActionCard(context, 'Request', 'Post needs', Icons.add_circle_outline, Colors.green, () => context.push('/requests'))),
                  SizedBox(width: 10.w),
                  Expanded(child: _buildActionCard(context, 'Barter', 'Skill exchange', Icons.swap_horiz, Colors.purple, () => context.push('/barter'))),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Nearby Materials
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Materials Near You', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  TextButton(onPressed: () => context.push('/student-dashboard/discovery'), child: const Text('See All')),
                ],
              ),
              SizedBox(height: 8.h),
              
              _buildMaterialCard(context, 'Arduino Boards', 'Lab A - Chemistry', '5 units', '0.2 km', 'Electronic'),
              SizedBox(height: 8.h),
              _buildMaterialCard(context, 'Copper Wire Spools', 'Lab B - Electronics', '3 kg', '0.4 km', 'Metal'),
              SizedBox(height: 8.h),
              _buildMaterialCard(context, 'Acrylic Sheets', 'Workshop', '10 sheets', '0.6 km', 'Plastic'),
              
              SizedBox(height: 24.h),
              
              // Recent Activity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  TextButton(onPressed: () => context.push('/notifications'), child: const Text('View All')),
                ],
              ),
              SizedBox(height: 8.h),
              
              _buildActivityItem('Material request matched', 'Arduino boards for Smart Traffic System', '2 hours ago', Icons.check_circle, Colors.green),
              _buildActivityItem('New opportunity', 'Copper wires available near you', '5 hours ago', Icons.notifications, Colors.blue),
              _buildActivityItem('Impact milestone', 'You\'ve saved 4kg of CO₂!', '1 day ago', Icons.emoji_events, Colors.amber),
              
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
      // Removed bottomNavigationBar as per request; only hamburger menu (AppDrawer) remains
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
      child: Column(
        children: [
          Container(
            width: 36.w, height: 36.h,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          Text(title, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey.shade100)),
          child: Column(
            children: [
              Container(
                width: 40.w, height: 40.h,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(height: 8.h),
              Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              Text(subtitle, style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, String name, String location, String quantity, String distance, String type) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
      child: Row(
        children: [
          Container(
            width: 44.w, height: 44.h,
            decoration: BoxDecoration(color: _getTypeColor(type).withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(_getTypeIcon(type), color: _getTypeColor(type), size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12.sp, color: Colors.grey.shade500),
                    SizedBox(width: 4.w),
                    Text(location, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(quantity, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
              Text(distance, style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
            width: 36.w, height: 36.h,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'electronic': return Colors.orange;
      case 'metal': return Colors.blueGrey;
      case 'plastic': return Colors.blue;
      default: return Colors.green;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'electronic': return Icons.memory;
      case 'metal': return Icons.hardware;
      case 'plastic': return Icons.local_drink;
      default: return Icons.inventory_2;
    }
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 16.h),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, color: Colors.grey.shade700, size: 28.sp),
                ),
                SizedBox(height: 12.h),
                Text('Shravanya', style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                Text('VESIT • IT Dept', style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_outlined, color: Colors.grey.shade800),
            title: Text('Dashboard', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.map_outlined, color: Colors.grey.shade800),
            title: Text('Discover Materials', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/student-dashboard/discovery'); },
          ),
          ListTile(
            leading: Icon(Icons.swap_horiz, color: Colors.grey.shade800),
            title: Text('Skill Barter', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/barter'); },
          ),
          ListTile(
            leading: Icon(Icons.add_circle_outline, color: Colors.grey.shade800),
            title: Text('My Requests', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/requests'); },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.assessment_outlined, color: Colors.grey.shade800),
            title: Text('Impact Dashboard', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/impact'); },
          ),
          ListTile(
            leading: Icon(Icons.timeline_outlined, color: Colors.grey.shade800),
            title: Text('Material Lifecycle', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/lifecycle'); },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: Colors.grey.shade800),
            title: Text('Settings', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/settings'); },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); context.go('/lab-dashboard'); },
                    icon: Icon(Icons.science, size: 14.sp),
                    label: Text('Lab', style: TextStyle(fontSize: 11.sp)),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 6.h)),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); context.go('/admin-dashboard'); },
                    icon: Icon(Icons.admin_panel_settings, size: 14.sp),
                    label: Text('Admin', style: TextStyle(fontSize: 11.sp)),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 6.h)),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout_outlined, color: Colors.grey.shade800),
            title: Text('Change Role', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.go('/role-selection'); },
          ),
        ],
      ),
    );
  }
}