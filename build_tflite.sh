#!/bin/bash

echo "🔧 Building TensorFlow Lite for Linux..."
echo "This will take 20-40 minutes."
echo ""

# Install dependencies
echo "📦 Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential cmake git python3 python3-pip

# Clone TensorFlow
echo "📥 Cloning TensorFlow..."
cd /tmp
rm -rf tensorflow
git clone --depth 1 --branch v2.13.0 https://github.com/tensorflow/tensorflow.git
cd tensorflow

# Build using CMake
echo "🔨 Building TensorFlow Lite (this takes time)..."
mkdir -p build && cd build
cmake ../tensorflow/lite/c
cmake --build . -j$(nproc)

# Check if build succeeded
if [ -f "libtensorflowlite_c.so" ]; then
    echo "✅ Build successful!"
    
    # Create directory and copy
    mkdir -p /home/ashik/Documents/ai_medical_app/blobs
    cp libtensorflowlite_c.so /home/ashik/Documents/ai_medical_app/blobs/libtensorflowlite_c-linux.so
    chmod +x /home/ashik/Documents/ai_medical_app/blobs/libtensorflowlite_c-linux.so
    
    echo "✅ Library installed to: /home/ashik/Documents/ai_medical_app/blobs/"
    ls -lh /home/ashik/Documents/ai_medical_app/blobs/libtensorflowlite_c-linux.so
    
    echo ""
    echo "🎉 Setup complete! Now run:"
    echo "cd /home/ashik/Documents/ai_medical_app"
    echo "flutter clean"
    echo "flutter run -d linux"
else
    echo "❌ Build failed. Please check the output above for errors."
    exit 1
fi
