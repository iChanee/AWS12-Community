#!/bin/bash

echo "=== Docker 기반 빌드 시작 ==="

PROJECT_DIR=$(pwd)
SRC_DIR="$PROJECT_DIR/src"
WEBAPP_DIR="$PROJECT_DIR/webapp"
BUILD_DIR="$PROJECT_DIR/build"
CLASSES_DIR="$WEBAPP_DIR/WEB-INF/classes"
BASE_LIB_PATH="$WEBAPP_DIR/WEB-INF/lib" # 라이브러리 경로 변수 추가

# 1. 정리
echo "1. 이전 빌드 정리..."
rm -rf "$BUILD_DIR"
rm -rf "$CLASSES_DIR"
# 라이브러리 디렉토리도 정리하고 다시 생성합니다.
rm -rf "$BASE_LIB_PATH" 
mkdir -p "$BUILD_DIR"
mkdir -p "$CLASSES_DIR"
mkdir -p "$BASE_LIB_PATH"

# 2. 컴파일을 위한 Jakarta EE API JAR 다운로드
echo "2. Java 컴파일을 위해 필요한 라이브러리 다운로드 (Umbrella API 사용)..."

# PostCreateServlet.java 에서 사용하는 jakarta.* 패키지(Servlet, Naming, Resource 등)를
# Jakarta EE 10 플랫폼의 통합 API JAR 파일 하나로 해결합니다.
EE_VERSION="10.0.0"
EE_JAR="jakarta.jakartaee-api-${EE_VERSION}.jar"
echo " -> Jakarta EE Platform API ($EE_VERSION) 다운로드 중..."
# -f 옵션: HTTP 에러 발생 시 curl이 조용히 실패하도록 하여, 깨진 파일이 저장되는 것을 방지합니다.
curl -f -o "$BASE_LIB_PATH/$EE_JAR" \
     https://repo1.maven.org/maven2/jakarta/platform/jakarta.jakartaee-api/$EE_VERSION/$EE_JAR
if [ $? -ne 0 ]; then 
    echo "❌ 다운로드 실패: $EE_JAR. 네트워크 연결 또는 URL을 확인하세요."
    exit 1
fi

# 3. Java 컴파일 실행
echo "3. Java 컴파일 실행..."

# 클래스패스(-cp)에 와일드카드 대신 다운로드된 JAR 파일 전체 경로를 명시적으로 지정하여
# 클래스패스 인식 오류를 방지합니다.
javac -cp "$BASE_LIB_PATH/$EE_JAR" \
      -d "$CLASSES_DIR" \
      -encoding UTF-8 \
      $(find "$SRC_DIR" -name "*.java")

if [ $? -ne 0 ]; then
    echo "❌ 컴파일 실패!"
    exit 1
fi

# 4. WAR 생성
echo "4. WAR 파일 생성..."
cd "$WEBAPP_DIR"
# WAR 파일에는 WEB-INF/lib 내부의 내용만 포함됩니다.
jar -cvf "$BUILD_DIR/community.war" .
cd "$PROJECT_DIR"

echo "✅ 빌드 완료: $BUILD_DIR/community.war"