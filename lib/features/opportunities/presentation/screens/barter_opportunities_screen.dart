import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BarterOpportunitiesScreen extends StatefulWidget {
  const BarterOpportunitiesScreen({super.key});

  @override
  State<BarterOpportunitiesScreen> createState() => _BarterOpportunitiesScreenState();
}

class _BarterOpportunitiesScreenState extends State<BarterOpportunitiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<BarterOpportunity> _opportunities = [
    BarterOpportunity(id: '1', labName: 'Lab A - Chemistry', skillRequired: 'Arduino Programming', projectDescription: 'Help setup IoT sensors for air quality monitoring', hoursNeeded: 4, materialsOffered: ['Arduino Nano (2)', 'Gas Sensors (3)', 'Breadboard'], postedBy: 'Dr. Sharma', status: BarterStatus.open),
    BarterOpportunity(id: '2', labName: 'Lab B - Electronics', skillRequired: 'PCB Design', projectDescription: 'Design custom PCB for student research project', hoursNeeded: 8, materialsOffered: ['Copper Clad Board', 'Etchant Solution', 'Components Kit'], postedBy: 'Prof. Patel', status: BarterStatus.open),
    BarterOpportunity(id: '3', labName: 'Workshop - Mechanical', skillRequired: '3D Printing', projectDescription: 'Print enclosures for lab equipment', hoursNeeded: 6, materialsOffered: ['PLA Filament (2kg)', 'PETG Filament (1kg)'], postedBy: 'Mr. Singh', status: BarterStatus.applied),
    BarterOpportunity(id: '4', labName: 'Lab C - Biotech', skillRequired: 'Data Analysis', projectDescription: 'Analyze experiment data using Python', hoursNeeded: 5, materialsOffered: ['Petri Dishes (20)', 'Test Tubes (50)'], postedBy: 'Dr. Gupta', status: BarterStatus.approved),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Skill Barter'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [Tab(text: 'Available'), Tab(text: 'Applied'), Tab(text: 'Approved')],
        ),
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.purple.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: Colors.white, size: 32.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exchange Skills for Materials', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text('Help labs with your skills and get materials for your projects!', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.sp)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOpportunityList(_opportunities.where((o) => o.status == BarterStatus.open).toList()),
                _buildOpportunityList(_opportunities.where((o) => o.status == BarterStatus.applied).toList()),
                _buildOpportunityList(_opportunities.where((o) => o.status == BarterStatus.approved).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityList(List<BarterOpportunity> opportunities) {
    if (opportunities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 64.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text('No opportunities yet', style: TextStyle(fontSize: 18.sp, color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: opportunities.length,
      itemBuilder: (context, index) => _buildOpportunityCard(opportunities[index]),
    );
  }

  Widget _buildOpportunityCard(BarterOpportunity opportunity) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w, height: 48.h,
                  decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(10.r)),
                  child: Icon(Icons.science, color: Colors.purple.shade700, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opportunity.labName, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                      SizedBox(height: 2.h),
                      Text('Posted by ${opportunity.postedBy}', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _buildStatusBadge(opportunity.status),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skill Required
                Row(
                  children: [
                    Icon(Icons.psychology, size: 18.sp, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 8.w),
                    Text('Skill Needed:', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20.r)),
                      child: Text(opportunity.skillRequired, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                    ),
                  ],
                ),
                
                SizedBox(height: 12.h),
                
                // Description
                Text(opportunity.projectDescription, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
                
                SizedBox(height: 12.h),
                
                // Time Commitment
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16.sp, color: Colors.grey.shade500),
                    SizedBox(width: 4.w),
                    Text('${opportunity.hoursNeeded} hours estimated', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                // Materials Offered
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8.r)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.card_giftcard, size: 16.sp, color: Colors.green.shade700),
                          SizedBox(width: 6.w),
                          Text('Materials You\'ll Receive:', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: opportunity.materialsOffered.map((m) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r), border: Border.all(color: Colors.green.shade200)),
                          child: Text(m, style: TextStyle(fontSize: 11.sp, color: Colors.green.shade800)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          if (opportunity.status == BarterStatus.open)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('View Details'))),
                  SizedBox(width: 12.w),
                  Expanded(flex: 2, child: ElevatedButton.icon(onPressed: () => _applyForBarter(opportunity), icon: const Icon(Icons.send), label: const Text('Apply'))),
                ],
              ),
            ),
          
          if (opportunity.status == BarterStatus.approved)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat),
                  label: const Text('Contact Lab'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BarterStatus status) {
    Color color;
    String text;
    switch (status) {
      case BarterStatus.open: color = Colors.blue; text = 'Open'; break;
      case BarterStatus.applied: color = Colors.orange; text = 'Applied'; break;
      case BarterStatus.approved: color = Colors.green; text = 'Approved'; break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.w600)),
    );
  }

  void _applyForBarter(BarterOpportunity opportunity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for Barter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You\'re applying to help ${opportunity.labName} with ${opportunity.skillRequired}.'),
            SizedBox(height: 16.h),
            TextField(maxLines: 3, decoration: InputDecoration(labelText: 'Why are you a good fit?', hintText: 'Describe your experience...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _opportunities.indexOf(opportunity);
                _opportunities[index] = opportunity.copyWith(status: BarterStatus.applied);
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application submitted!'), backgroundColor: Colors.green));
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

enum BarterStatus { open, applied, approved }

class BarterOpportunity {
  final String id;
  final String labName;
  final String skillRequired;
  final String projectDescription;
  final int hoursNeeded;
  final List<String> materialsOffered;
  final String postedBy;
  final BarterStatus status;

  BarterOpportunity({required this.id, required this.labName, required this.skillRequired, required this.projectDescription, required this.hoursNeeded, required this.materialsOffered, required this.postedBy, required this.status});

  BarterOpportunity copyWith({String? id, String? labName, String? skillRequired, String? projectDescription, int? hoursNeeded, List<String>? materialsOffered, String? postedBy, BarterStatus? status}) {
    return BarterOpportunity(id: id ?? this.id, labName: labName ?? this.labName, skillRequired: skillRequired ?? this.skillRequired, projectDescription: projectDescription ?? this.projectDescription, hoursNeeded: hoursNeeded ?? this.hoursNeeded, materialsOffered: materialsOffered ?? this.materialsOffered, postedBy: postedBy ?? this.postedBy, status: status ?? this.status);
  }
}