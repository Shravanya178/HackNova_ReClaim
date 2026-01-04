import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user.dart';

class CampusSelectionScreen extends StatefulWidget {
  final UserRole? selectedRole;
  
  const CampusSelectionScreen({super.key, this.selectedRole});

  @override
  State<CampusSelectionScreen> createState() => _CampusSelectionScreenState();
}

class _CampusSelectionScreenState extends State<CampusSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCampusId;
  String? _selectedDepartmentId;
  List<Campus> _filteredCampuses = [];
  List<Department> _departments = [];
  bool _isLoadingDepartments = false;
  
  // Track the selected role
  late UserRole _userRole;

  // Sample data - In real app, this would come from Supabase
  final List<Campus> _allCampuses = [
    Campus(
      id: '1',
      name: 'VESIT - Vivekanand Education Society Institute of Technology',
      location: 'Chembur, Mumbai, Maharashtra',
      imageUrl: 'assets/images/vesit.jpg',
    ),
    Campus(
      id: '2',
      name: 'IIT Bombay',
      location: 'Powai, Mumbai, Maharashtra',
      imageUrl: 'assets/images/iitb.jpg',
    ),
    Campus(
      id: '3',
      name: 'VJTI - Veermata Jijabai Technological Institute',
      location: 'Matunga, Mumbai, Maharashtra',
      imageUrl: 'assets/images/vjti.jpg',
    ),
    Campus(
      id: '4',
      name: 'SPIT - Sardar Patel Institute of Technology',
      location: 'Andheri, Mumbai, Maharashtra',
      imageUrl: 'assets/images/spit.jpg',
    ),
    Campus(
      id: '5',
      name: 'DJ Sanghvi College of Engineering',
      location: 'Vile Parle, Mumbai, Maharashtra',
      imageUrl: 'assets/images/djsce.jpg',
    ),
    Campus(
      id: '6',
      name: 'KJ Somaiya College of Engineering',
      location: 'Vidyavihar, Mumbai, Maharashtra',
      imageUrl: 'assets/images/kjsce.jpg',
    ),
    Campus(
      id: '7',
      name: 'Thadomal Shahani Engineering College',
      location: 'Bandra, Mumbai, Maharashtra',
      imageUrl: 'assets/images/tsec.jpg',
    ),
    Campus(
      id: '8',
      name: 'Fr. Conceicao Rodrigues College of Engineering',
      location: 'Bandra, Mumbai, Maharashtra',
      imageUrl: 'assets/images/frcrce.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredCampuses = _allCampuses;
    // Default to student if no role was passed
    _userRole = widget.selectedRole ?? UserRole.student;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Select Campus'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Your Institution',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Text(
                    'Search and select your campus to get started',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Search Field
                  TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for your university or college...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterCampuses('');
                          },
                        )
                      : null,
                ),
                    onChanged: _filterCampuses,
                  ),
                  
                  SizedBox(height: 24.h),
                ],
              ),
            ),
            
            // Campus List
            if (_selectedCampusId == null)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: ListView.builder(
                    itemCount: _filteredCampuses.length,
                    itemBuilder: (context, index) {
                      final campus = _filteredCampuses[index];
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: GestureDetector(
                          onTap: () => _selectCampus(campus),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade100,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Campus Image Placeholder
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 24.sp,
                                  ),
                                ),
                                
                                SizedBox(width: 12.w),
                                
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        campus.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        campus.location,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16.sp,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
            // Department Selection
            if (_selectedCampusId != null)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _allCampuses.firstWhere((c) => c.id == _selectedCampusId).name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCampusId = null;
                                  _selectedDepartmentId = null;
                                  _departments.clear();
                                });
                              },
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      Text(
                        'Select Department',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      if (_isLoadingDepartments)
                        const Center(child: CircularProgressIndicator())
                      else
                        ..._departments.map((department) {
                          final isSelected = _selectedDepartmentId == department.id;
                          
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDepartmentId = department.id;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        department.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primary
                                              : Colors.grey.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check,
                                        color: Theme.of(context).colorScheme.primary,
                                        size: 20.sp,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      
                      SizedBox(height: 24.h),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedDepartmentId != null ? _handleComplete : null,
                          child: const Text('Complete Setup'),
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _filterCampuses(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCampuses = _allCampuses;
      } else {
        _filteredCampuses = _allCampuses
            .where((campus) =>
                campus.name.toLowerCase().contains(query.toLowerCase()) ||
                campus.location.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectCampus(Campus campus) async {
    setState(() {
      _selectedCampusId = campus.id;
      _isLoadingDepartments = true;
    });

    // Simulate loading departments
    await Future.delayed(const Duration(seconds: 1));

    // Sample departments - In real app, fetch from Supabase based on campus ID
    setState(() {
      _departments = [
        Department(id: '1', name: 'Computer Science', campusId: campus.id),
        Department(id: '2', name: 'Information Technology', campusId: campus.id),
        Department(id: '3', name: 'Mechanical Engineering', campusId: campus.id),
        Department(id: '4', name: 'Electrical Engineering', campusId: campus.id),
        Department(id: '5', name: 'Electronics & Telecom', campusId: campus.id),
        Department(id: '6', name: 'AI & Data Science', campusId: campus.id),
      ];
      _isLoadingDepartments = false;
    });
  }

  void _handleComplete() {
    // TODO: Save campus and department to user profile
    // Navigate to appropriate dashboard based on user role
    switch (_userRole) {
      case UserRole.student:
        context.go('/student-dashboard');
        break;
      case UserRole.lab:
        context.go('/lab-dashboard');
        break;
      case UserRole.admin:
        context.go('/admin-dashboard');
        break;
    }
  }
}

class Campus {
  final String id;
  final String name;
  final String location;
  final String imageUrl;

  const Campus({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
  });
}

class Department {
  final String id;
  final String name;
  final String campusId;

  const Department({
    required this.id,
    required this.name,
    required this.campusId,
  });
}