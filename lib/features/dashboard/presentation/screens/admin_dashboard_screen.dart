import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Materials'), Tab(text: 'Campus Zones'), Tab(text: 'Users')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildMaterialsTab(), _buildCampusZonesTab(), _buildUsersTab()],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Users', '234', Icons.people, Colors.blue, '+12 this week')),
              SizedBox(width: 12.w),
              Expanded(child: _buildStatCard('Active Materials', '89', Icons.inventory_2, Colors.green, '+23 captured')),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total CO₂ Saved', '156.8 kg', Icons.eco, Colors.teal, '+8.5kg this month')),
              SizedBox(width: 12.w),
              Expanded(child: _buildStatCard('Active Projects', '45', Icons.rocket_launch, Colors.orange, '12 completed')),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Quick Actions
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Actions', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildActionChip('Add Material Category', Icons.add_circle_outline),
                    _buildActionChip('Configure Carbon Factors', Icons.tune),
                    _buildActionChip('Manage Campus Zones', Icons.location_on),
                    _buildActionChip('User Reports', Icons.assessment),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          
          // Recent Activity
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Activity', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                SizedBox(height: 12.h),
                _buildActivityItem('New user registered', 'Rahul Sharma - Computer Engg', '5 min ago', Icons.person_add, Colors.blue),
                _buildActivityItem('Material captured', 'Arduino boards in Lab A', '15 min ago', Icons.camera_alt, Colors.green),
                _buildActivityItem('Opportunity matched', 'Copper wires → Home Automation', '1 hour ago', Icons.handshake, Colors.purple),
                _buildActivityItem('Carbon milestone', 'Campus reached 150kg CO₂ saved', '2 hours ago', Icons.emoji_events, Colors.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab() {
    final categories = [
      {'name': 'Electronic', 'count': 34, 'factor': 2.5, 'color': Colors.orange},
      {'name': 'Metal', 'count': 23, 'factor': 1.8, 'color': Colors.grey},
      {'name': 'Plastic', 'count': 18, 'factor': 3.2, 'color': Colors.blue},
      {'name': 'Glass', 'count': 12, 'factor': 0.8, 'color': Colors.cyan},
      {'name': 'Chemical', 'count': 8, 'factor': 4.5, 'color': Colors.purple},
      {'name': 'Wood', 'count': 5, 'factor': 0.5, 'color': Colors.brown},
    ];
    
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Material Categories', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  IconButton(icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary), onPressed: () => _showAddCategoryDialog()),
                ],
              ),
              SizedBox(height: 12.h),
              ...categories.map((cat) => _buildCategoryItem(cat['name'] as String, cat['count'] as int, cat['factor'] as double, cat['color'] as Color)),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Carbon Factors (kg CO₂/unit)', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              SizedBox(height: 8.h),
              Text('Adjust the environmental impact calculation for each material type', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
              SizedBox(height: 16.h),
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.tune), label: const Text('Configure Carbon Factors')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCampusZonesTab() {
    final zones = [
      {'name': 'Lab A - Chemistry', 'building': 'Science Block', 'materials': 12, 'active': true},
      {'name': 'Lab B - Electronics', 'building': 'Engineering Block', 'materials': 18, 'active': true},
      {'name': 'Lab C - Mechanical', 'building': 'Engineering Block', 'materials': 8, 'active': true},
      {'name': 'Workshop', 'building': 'Main Building', 'materials': 15, 'active': true},
      {'name': 'Storage Room A', 'building': 'Admin Block', 'materials': 5, 'active': false},
    ];
    
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Campus Zones', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            ElevatedButton.icon(onPressed: () => _showAddZoneDialog(), icon: const Icon(Icons.add), label: const Text('Add Zone')),
          ],
        ),
        SizedBox(height: 16.h),
        ...zones.map((zone) => Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: ListTile(
            leading: Container(
              width: 44.w, height: 44.h,
              decoration: BoxDecoration(color: (zone['active'] as bool) ? Colors.green.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(10.r)),
              child: Icon(Icons.location_on, color: (zone['active'] as bool) ? Colors.green : Colors.grey),
            ),
            title: Text(zone['name'] as String, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
            subtitle: Text('${zone['building']} • ${zone['materials']} materials'),
            trailing: Switch.adaptive(value: zone['active'] as bool, onChanged: (v) {}),
          ),
        )),
      ],
    );
  }

  Widget _buildUsersTab() {
    final users = [
      {'name': 'Rahul Sharma', 'role': 'Student', 'department': 'Computer Engg', 'status': 'Active'},
      {'name': 'Dr. Sharma', 'role': 'Lab Admin', 'department': 'Chemistry', 'status': 'Active'},
      {'name': 'Priya Patel', 'role': 'Student', 'department': 'Electronics', 'status': 'Active'},
      {'name': 'Prof. Singh', 'role': 'Lab Admin', 'department': 'Mechanical', 'status': 'Active'},
      {'name': 'Amit Kumar', 'role': 'Student', 'department': 'IT', 'status': 'Suspended'},
    ];
    
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        ...users.map((user) => Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Text((user['name'] as String).split(' ').map((n) => n[0]).join(), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
            title: Text(user['name'] as String, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
            subtitle: Text('${user['role']} • ${user['department']}'),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(color: user['status'] == 'Active' ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(4.r)),
              child: Text(user['status'] as String, style: TextStyle(color: user['status'] == 'Active' ? Colors.green.shade700 : Colors.red.shade700, fontSize: 11.sp, fontWeight: FontWeight.w600)),
            ),
            onTap: () {},
          ),
        )),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 36.w, height: 36.h, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)), child: Icon(icon, color: color, size: 18.sp)),
              const Spacer(),
              Icon(Icons.trending_up, color: Colors.green, size: 16.sp),
            ],
          ),
          SizedBox(height: 12.h),
          Text(value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          SizedBox(height: 4.h),
          Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
          SizedBox(height: 2.h),
          Text(subtitle, style: TextStyle(fontSize: 10.sp, color: Colors.green.shade600)),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16.sp),
      label: Text(label, style: TextStyle(fontSize: 12.sp)),
      onPressed: () {},
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(width: 36.w, height: 36.h, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)), child: Icon(icon, color: color, size: 16.sp)),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade800)), Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600))])),
          Text(time, style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, int count, double factor, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        children: [
          Container(width: 8.w, height: 40.h, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4.r))),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)), Text('$count items • ${factor}kg CO₂/unit', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600))])),
          IconButton(icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600, size: 20.sp), onPressed: () {}),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Material Category'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(decoration: InputDecoration(labelText: 'Category Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)))),
          SizedBox(height: 12.h),
          TextField(decoration: InputDecoration(labelText: 'Carbon Factor (kg CO₂/unit)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r))), keyboardType: TextInputType.number),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Add'))],
      ),
    );
  }

  void _showAddZoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Campus Zone'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(decoration: InputDecoration(labelText: 'Zone Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)))),
          SizedBox(height: 12.h),
          TextField(decoration: InputDecoration(labelText: 'Building', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)))),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Add'))],
      ),
    );
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
                  child: Icon(Icons.admin_panel_settings, color: Colors.grey.shade700, size: 28.sp),
                ),
                SizedBox(height: 12.h),
                Text('Admin Panel', style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                Text('VESIT Mumbai', style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_outlined, color: Colors.grey.shade800),
            title: Text('Overview', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); setState(() => _tabController.index = 0); },
          ),
          ListTile(
            leading: Icon(Icons.inventory_2_outlined, color: Colors.grey.shade800),
            title: Text('Materials', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); setState(() => _tabController.index = 1); },
          ),
          ListTile(
            leading: Icon(Icons.location_on_outlined, color: Colors.grey.shade800),
            title: Text('Campus Zones', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); setState(() => _tabController.index = 2); },
          ),
          ListTile(
            leading: Icon(Icons.people_outlined, color: Colors.grey.shade800),
            title: Text('Users', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); setState(() => _tabController.index = 3); },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.assessment_outlined, color: Colors.grey.shade800),
            title: Text('Impact Reports', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/impact'); },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: Colors.grey.shade800),
            title: Text('Settings', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/settings'); },
          ),
          const Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); context.go('/student-dashboard'); },
                    icon: Icon(Icons.person, size: 14.sp),
                    label: Text('Student', style: TextStyle(fontSize: 11.sp)),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 6.h)),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); context.go('/lab-dashboard'); },
                    icon: Icon(Icons.science, size: 14.sp),
                    label: Text('Lab', style: TextStyle(fontSize: 11.sp)),
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