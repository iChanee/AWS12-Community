#!/bin/bash

echo "=== Docker 기반 빌드 시작 ==="

PROJECT_DIR=$(pwd)
SRC_DIR="$PROJECT_DIR/src"
WEBAPP_DIR="$PROJECT_DIR/webapp"
BUILD_DIR="$PROJECT_DIR/build"
CLASSES_DIR="$WEBAPP_DIR/WEB-INF/classes"

# 1. 정리
echo "1. 이전 빌드 정리..."
rm -rf "$BUILD_DIR"
rm -rf "$CLASSES_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$CLASSES_DIR"

# 2. Jakarta Servlet API 다운로드 (없으면)
echo "2. Jakarta Servlet API 확인..."
if [ ! -f "$WEBAPP_DIR/WEB-INF/lib/jakarta.servlet-api-6.0.0.jar" ]; then
    echo "Jakarta Servlet API 다운로드 중..."
    curl -o "$WEBAPP_DIR/WEB-INF/lib/jakarta.servlet-api-6.0.0.jar" \
         https://repo1.maven.org/maven2/jakarta/servlet/jakarta.servlet-api/6.0.0/jakarta.servlet-api-6.0.0.jar
fi

# 3. 컴파일
echo "3. Java 컴파일..."
javac -cp "$WEBAPP_DIR/WEB-INF/lib/*" \
      -d "$CLASSES_DIR" \
      -encoding UTF-8 \
      $(find "$SRC_DIR" -name "*.java")

if [ $? -ne 0 ]; then
    echo "❌ 컴파일 실패!"
    exit 1
fi

echo "✅ 컴파일 완료"

# 4. WAR 생성
echo "4. WAR 파일 생성..."
cd "$WEBAPP_DIR"
jar -cvf "$BUILD_DIR/community.war" . > /dev/null 2>&1
cd "$PROJECT_DIR"

WAR_SIZE=$(du -h "$BUILD_DIR/community.war" | cut -f1)
echo "✅ 빌드 완료: $BUILD_DIR/community.war ($WAR_SIZE)"