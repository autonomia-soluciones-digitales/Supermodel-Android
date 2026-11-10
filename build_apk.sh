#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUPERMODEL_SRC="/tmp/Supermodel"
ANDROID_PROJECT="$SCRIPT_DIR"
echo "=== Supermodel Android Build Script ==="
echo "Supermodel source: $SUPERMODEL_SRC"
echo "Android project: $ANDROID_PROJECT"
if [ ! -d "$SUPERMODEL_SRC" ]; then
    echo "ERROR: Supermodel source not found at $SUPERMODEL_SRC"
    echo "Run: git clone https://github.com/trzy/Supermodel /tmp/Supermodel"
    exit 1
fi
echo "Copying Supermodel source..."
mkdir -p "$ANDROID_PROJECT/Supermodel"
rsync -a --exclude='.git' --exclude='obj*' --exclude='bin*' "$SUPERMODEL_SRC/" "$ANDROID_PROJECT/Supermodel/"
echo "Copying assets..."
mkdir -p "$ANDROID_PROJECT/app/src/main/assets/Config"
mkdir -p "$ANDROID_PROJECT/app/src/main/assets/Assets"
cp -r "$SUPERMODEL_SRC/Config/"* "$ANDROID_PROJECT/app/src/main/assets/Config/" 2>/dev/null || true
cp -r "$SUPERMODEL_SRC/Assets/"* "$ANDROID_PROJECT/app/src/main/assets/Assets/" 2>/dev/null || true
if [ ! -f "$ANDROID_PROJECT/app/src/main/assets/Config/Supermodel.ini" ]; then
    cat > "$ANDROID_PROJECT/app/src/main/assets/Config/Supermodel.ini" << 'INIEOF'
[Global]
New3DEngine = 1
WideScreen = 0
VSync = 0
MultiThreaded = 1
GPUMultiThreaded = 1
IdleSkip = 1
HighLevelGeometrizer = 1
PowerPCFrequency = 100
SoundVolume = 100
MusicVolume = 100
Balance = 0
NbSoundChannels = 4
Crosshairs = 0
CrosshairStyle = 0
Supersampling = 1
CRTcolors = 0
RefreshRate = 57.524
InputSystem = SDL
Outputs = None
PortIn = 8000
PortOut = 8000
AddressOut = 127.0.0.1
GameXMLFile = Games.xml
LogOutput = Supermodel.log
LogLevel = info
INIEOF
fi
if [ -f "$SUPERMODEL_SRC/Config/Games.xml" ]; then
    cp "$SUPERMODEL_SRC/Config/Games.xml" "$ANDROID_PROJECT/app/src/main/assets/Config/"
fi
chmod +x "$ANDROID_PROJECT/gradlew" 2>/dev/null || true
echo "Building APK..."
cd "$ANDROID_PROJECT"
if [ -f "./gradlew" ]; then
    ./gradlew assembleDebug
elif command -v gradle &> /dev/null; then
    gradle assembleDebug
else
    echo "ERROR: Neither gradlew nor gradle found. Please install Gradle."
    exit 1
fi
APK_PATH=$(find "$ANDROID_PROJECT" -name "*.apk" -path "*/build/outputs/*" | head -1)
if [ -n "$APK_PATH" ]; then
    echo ""
    echo "=== BUILD SUCCESSFUL ==="
    echo "APK location: $APK_PATH"
    echo "Size: $(du -h "$APK_PATH" | cut -f1)"
else
    echo "ERROR: APK not found after build"
    exit 1
fi
