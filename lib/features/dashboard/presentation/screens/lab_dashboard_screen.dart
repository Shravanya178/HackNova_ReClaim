import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LabDashboardScreen extends StatelessWidget {
  const LabDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('ReClaim Lab'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () => context.push('/notifications')),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () => context.push('/settings')),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(Icons.science, color: Colors.white, size: 30.sp),
                  ),
                  SizedBox(height: 12.h),
                  Text('Lab A - Chemistry', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  Text('VESIT Mumbai', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.sp)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Capture Materials'),
              onTap: () { Navigator.pop(context); context.push('/lab-dashboard/capture'); },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Inventory'),
              onTap: () { Navigator.pop(context); context.push('/lab-dashboard/inventory'); },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Opportunities'),
              onTap: () { Navigator.pop(context); context.push('/lab-dashboard/opportunities'); },
            ),
            ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: const Text('Requests'),
              onTap: () { Navigator.pop(context); context.push('/requests'); },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.timeline_outlined),
              title: const Text('Lifecycle Tracking'),
              onTap: () { Navigator.pop(context); context.push('/lifecycle'); },
            ),
            ListTile(
              leading: const Icon(Icons.assessment_outlined),
              title: const Text('Lab Reports'),
              onTap: () { Navigator.pop(context); context.push('/impact'); },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () { Navigator.pop(context); context.push('/settings'); },
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: Colors.blue.shade700),
              title: Text('Switch to Student Mode', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); context.go('/student-dashboard'); },
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Change Role'),
              onTap: () { Navigator.pop(context); context.go('/role-selection'); },
            ),
          ],
        ),
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
                  gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12.r)),
                          child: Icon(Icons.science, color: Colors.white, size: 28.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Lab A - Chemistry', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                              Text('VESIT Mumbai', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickStat('Materials', '23', Icons.inventory_2_outlined),
                        _buildQuickStat('Matches', '8', Icons.handshake_outlined),
                        _buildQuickStat('CO₂ Saved', '12.5kg', Icons.eco_outlined),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Quick Actions
              Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _buildActionCard(context, 'Capture Materials', 'AI-powered detection', Icons.camera_alt, Colors.blue, () => context.push('/lab-dashboard/capture'))),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildActionCard(context, 'View Inventory', 'Manage materials', Icons.inventory_2, Colors.green, () => context.push('/lab-dashboard/inventory'))),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _buildActionCard(context, 'Opportunities', 'AI-generated matches', Icons.auto_awesome, Colors.purple, () => context.push('/lab-dashboard/opportunities'))),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildActionCard(context, 'Requests', 'Student requests', Icons.inbox, Colors.orange, () => context.push('/requests'))),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Pending Opportunities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Pending Opportunities', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800), overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 8.w),
                  TextButton(onPressed: () => context.push('/lab-dashboard/opportunities'), child: Text('View All', style: TextStyle(fontSize: 12.sp))),
                ],
              ),
              SizedBox(height: 8.h),
              _buildOpportunityCard(context, 'Arduino Boards', 'Smart Traffic System', 'Rahul Sharma', 92, 1.8),
              SizedBox(height: 8.h),
              _buildOpportunityCard(context, 'Copper Wires', 'Home Automation Hub', 'Priya Patel', 87, 2.4),
              
              SizedBox(height: 24.h),
              
              // Lab Management
              Row(
                children: [
                  Expanded(child: _buildFeatureCard(context, 'Lifecycle', 'Track usage', Icons.timeline, () => context.push('/lifecycle'))),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildFeatureCard(context, 'Reports', 'Lab analytics', Icons.assessment, () => context.push('/impact'))),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildFeatureCard(context, 'Approve', 'Pending', Icons.check_circle_outline, () => context.push('/requests'))),
                ],
              ),
              
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 22.sp),
        SizedBox(height: 6.h),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11.sp)),
      ],
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
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey.shade100)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w, height: 44.h,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              SizedBox(height: 12.h),
              Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              SizedBox(height: 2.h),
              Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(BuildContext context, String material, String project, String student, int matchPercent, double carbonSaved) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
            width: 40.w, height: 40.h,
            decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(10.r)),
            child: Icon(Icons.auto_awesome, color: Colors.purple, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800), overflow: TextOverflow.ellipsis),
                Text('$project', style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10.r)),
                child: Text('$matchPercent%', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10.sp, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 2.h),
              Text('$carbonSaved kg', style: TextStyle(fontSize: 9.sp, color: Colors.green.shade700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
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
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24.sp),
              SizedBox(height: 6.h),
              Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              Text(subtitle, style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}