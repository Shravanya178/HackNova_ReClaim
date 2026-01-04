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
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () {}),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () => context.push('/notifications')),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () => context.push('/settings')),
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
                  Expanded(child: _buildActionCard(context, 'Vision AI', 'Hybrid intelligence', Icons.visibility, Colors.deepPurple, () => context.push('/lab-dashboard/vision'))),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildActionCard(context, 'Capture', 'Quick scan', Icons.camera_alt, Colors.blue, () => context.push('/lab-dashboard/capture'))),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _buildActionCard(context, 'Inventory', 'Manage materials', Icons.inventory_2, Colors.green, () => context.push('/lab-dashboard/inventory'))),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildActionCard(context, 'Opportunities', 'AI matches', Icons.auto_awesome, Colors.orange, () => context.push('/lab-dashboard/opportunities'))),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Pending Opportunities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pending Opportunities', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  TextButton(onPressed: () => context.push('/lab-dashboard/opportunities'), child: const Text('View All')),
                ],
              ),
              SizedBox(height: 8.h),
              _buildOpportunityCard(context, 'Arduino Boards', 'Smart Traffic System', 'Rahul Sharma', 92, 1.8),
              SizedBox(height: 8.h),
              _buildOpportunityCard(context, 'Copper Wires', 'Home Automation Hub', 'Priya Patel', 87, 2.4),
              
              SizedBox(height: 24.h),
              
              // Additional Features
              Row(
                children: [
                  Expanded(child: _buildFeatureCard(context, 'Lifecycle', 'Track materials', Icons.timeline, () => context.push('/lifecycle'))),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildFeatureCard(context, 'Barter', 'Skill exchange', Icons.swap_horiz, () => context.push('/barter'))),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildFeatureCard(context, 'Impact', 'Dashboard', Icons.analytics, () => context.push('/impact'))),
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
            width: 44.w, height: 44.h,
            decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(10.r)),
            child: Icon(Icons.auto_awesome, color: Colors.purple, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                Text('$project • $student', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12.r)),
                child: Text('$matchPercent%', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11.sp, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 4.h),
              Text('$carbonSaved kg CO₂', style: TextStyle(fontSize: 10.sp, color: Colors.green.shade700)),
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