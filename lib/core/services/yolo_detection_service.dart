import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// YOLO-based object detection service for offline material detection
class YoloDetectionService {
  static final YoloDetectionService _instance = YoloDetectionService._internal();
  factory YoloDetectionService() => _instance;
  YoloDetectionService._internal();
  
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isInitialized = false;
  
  // Model configuration
  static const int inputSize = 640; // YOLOv8 default input size
  static const double confidenceThreshold = 0.5;
  static const double iouThreshold = 0.45;
  
  // Material labels for campus recycling context
  static const List<String> materialLabels = [
    'electronics',
    'circuit_board',
    'pcb',
    'motor',
    'metal',
    'aluminum',
    'steel',
    'copper',
    'wood',
    'plastic',
    'acrylic',
    'glass',
    'wire',
    'cable',
    'battery',
    'screw',
    'bolt',
    'tool',
    'capacitor',
    'resistor',
    'ic_chip',
    'connector',
    'transformer',
    'gear',
    'bearing',
    'shaft',
    'bracket',
    'unknown'
  ];

  bool get isInitialized => _isInitialized;

  /// Initialize the YOLO model
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Try to load the model from assets
      // Note: You need to add a YOLO .tflite model to assets/models/
      final modelPath = await _getModelPath();
      
      if (modelPath != null) {
        print('Found YOLO model at: $modelPath');
        try {
          _interpreter = await Interpreter.fromAsset(modelPath);
          _labels = materialLabels;
          _isInitialized = true;
          print('YOLO model loaded successfully');
          print('YOLO model input shape: ${_interpreter!.getInputTensor(0).shape}');
          print('YOLO model output shape: ${_interpreter!.getOutputTensor(0).shape}');
          return true;
        } catch (e) {
          print('YOLO model file exists but failed to load: $e');
          print('This usually means the .tflite file is corrupted or not a valid YOLOv8 model');
          print('Please download a valid YOLOv8 TFLite model from: https://github.com/ultralytics/ultralytics');
          _isInitialized = false;
          return false;
        }
      } else {
        print('YOLO model not found in assets, using fallback detection');
        _isInitialized = false;
        return false;
      }
    } catch (e) {
      print('Failed to initialize YOLO: $e');
      _isInitialized = false;
      return false;
    }
  }

  Future<String?> _getModelPath() async {
    // Check if model exists in assets
    try {
      const possibleModels = [
        'assets/models/yolov8n.tflite',
        'assets/models/yolo_materials.tflite',
        'assets/models/material_detector.tflite',
      ];
      
      for (final model in possibleModels) {
        try {
          await rootBundle.load(model);
          return model;
        } catch (_) {
          continue;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Run detection on an image file
  Future<YoloDetectionResult> detectFromFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return detectFromBytes(bytes);
    } catch (e) {
      return YoloDetectionResult.error('Failed to read image: $e');
    }
  }

  /// Run detection on image bytes
  Future<YoloDetectionResult> detectFromBytes(Uint8List imageBytes) async {
    // If YOLO model is not loaded, use heuristic detection
    if (!_isInitialized || _interpreter == null) {
      return _heuristicDetection(imageBytes);
    }
    
    try {
      // Decode and preprocess image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return YoloDetectionResult.error('Failed to decode image');
      }
      
      // Resize to model input size
      final resized = img.copyResize(image, width: inputSize, height: inputSize);
      
      // Convert to input tensor format
      final input = _imageToInput(resized);
      
      // Prepare output tensor
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final output = List.generate(
        outputShape[0],
        (_) => List.generate(
          outputShape[1],
          (_) => List.filled(outputShape[2], 0.0),
        ),
      );
      
      // Run inference
      _interpreter!.run(input, output);
      
      // Process detections
      final detections = _processDetections(output, image.width, image.height);
      
      // Analyze image quality
      final quality = _analyzeImageQuality(image);
      
      return YoloDetectionResult(
        detections: detections,
        imageQuality: quality,
        visualHeuristics: _detectVisualHeuristics(image),
        isModelBased: true,
      );
    } catch (e) {
      print('YOLO inference error: $e');
      return _heuristicDetection(imageBytes);
    }
  }

  /// Heuristic-based detection when YOLO model is not available
  Future<YoloDetectionResult> _heuristicDetection(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return YoloDetectionResult.error('Failed to decode image');
      }
      
      final detections = <Detection>[];
      final heuristics = _detectVisualHeuristics(image);
      final quality = _analyzeImageQuality(image);
      
      final colorAnalysis = _analyzeColors(image);
      
      // Detect green PCBs
      if (colorAnalysis['green']! > 0.1) {
        detections.add(Detection(
          label: 'pcb',
          confidence: 0.6 + (colorAnalysis['green']! * 0.3),
          boundingBox: BoundingBox(0, 0, image.width.toDouble(), image.height.toDouble()),
          estimatedCount: _estimateCount(colorAnalysis['green']!),
        ));
      }
      
      // Detect blue PCBs (common in electronics)
      if (colorAnalysis['blue']! > 0.15) {
        detections.add(Detection(
          label: 'circuit_board',
          confidence: 0.55 + (colorAnalysis['blue']! * 0.3),
          boundingBox: BoundingBox(0, 0, image.width.toDouble(), image.height.toDouble()),
          estimatedCount: _estimateCount(colorAnalysis['blue']!),
        ));
      }
      
      // Detect cables/wires (red, orange, yellow colors often indicate wires)
      final wireColors = (colorAnalysis['red']! + colorAnalysis['orange']! + colorAnalysis['yellow']!) / 3;
      if (wireColors > 0.05) {
        detections.add(Detection(
          label: 'wire',
          confidence: 0.5 + (wireColors * 0.4),
          boundingBox: BoundingBox(0, 0, image.width.toDouble(), image.height.toDouble()),
          estimatedCount: _estimateCount(wireColors * 2),
        ));
      }
      
      // Detect metal (gray/silver colors)
      if (colorAnalysis['gray']! > 0.1) {
        detections.add(Detection(
          label: 'metal',
          confidence: 0.5 + (colorAnalysis['gray']! * 0.3),
          boundingBox: BoundingBox(0, 0, image.width.toDouble(), image.height.toDouble()),
          estimatedCount: _estimateCount(colorAnalysis['gray']!),
        ));
      }
      
      // Detect copper (brownish-orange)
      if (colorAnalysis['copper']! > 0.05) {
        detections.add(Detection(
          label: 'copper',
          confidence: 0.55 + (colorAnalysis['copper']! * 0.3),
          boundingBox: BoundingBox(0, 0, image.width.toDouble(), image.height.toDouble()),
          estimatedCount: _estimateCount(colorAnalysis['copper']!),
        ));
      }
      
      // If image appears to be electronics
      if (colorAnalysis['green']! > 0.05 || colorAnalysis['blue']! > 0.1) {
        detections.add(Detection(
          label: 'electronics',
          confidence: 0.7,
          boundingBox: BoundingBox(0, 0, image.width.toDouble(), image.height.toDouble()),
          estimatedCount: detections.length + 1,
        ));
      }
      
      return YoloDetectionResult(
        detections: detections,
        imageQuality: quality,
        visualHeuristics: heuristics,
        isModelBased: false,
      );
    } catch (e) {
      return YoloDetectionResult.error('Heuristic detection failed: $e');
    }
  }

  int _estimateCount(double ratio) {
    if (ratio < 0.1) return 1;
    if (ratio < 0.2) return 3;
    if (ratio < 0.3) return 5;
    if (ratio < 0.5) return 8;
    return 10;
  }

  Map<String, double> _analyzeColors(img.Image image) {
    int greenCount = 0;
    int blueCount = 0;
    int redCount = 0;
    int orangeCount = 0;
    int yellowCount = 0;
    int grayCount = 0;
    int copperCount = 0;
    int brownCount = 0;
    int totalPixels = 0;
    
    // Sample pixels for efficiency
    final stepX = (image.width / 100).ceil();
    final stepY = (image.height / 100).ceil();
    
    for (int y = 0; y < image.height; y += stepY) {
      for (int x = 0; x < image.width; x += stepX) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        totalPixels++;
        
        // PCB Green (bright green)
        if (g > 100 && g > r * 1.2 && g > b * 1.2) {
          greenCount++;
        }
        // PCB Blue
        else if (b > 100 && b > r * 1.3 && b > g * 0.8) {
          blueCount++;
        }
        // Wire Red
        else if (r > 150 && r > g * 1.5 && r > b * 1.5) {
          redCount++;
        }
        // Wire Orange
        else if (r > 180 && g > 80 && g < 150 && b < 80) {
          orangeCount++;
        }
        // Wire Yellow
        else if (r > 180 && g > 180 && b < 100) {
          yellowCount++;
        }
        // Metal Gray
        else if ((r - g).abs() < 30 && (g - b).abs() < 30 && r > 80 && r < 200) {
          grayCount++;
        }
        // Copper (brownish-orange)
        else if (r > 140 && g > 80 && g < 130 && b < 80) {
          copperCount++;
        }
        // Brown (burnt marks)
        else if (r > 60 && r < 120 && g > 40 && g < 90 && b < 60) {
          brownCount++;
        }
      }
    }
    
    return {
      'green': greenCount / totalPixels,
      'blue': blueCount / totalPixels,
      'red': redCount / totalPixels,
      'orange': orangeCount / totalPixels,
      'yellow': yellowCount / totalPixels,
      'gray': grayCount / totalPixels,
      'copper': copperCount / totalPixels,
      'brown': brownCount / totalPixels,
    };
  }

  VisualHeuristics _detectVisualHeuristics(img.Image image) {
    final colors = _analyzeColors(image);
    
    // Burn marks detection (dark brown/black spots)
    final burnMarksDetected = colors['brown']! > 0.03;
    
    // Rust detection (reddish-brown)
    final rustDetected = colors['copper']! > 0.1 && colors['brown']! > 0.05;
    
    // Cracks detection would require edge detection - simplified
    final cracksDetected = false;
    
    // Sharp edges - can't reliably detect without ML
    final sharpEdgesDetected = false;
    
    return VisualHeuristics(
      burnMarksDetected: burnMarksDetected,
      rustDetected: rustDetected,
      cracksDetected: cracksDetected,
      sharpEdgesDetected: sharpEdgesDetected,
      oxidationDetected: colors['copper']! > 0.08,
      discolorationDetected: colors['brown']! > 0.05,
    );
  }

  ImageQuality _analyzeImageQuality(img.Image image) {
    // Calculate blur score using Laplacian variance approximation
    double blurScore = _calculateBlurScore(image);
    
    // Analyze lighting
    String lighting = _analyzeLighting(image);
    
    // Estimate occlusion (simplified - based on color uniformity)
    String occlusion = _estimateOcclusion(image);
    
    return ImageQuality(
      blurScore: blurScore,
      lighting: lighting,
      occlusionLevel: occlusion,
      resolution: '${image.width}x${image.height}',
    );
  }

  double _calculateBlurScore(img.Image image) {
    // Simplified blur detection using edge intensity
    double totalEdge = 0;
    int count = 0;
    
    final stepX = (image.width / 50).ceil();
    final stepY = (image.height / 50).ceil();
    
    for (int y = 1; y < image.height - 1; y += stepY) {
      for (int x = 1; x < image.width - 1; x += stepX) {
        final center = image.getPixel(x, y);
        final right = image.getPixel(x + 1, y);
        final bottom = image.getPixel(x, y + 1);
        
        final dx = (center.r - right.r).abs() + (center.g - right.g).abs() + (center.b - right.b).abs();
        final dy = (center.r - bottom.r).abs() + (center.g - bottom.g).abs() + (center.b - bottom.b).abs();
        
        totalEdge += (dx + dy) / 6;
        count++;
      }
    }
    
    // Higher edge intensity = less blur
    final avgEdge = totalEdge / count;
    // Return blur score (0 = no blur, 1 = very blurry)
    return (1 - (avgEdge / 100)).clamp(0.0, 1.0);
  }

  String _analyzeLighting(img.Image image) {
    double totalBrightness = 0;
    int count = 0;
    
    final stepX = (image.width / 50).ceil();
    final stepY = (image.height / 50).ceil();
    
    for (int y = 0; y < image.height; y += stepY) {
      for (int x = 0; x < image.width; x += stepX) {
        final pixel = image.getPixel(x, y);
        totalBrightness += (pixel.r + pixel.g + pixel.b) / 3;
        count++;
      }
    }
    
    final avgBrightness = totalBrightness / count;
    
    if (avgBrightness < 50) return 'poor';
    if (avgBrightness < 100) return 'moderate';
    if (avgBrightness < 180) return 'good';
    return 'overexposed';
  }

  String _estimateOcclusion(img.Image image) {
    // Simplified: check color diversity as proxy for multiple overlapping objects
    final colors = _analyzeColors(image);
    final colorCount = colors.values.where((v) => v > 0.05).length;
    
    if (colorCount > 5) return 'high';
    if (colorCount > 3) return 'medium';
    return 'low';
  }

  List<List<List<double>>> _imageToInput(img.Image image) {
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ).expand((e) => e).toList(),
      ),
    );
    return [input[0]];
  }

  List<Detection> _processDetections(List<dynamic> output, int origWidth, int origHeight) {
    // Process YOLO output format - implementation depends on specific model
    // This is a placeholder for actual YOLO output processing
    final detections = <Detection>[];
    return detections;
  }

  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}

