#!/bin/bash
# EdgeSpeedColor 编译脚本
# 分别为 Edge 840 和 Edge 540 编译独立的 .prg 文件
SDK_DIR="$HOME/AppData/Roaming/Garmin/ConnectIQ/Sdks/connectiq-sdk-win-9.2.0-2026-06-09-92a1605b2"
JAR="$SDK_DIR/bin/monkeybrains.jar"
APIDB="$SDK_DIR/bin/api.db"
APIMIR="$SDK_DIR/bin/api.mir"

cd "$(dirname "$0")"

# 用 Windows 绝对路径避免 MSYS 路径转换
JAR_WIN=$(cygpath -w "$JAR")
APIDB_WIN=$(cygpath -w "$APIDB")
APIMIR_WIN=$(cygpath -w "$APIMIR")
KEY_WIN=$(cygpath -w "$PWD/developer_key.der")

mkdir -p bin

build_device() {
    local device="$1"
    local out="$2"
    local OUT_WIN=$(cygpath -w "$out")
    echo "=== 编译 $device -> $out ==="
    MSYS_NO_PATHCONV=1 java -Xms1g -Dfile.encoding=UTF-8 -jar "$JAR_WIN" \
      -a "$APIDB_WIN" -b "$APIMIR_WIN" \
      -o "$OUT_WIN" \
      -f monkey.jungle \
      -d "$device" \
      -y "$KEY_WIN" \
      -w
}

build_device edge840 "$PWD/bin/EdgeSpeedColor-edge840.prg"
build_device edge540 "$PWD/bin/EdgeSpeedColor-edge540.prg"

echo "=== 完成，产物： ==="
ls -la bin/*.prg
