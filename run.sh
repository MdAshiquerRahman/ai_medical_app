#!/bin/bash

# AI Medical Diagnosis App - Helper Commands
# This script contains useful commands for running and building the app

echo "🏥 AI Medical Diagnosis App - Command Helper"
echo "=============================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Flutter is installed"
flutter --version
echo ""

# Function to show menu
show_menu() {
    echo "Choose an option:"
    echo "1) List available devices"
    echo "2) Run on Linux Desktop"
    echo "3) Run on Android"
    echo "4) Run on iOS"
    echo "5) Build APK (Android Release)"
    echo "6) Build Linux Release"
    echo "7) Install dependencies (pub get)"
    echo "8) Clean and rebuild"
    echo "9) Run Flutter Doctor"
    echo "0) Exit"
    echo ""
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice [0-9]: " choice
    echo ""
    
    case $choice in
        1)
            echo "📱 Available devices:"
            flutter devices
            echo ""
            ;;
        2)
            echo "🖥️  Running on Linux Desktop..."
            flutter run -d linux
            ;;
        3)
            echo "📱 Running on Android..."
            flutter run -d android
            ;;
        4)
            echo "📱 Running on iOS..."
            flutter run -d ios
            ;;
        5)
            echo "📦 Building Android APK..."
            flutter build apk --release
            echo ""
            echo "✅ APK built at: build/app/outputs/flutter-apk/app-release.apk"
            ;;
        6)
            echo "🖥️  Building Linux Release..."
            flutter build linux --release
            echo ""
            echo "✅ Linux build at: build/linux/x64/release/bundle/"
            ;;
        7)
            echo "📦 Installing dependencies..."
            flutter pub get
            ;;
        8)
            echo "🧹 Cleaning project..."
            flutter clean
            echo "📦 Getting dependencies..."
            flutter pub get
            echo "✅ Project cleaned and dependencies installed"
            ;;
        9)
            echo "🔍 Running Flutter Doctor..."
            flutter doctor -v
            ;;
        0)
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please try again."
            echo ""
            ;;
    esac
done
