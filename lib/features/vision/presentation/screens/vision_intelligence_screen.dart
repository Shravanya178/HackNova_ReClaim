import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reclaim/core/services/hybrid_vision_service.dart';
import 'package:reclaim/core/services/gemini_vision_service.dart';

class VisionIntelligenceScreen extends StatefulWidget {
  const VisionIntelligenceScreen({super.key});

  @override
  State<VisionIntelligenceScreen> createState() => _VisionIntelligenceScreenState();
}

class _VisionIntelligenceScreenState extends State<VisionIntelligenceScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  bool _isInitializing = true;
  HybridAnalysisResult? _analysisResult;
  HybridInitResult? _initResult;
  final ImagePicker _picker = ImagePicker();
  final HybridVisionService _visionService = HybridVisionService();
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() => _isInitializing = true);
    
    // Load saved API key
    final savedKey = await _visionService.getGeminiApiKey();
    if (savedKey != null) {
      _apiKeyController.text = savedKey;
    }
    
    // Initialize services
    final result = await _visionService.initialize(geminiApiKey: savedKey);
    
    setState(() {
      _initResult = result;
      _isInitializing = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    
    setState(() => _isAnalyzing = true);
    
    try {
      final result = await _visionService.analyzeImage(_selectedImage!);
      
      setState(() {
        _isAnalyzing = false;
        _analysisResult = result;
      });

      if (result.hasError) {
        _showError(result.error!);
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showError('Analysis failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _addToInventory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Materials added to inventory successfully!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => context.push('/lab-dashboard/inventory'),
        ),
      ),
    );
    
    setState(() {
      _selectedImage = null;
      _analysisResult = null;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Vision Intelligence'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  SizedBox(height: 16.h),
                  _buildImageSection(),
                  SizedBox(height: 16.h),
                  if (_analysisResult != null && !_analysisResult!.hasError) ...[
                    _buildAnalysisResults(),
                    SizedBox(height: 16.h),
                    _buildActionButtons(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    final isGeminiReady = _initResult?.geminiReady ?? false;
    final isYoloReady = _initResult?.yoloReady ?? false;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.visibility, color: Colors.white, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hybrid Vision AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _initResult?.message ?? 'Initializing...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildStatusChip('YOLO', isYoloReady, Icons.offline_bolt),
              SizedBox(width: 8.w),
              _buildStatusChip('Gemini', isGeminiReady, Icons.cloud),
            ],
          ),
          if (!isGeminiReady) ...[
            SizedBox(height: 12.h),
            InkWell(
              onTap: () => _showSettingsDialog(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.key, color: Colors.white, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Configure Gemini API Key',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : icon,
            color: isActive ? Colors.white : Colors.white70,
            size: 14.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.grey.shade700, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Capture Material',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          if (_selectedImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => setState(() {
                        _selectedImage = null;
                        _analysisResult = null;
                      }),
                      icon: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 18.sp),
                      ),
                    ),
                  ),
                  if (_isAnalyzing)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 12.h),
                            Text(
                              'Analyzing with AI...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _visionService.isGeminiReady 
                                ? 'Using Gemini Vision' 
                                : 'Using offline detection',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeImage,
                icon: Icon(_isAnalyzing ? Icons.hourglass_empty : Icons.auto_awesome),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze with AI'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              height: 180.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 48.sp, color: Colors.grey.shade400),
                  SizedBox(height: 12.h),
                  Text(
                    'Capture or select an image',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    final result = _analysisResult!;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with source info
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.green, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Analysis Results',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: result.isOnline ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      result.isOnline ? Icons.cloud_done : Icons.cloud_off,
                      color: result.isOnline ? Colors.green : Colors.orange,
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      result.sourceDescription,
                      style: TextStyle(
                        color: result.isOnline ? Colors.green : Colors.orange,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Processing info
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.timer, size: 12.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                '${result.processingTimeMs}ms',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.category, size: 12.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                '${result.materials.length} materials detected',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Offline warning if applicable
          if (result.offlineWarning != null) ...[
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _getWarningColor(result.offlineWarning!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: _getWarningColor(result.offlineWarning!).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getWarningIcon(result.offlineWarning!),
                    color: _getWarningColor(result.offlineWarning!),
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _formatWarningMessage(result.offlineWarning!),
                      style: TextStyle(
                        color: _getWarningColor(result.offlineWarning!).shade800,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],
          
          // Materials List
          ...result.materials.map((material) => _buildMaterialCard(material)).toList(),
          
          // Project Suggestions
          if (result.suggestedProjects.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildProjectSuggestionsSection(result.suggestedProjects),
          ],
          
          SizedBox(height: 16.h),
          
          // Overall Notes
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Analysis Notes',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  result.overallNotes,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Recommended Next Step
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Recommended: ${result.recommendedNextStep}',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(MaterialAnalysis material) {
    Color safetyColor;
    IconData safetyIcon;
    
    switch (material.safetyFlag) {
      case 'Safe (Visual)':
        safetyColor = Colors.green;
        safetyIcon = Icons.check_circle;
        break;
      case 'Caution':
        safetyColor = Colors.orange;
        safetyIcon = Icons.warning;
        break;
      case 'Restricted':
        safetyColor = Colors.red;
        safetyIcon = Icons.dangerous;
        break;
      default:
        safetyColor = Colors.grey;
        safetyIcon = Icons.help;
    }
    
    Color reusabilityColor;
    if (material.reuseSuitability.contains('Likely')) {
      reusabilityColor = Colors.green;
    } else if (material.reuseSuitability.contains('Possibly')) {
      reusabilityColor = Colors.orange;
    } else {
      reusabilityColor = Colors.red;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  material.materialType,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: safetyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(safetyIcon, color: safetyColor, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      material.safetyFlag,
                      style: TextStyle(
                        color: safetyColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          
          // Quantity & Size
          Row(
            children: [
              _buildInfoChip(Icons.numbers, material.estimatedQuantity),
              SizedBox(width: 8.w),
              _buildInfoChip(Icons.straighten, material.estimatedSize),
            ],
          ),
          SizedBox(height: 8.h),
          
          // Condition
          Row(
            children: [
              Text(
                'Condition: ',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              Text(
                '${material.condition.structural} structural, ${material.condition.visibleDamage} damage',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          
          if (material.condition.defects.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Wrap(
              spacing: 4.w,
              runSpacing: 4.h,
              children: material.condition.defects.map((defect) => 
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    defect,
                    style: TextStyle(fontSize: 10.sp, color: Colors.orange.shade700),
                  ),
                ),
              ).toList(),
            ),
          ],
          
          SizedBox(height: 8.h),
          
          // Reusability
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: reusabilityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              material.reuseSuitability,
              style: TextStyle(
                color: reusabilityColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          SizedBox(height: 8.h),
          
          // Confidence Scores
          Row(
            children: [
              _buildConfidenceIndicator('ID', material.confidence.materialIdentification),
              SizedBox(width: 12.w),
              _buildConfidenceIndicator('Condition', material.confidence.conditionAssessment),
              SizedBox(width: 12.w),
              _buildConfidenceIndicator('Qty', material.confidence.quantityEstimation),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          // Reasoning
          Text(
            material.reasoning,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.grey.shade600),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(String label, double value) {
    Color color;
    if (value >= 0.85) {
      color = Colors.green;
    } else if (value >= 0.7) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }
    
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
        ),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedImage = null;
                _analysisResult = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Another'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _addToInventory,
            icon: const Icon(Icons.add),
            label: const Text('Add to Inventory'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              backgroundColor: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 8.w),
            const Text('API Settings'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gemini API Key',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _apiKeyController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your Gemini API key',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Get your free API key from:',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 4.h),
              SelectableText(
                'https://makersuite.google.com/app/apikey',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Without API key, only offline YOLO detection will be available.',
                        style: TextStyle(fontSize: 11.sp, color: Colors.blue.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final apiKey = _apiKeyController.text.trim();
              if (apiKey.isNotEmpty) {
                await _visionService.saveGeminiApiKey(apiKey);
                await _initializeService();
              }
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API key saved!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.visibility, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 8.w),
            const Text('Vision Intelligence'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How it works:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              _buildHelpItem('1', 'Capture or select an image of materials'),
              _buildHelpItem('2', 'YOLO runs locally for basic detection (offline)'),
              _buildHelpItem('3', 'Gemini analyzes for detailed assessment (online)'),
              _buildHelpItem('4', 'Review safety flags and conditions'),
              _buildHelpItem('5', 'Add approved materials to inventory'),
              
              SizedBox(height: 16.h),
              Text(
                'Analysis Modes:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              _buildModeInfo('Hybrid', 'YOLO + Gemini for best results', Colors.green),
              _buildModeInfo('Gemini', 'Vision AI for detailed analysis', Colors.blue),
              _buildModeInfo('YOLO', 'Offline ML model detection', Colors.orange),
              _buildModeInfo('Heuristic', 'Color-based analysis (fallback)', Colors.grey),
              
              SizedBox(height: 16.h),
              Text(
                'Supported Materials:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 4.w,
                runSpacing: 4.h,
                children: [
                  'PCBs', 'Electronics', 'Motors', 'Metals', 'Wood',
                  'Plastics', 'Batteries', 'Glassware', 'Tools', 'Cables'
                ].map((e) => Chip(
                  label: Text(e, style: TextStyle(fontSize: 11.sp)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildModeInfo(String mode, String description, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '$mode: ',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
          ),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSuggestionsSection(List<ProjectSuggestion> projects) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.purple, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Suggested Projects',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...projects.map((project) => _buildProjectCard(project)).toList(),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ProjectSuggestion project) {
    MaterialColor complexityColor;
    switch (project.complexity.toLowerCase()) {
      case 'beginner':
        complexityColor = Colors.green;
        break;
      case 'advanced':
        complexityColor = Colors.red;
        break;
      default:
        complexityColor = Colors.orange;
    }

    IconData categoryIcon;
    switch (project.category.toLowerCase()) {
      case 'electronics':
        categoryIcon = Icons.memory;
        break;
      case 'robotics':
        categoryIcon = Icons.smart_toy;
        break;
      case 'furniture':
        categoryIcon = Icons.chair;
        break;
      case 'iot':
        categoryIcon = Icons.wifi;
        break;
      case 'art':
        categoryIcon = Icons.palette;
        break;
      default:
        categoryIcon = Icons.construction;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(categoryIcon, color: Colors.purple, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  project.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: complexityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: complexityColor.withOpacity(0.3)),
                ),
                child: Text(
                  project.complexity,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: complexityColor.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            project.description,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 14.sp, color: Colors.grey.shade600),
              SizedBox(width: 4.w),
              Text(
                project.estimatedBuildTime,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.category, size: 14.sp, color: Colors.grey.shade600),
              SizedBox(width: 4.w),
              Text(
                project.category,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (project.materialsUsed.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: project.materialsUsed.map((material) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    material,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods for warning message formatting
  MaterialColor _getWarningColor(String warning) {
    if (warning.toLowerCase().contains('incomplete') || 
        warning.toLowerCase().contains('invalid') ||
        warning.toLowerCase().contains('try again')) {
      return Colors.red;
    } else if (warning.toLowerCase().contains('no internet')) {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }

  IconData _getWarningIcon(String warning) {
    if (warning.toLowerCase().contains('incomplete') || 
        warning.toLowerCase().contains('invalid')) {
      return Icons.error_outline;
    } else if (warning.toLowerCase().contains('no internet')) {
      return Icons.wifi_off;
    } else {
      return Icons.warning_amber;
    }
  }

  String _formatWarningMessage(String warning) {
    // Don't prefix with "Offline mode:" if it's an error message
    if (warning.toLowerCase().contains('failed') || 
        warning.toLowerCase().contains('error') ||
        warning.toLowerCase().contains('incomplete')) {
      return warning;
    } else if (warning.toLowerCase().contains('no internet')) {
      return 'Offline mode: Using color analysis (no internet connection)';
    } else {
      return 'Offline mode: $warning';
    }
  }
}