// Data classes
class YoloDetectionResult {
  final List<Detection> detections;
  final ImageQuality? imageQuality;
  final VisualHeuristics? visualHeuristics;
  final bool isModelBased;
  final String? error;

  YoloDetectionResult({
    required this.detections,
    this.imageQuality,
    this.visualHeuristics,
    this.isModelBased = false,
  }) : error = null;

  YoloDetectionResult.error(this.error)
      : detections = [],
        imageQuality = null,
        visualHeuristics = null,
        isModelBased = false;

  bool get hasError => error != null;
  bool get hasDetections => detections.isNotEmpty;

  Map<String, dynamic> toPreprocessedJson() {
    return {
      'input_type': 'preprocessed',
      'detections': detections.map((d) => d.toJson()).toList(),
      'image_quality': imageQuality?.toJson() ?? {},
      'visual_heuristics': visualHeuristics?.toJson() ?? {},
      'is_model_based': isModelBased,
    };
  }
}

class Detection {
  final String label;
  final double confidence;
  final BoundingBox boundingBox;
  final int estimatedCount;

  Detection({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    this.estimatedCount = 1,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'confidence': confidence,
    'count': estimatedCount,
    'bbox': [boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height],
  };
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox(this.x, this.y, this.width, this.height);
}

class ImageQuality {
  final double blurScore;
  final String lighting;
  final String occlusionLevel;
  final String resolution;

  ImageQuality({
    required this.blurScore,
    required this.lighting,
    required this.occlusionLevel,
    required this.resolution,
  });

  Map<String, dynamic> toJson() => {
    'blur_score': blurScore,
    'lighting': lighting,
    'occlusion_level': occlusionLevel,
    'resolution': resolution,
  };
}

class VisualHeuristics {
  final bool burnMarksDetected;
  final bool rustDetected;
  final bool cracksDetected;
  final bool sharpEdgesDetected;
  final bool oxidationDetected;
  final bool discolorationDetected;

  VisualHeuristics({
    required this.burnMarksDetected,
    required this.rustDetected,
    required this.cracksDetected,
    required this.sharpEdgesDetected,
    this.oxidationDetected = false,
    this.discolorationDetected = false,
  });

  Map<String, dynamic> toJson() => {
    'burn_marks_detected': burnMarksDetected,
    'rust_detected': rustDetected,
    'cracks_detected': cracksDetected,
    'sharp_edges_detected': sharpEdgesDetected,
    'oxidation_detected': oxidationDetected,
    'discoloration_detected': discolorationDetected,
  };
}
