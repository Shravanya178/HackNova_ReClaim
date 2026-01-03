import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MaterialCaptureScreen extends StatefulWidget {
  const MaterialCaptureScreen({super.key});

  @override
  State<MaterialCaptureScreen> createState() => _MaterialCaptureScreenState();
}

class _MaterialCaptureScreenState extends State<MaterialCaptureScreen> {
  bool _isAnalyzing = false;
  bool _hasImage = false;
  File? _capturedImage;
  List<DetectedMaterial> _detectedMaterials = [];
  final ImagePicker _picker = ImagePicker();
  
  final TextEditingController _notesController = TextEditingController();
  String _selectedLocation = 'Lab A - Chemistry';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Material Capture'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_detectedMaterials.isNotEmpty)
            TextButton.icon(
              onPressed: _generateOpportunities,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text('Generate', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera/Image Section
            Container(
              width: double.infinity,
              height: 300.h,
              margin: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _hasImage
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: _capturedImage != null 
                            ? Image.file(
                                _capturedImage!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.grey.shade300,
                                child: Icon(
                                  Icons.image,
                                  size: 80.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                        ),
                        if (_detectedMaterials.isNotEmpty)
                          ..._detectedMaterials.map((material) => Positioned(
                            left: material.boundingBox.left,
                            top: material.boundingBox.top,
                            child: Container(
                              width: material.boundingBox.width,
                              height: material.boundingBox.height,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _getMaterialColor(material.type),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: _getMaterialColor(material.type),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6.r),
                                      bottomRight: Radius.circular(6.r),
                                    ),
                                  ),
                                  child: Text(
                                    '${material.type} ${(material.confidence * 100).toInt()}%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                        if (_isAnalyzing)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(color: Colors.white),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'AI Analyzing Materials...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 64.sp, color: Colors.grey.shade400),
                        SizedBox(height: 16.h),
                        Text(
                          'Capture waste materials',
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'AI will detect and categorize materials',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _captureImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14.h)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _uploadImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Upload'),
                      style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14.h)),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            if (_detectedMaterials.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Detected Materials', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    Text('${_detectedMaterials.length} items', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              
              SizedBox(height: 12.h),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _detectedMaterials.length,
                itemBuilder: (context, index) => _buildMaterialCard(_detectedMaterials[index], index),
              ),
              
              SizedBox(height: 24.h),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedLocation,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: ['Lab A - Chemistry', 'Lab B - Electronics', 'Lab C - Mechanical', 'Workshop - Main Building', 'Storage Room - Block A']
                            .map((location) => DropdownMenuItem(value: location, child: Text(location, style: TextStyle(color: Colors.grey.shade800)))).toList(),
                        onChanged: (value) => setState(() => _selectedLocation = value!),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16.h),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Additional Notes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      style: TextStyle(color: Colors.grey.shade800),
                      decoration: InputDecoration(
                        hintText: 'Any additional information about the materials...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              Padding(
                padding: EdgeInsets.all(16.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generateOpportunities,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Opportunities'),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16.h), backgroundColor: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(DetectedMaterial material, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(color: _getMaterialColor(material.type).withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
                child: Icon(_getMaterialIcon(material.type), color: _getMaterialColor(material.type), size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.type, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4.r)),
                      child: Text('${(material.confidence * 100).toInt()}% confidence', style: TextStyle(color: Colors.green.shade700, fontSize: 11.sp, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              IconButton(icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600), onPressed: () => _editMaterial(index)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildMaterialField('Quantity', material.quantity),
              SizedBox(width: 12.w),
              _buildMaterialField('Condition', material.condition),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialField(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: Colors.grey.shade200)),
            child: Text(value, style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Color _getMaterialColor(String type) {
    switch (type.toLowerCase()) {
      case 'plastic': return Colors.blue;
      case 'metal': return Colors.grey.shade700;
      case 'electronic': return Colors.orange;
      case 'glass': return Colors.cyan;
      case 'wood': return Colors.brown;
      case 'chemical': return Colors.purple;
      default: return Colors.green;
    }
  }

  IconData _getMaterialIcon(String type) {
    switch (type.toLowerCase()) {
      case 'plastic': return Icons.local_drink;
      case 'metal': return Icons.hardware;
      case 'electronic': return Icons.memory;
      case 'glass': return Icons.science;
      case 'wood': return Icons.forest;
      case 'chemical': return Icons.science;
      default: return Icons.inventory_2;
    }
  }

  void _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() { 
          _capturedImage = File(image.path);
          _hasImage = true; 
          _isAnalyzing = true; 
        });
        
        // Simulate AI analysis
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isAnalyzing = false;
          _detectedMaterials = [
            DetectedMaterial(type: 'Electronic', quantity: '5 units', condition: 'Good', confidence: 0.94, boundingBox: Rect.fromLTWH(20.w, 40.h, 100.w, 80.h)),
            DetectedMaterial(type: 'Metal', quantity: '2 kg', condition: 'Fair', confidence: 0.87, boundingBox: Rect.fromLTWH(140.w, 100.h, 120.w, 90.h)),
            DetectedMaterial(type: 'Plastic', quantity: '3 units', condition: 'Good', confidence: 0.91, boundingBox: Rect.fromLTWH(80.w, 200.h, 80.w, 60.h)),
          ];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing camera: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _uploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() { 
          _capturedImage = File(image.path);
          _hasImage = true; 
          _isAnalyzing = true; 
        });
        
        // Simulate AI analysis
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isAnalyzing = false;
          _detectedMaterials = [
            DetectedMaterial(type: 'Electronic', quantity: '5 units', condition: 'Good', confidence: 0.94, boundingBox: Rect.fromLTWH(20.w, 40.h, 100.w, 80.h)),
            DetectedMaterial(type: 'Metal', quantity: '2 kg', condition: 'Fair', confidence: 0.87, boundingBox: Rect.fromLTWH(140.w, 100.h, 120.w, 90.h)),
            DetectedMaterial(type: 'Plastic', quantity: '3 units', condition: 'Good', confidence: 0.91, boundingBox: Rect.fromLTWH(80.w, 200.h, 80.w, 60.h)),
          ];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing gallery: $e'), backgroundColor: Colors.red),
      );
    }
  }
  void _editMaterial(int index) {}

  void _generateOpportunities() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [Icon(Icons.check_circle, color: Colors.green, size: 28.sp), SizedBox(width: 8.w), const Text('Success!')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_detectedMaterials.length} materials captured successfully.'),
            SizedBox(height: 8.h),
            const Text('Opportunity cards are being generated based on detected materials and student demand.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); context.go('/lab-dashboard/opportunities'); }, child: const Text('View Opportunities')),
          ElevatedButton(onPressed: () { Navigator.pop(context); context.go('/lab-dashboard/inventory'); }, child: const Text('View Inventory')),
        ],
      ),
    );
  }
}

class DetectedMaterial {
  final String type;
  final String quantity;
  final String condition;
  final double confidence;
  final Rect boundingBox;

  DetectedMaterial({required this.type, required this.quantity, required this.condition, required this.confidence, required this.boundingBox});

  DetectedMaterial copyWith({String? type, String? quantity, String? condition, double? confidence, Rect? boundingBox}) {
    return DetectedMaterial(type: type ?? this.type, quantity: quantity ?? this.quantity, condition: condition ?? this.condition, confidence: confidence ?? this.confidence, boundingBox: boundingBox ?? this.boundingBox);
  }
}
