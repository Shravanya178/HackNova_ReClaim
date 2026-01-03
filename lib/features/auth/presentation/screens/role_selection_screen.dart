import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  final List<RoleOption> _roleOptions = [
    RoleOption(
      role: UserRole.student,
      title: 'Student',
      subtitle: 'Find materials for your projects',
      description: 'Discover available materials on campus, request specific items, and contribute to sustainability.',
      icon: Icons.school_outlined,
      color: Colors.blue,
    ),
    RoleOption(
      role: UserRole.lab,
      title: 'Lab / Faculty',
      subtitle: 'Share materials and resources',
      description: 'Upload materials, generate opportunities for students, and track environmental impact.',
      icon: Icons.science_outlined,
      color: Colors.green,
    ),
    RoleOption(
      role: UserRole.admin,
      title: 'Administrator',
      subtitle: 'Manage campus sustainability',
      description: 'Oversee platform usage, manage users, and analyze campus-wide impact metrics.',
      icon: Icons.admin_panel_settings_outlined,
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Select Your Role'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              
              Text(
                'How will you be using ReClaim?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 8.h),
              
              Text(
                'Choose your role to customize your experience',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              
              SizedBox(height: 32.h),
              
              Expanded(
                child: ListView.builder(
                  itemCount: _roleOptions.length,
                  itemBuilder: (context, index) {
                    final option = _roleOptions[index];
                    final isSelected = _selectedRole == option.role;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = option.role;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? option.color.withOpacity(0.1)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? option.color
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: option.color.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60.w,
                                height: 60.h,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? option.color
                                      : option.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  option.icon,
                                  size: 30.sp,
                                  color: isSelected ? Colors.white : option.color,
                                ),
                              ),
                              
                              SizedBox(width: 16.w),
                              
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.title,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? option.color : null,
                                      ),
                                    ),
                                    
                                    SizedBox(height: 4.h),
                                    
                                    Text(
                                      option.subtitle,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    
                                    SizedBox(height: 8.h),
                                    
                                    Text(
                                      option.description,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: option.color,
                                  size: 24.sp,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 24.h),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedRole != null ? _handleContinue : null,
                  child: const Text('Continue'),
                ),
              ),
              
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_selectedRole != null) {
      // Pass selected role to campus selection
      context.go('/campus-selection', extra: _selectedRole);
    }
  }
}

class RoleOption {
  final UserRole role;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  const RoleOption({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}