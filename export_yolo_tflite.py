"""
Export YOLOv8 model to TFLite format for Flutter app
"""
from ultralytics import YOLO
import os
import shutil

# Load a pretrained YOLOv8n model (smallest, fastest)
print("Loading YOLOv8n model...")
model = YOLO("yolov8n.pt")

# Export to TFLite format
print("Exporting to TFLite format...")
print("This may take a few minutes...")
path = model.export(format="tflite", imgsz=640)

print(f"\nModel exported to: {path}")

# Copy to assets/models directory
assets_models = os.path.join(os.path.dirname(__file__), "assets", "models")
destination = os.path.join(assets_models, "yolov8n.tflite")

if os.path.exists(path):
    print(f"Copying to: {destination}")
    shutil.copy(path, destination)
    print("✓ Successfully exported and copied YOLOv8n TFLite model!")
    print(f"File size: {os.path.getsize(destination) / (1024*1024):.2f} MB")
else:
    print(f"ERROR: Export failed, file not found at {path}")
