#!/bin/bash

# TensorFlow Lite Setup Script for Linux
# This script downloads and installs the TensorFlow Lite C library for Linux

echo "🔧 Setting up TensorFlow Lite for Linux..."
echo ""

# Create blobs directory
mkdir -p /home/ashik/Documents/ai_medical_app/blobs

cd /tmp

# Try multiple sources
echo "📥 Attempting to download TensorFlow Lite library..."

# Source 1: GitHub Releases (TensorFlow 2.11.0)
if [ ! -f libtensorflowlite_c-linux.so ]; then
    echo "Trying TensorFlow 2.11.0 release..."
    wget -q --show-progress https://github.com/zhanghongtong/tflite-flutter-helper-android/raw/main/tensorflow-lite-2.11.0/jni/linux_x86_64/libtensorflowlite_jni.so -O libtensorflowlite_c-linux.so 2>/dev/null
fi

# Source 2: Build from source (if wget failed)
if [ ! -f libtensorflowlite_c-linux.so ] || [ ! -s libtensorflowlite_c-linux.so ]; then
    echo "❌ Download failed. Building from source..."
    echo ""
    echo "To build TensorFlow Lite from source, run:"
    echo ""
    echo "  git clone https://github.com/tensorflow/tensorflow.git"
    echo "  cd tensorflow"
    echo "  ./tensorflow/lite/tools/make/download_dependencies.sh"
    echo "  ./tensorflow/lite/tools/make/build_lib.sh"
    echo ""
    echo "Then copy the generated library:"
    echo "  cp tensorflow/lite/tools/make/gen/linux_x86_64/lib/libtensorflowlite_c.so \\"
    echo "     /home/ashik/Documents/ai_medical_app/blobs/libtensorflowlite_c-linux.so"
    echo ""
    echo "Or download pre-built library manually from:"
    echo "  https://www.tensorflow.org/lite/guide/build_cmake"
    exit 1
fi

# Copy to project
if [ -f libtensorflowlite_c-linux.so ] && [ -s libtensorflowlite_c-linux.so ]; then
    cp libtensorflowlite_c-linux.so /home/ashik/Documents/ai_medical_app/blobs/
    chmod +x /home/ashik/Documents/ai_medical_app/blobs/libtensorflowlite_c-linux.so
    echo "✅ TensorFlow Lite library installed successfully!"
    ls -lh /home/ashik/Documents/ai_medical_app/blobs/libtensorflowlite_c-linux.so
else
    echo "❌ Failed to download library"
    exit 1
fi

# Update CMakeLists.txt
CMAKEFILE="/home/ashik/Documents/ai_medical_app/linux/CMakeLists.txt"

if ! grep -q "libtensorflowlite_c-linux.so" "$CMAKEFILE"; then
    echo ""
    echo "📝 Updating linux/CMakeLists.txt..."
    cat >> "$CMAKEFILE" << 'EOF'

# TensorFlow Lite library installation
install(
  FILES ${PROJECT_BUILD_DIR}/../blobs/libtensorflowlite_c-linux.so
  DESTINATION ${INSTALL_BUNDLE_DATA_DIR}/../blobs/
)
EOF
    echo "✅ CMakeLists.txt updated!"
else
    echo "✅ CMakeLists.txt already configured"
fi

echo ""
echo "🎉 Setup complete! You can now run: flutter run -d linux"
