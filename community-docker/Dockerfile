# ========== Stage 1: Tomcat 다운로드 & 정리 ==========
FROM alpine:3.19 AS downloader

ENV TOMCAT_VERSION=10.1.30

# 버전 패치마다 링크만 수정
RUN apk add --no-cache curl tar && \
    mkdir -p /opt/tomcat && \
    curl -fSL "https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
      -o /tmp/tomcat.tar.gz && \
    tar -xzf /tmp/tomcat.tar.gz -C /opt/tomcat --strip-components=1 && \
    rm -rf /tmp/tomcat.tar.gz \
           /opt/tomcat/webapps/* \
           /opt/tomcat/webapps.dist \
           /opt/tomcat/temp/* \
           /opt/tomcat/work/* \
           /opt/tomcat/logs/* \
           /opt/tomcat/bin/*.bat \
           /opt/tomcat/BUILDING.txt \
           /opt/tomcat/CONTRIBUTING.md \
           /opt/tomcat/README.md \
           /opt/tomcat/RELEASE-NOTES \
           /opt/tomcat/RUNNING.txt

COPY build/community.war /opt/tomcat/webapps/ROOT.war

COPY webapp/WEB-INF/lib/mysql-connector-j-8.0.33.jar /opt/tomcat/lib/

# ========== Stage 2: 커스텀 JRE 생성 ==========
FROM amazoncorretto:17-alpine AS jre-builder

RUN apk add --no-cache binutils

RUN $JAVA_HOME/bin/jlink \
    --add-modules java.base,java.logging,java.naming,java.management,java.rmi,java.sql,java.xml,jdk.unsupported,java.desktop,java.security.jgss,java.instrument \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /opt/jre-minimal

# ========== Stage 3: 최종 런타임 ==========
FROM alpine:3.19

ENV JAVA_HOME=/opt/jre-minimal
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$JAVA_HOME/bin:$CATALINA_HOME/bin:$PATH

# Bash만 설치
RUN apk add --no-cache bash

# 커스텀 JRE 복사
COPY --from=jre-builder /opt/jre-minimal $JAVA_HOME

# Tomcat 복사
COPY --from=downloader /opt/tomcat $CATALINA_HOME

EXPOSE 8080
CMD ["catalina.sh", "run"]


# ===============================================================================================================
# ===============================================================================================================
# ===============================================================================================================
# ===============================================================================================================



# # Stage 1: 베이스 Tomcat 이미지에서 필요한 컴포넌트 준비
# # (Tomcat 엔진, conf, lib, bin 디렉토리를 복사하기 위해 사용)
# FROM tomcat:10.1-jre17 AS tomcat-base

# # Stage 2: 런타임 이미지 (가장 가벼운 Alpine JRE 사용)
# FROM eclipse-temurin:17-jre-alpine

# # **Bash 설치**: Alpine 환경에서 catalina.sh 실행을 위해 bash를 추가하고 캐시 정리
# RUN apk add --no-cache bash

# # Tomcat 설치 경로 및 환경 변수 설정
# ENV CATALINA_HOME /usr/local/tomcat
# ENV PATH $CATALINA_HOME/bin:$PATH
# WORKDIR $CATALINA_HOME

# # **추가**: Tomcat 임시 디렉토리 변수 명시
# ENV CATALINA_TMPDIR $CATALINA_HOME/temp

# # 1. Tomcat 실행을 위한 non-root 사용자 생성 (보안 강화)
# RUN addgroup -g 1000 tomcat \
#     && adduser -u 1000 -G tomcat -D -h $CATALINA_HOME tomcat

# # 2. Tomcat 핵심 디렉토리 복사 및 권한 설정
# # --chown=tomcat:tomcat 옵션을 사용하여 복사되는 파일의 소유자를 non-root 사용자로 즉시 변경합니다.
# COPY --from=tomcat-base --chown=tomcat:tomcat /usr/local/tomcat/conf $CATALINA_HOME/conf
# COPY --from=tomcat-base --chown=tomcat:tomcat /usr/local/tomcat/lib $CATALINA_HOME/lib
# COPY --from=tomcat-base --chown=tomcat:tomcat /usr/local/tomcat/bin $CATALINA_HOME/bin
# COPY --from=tomcat-base --chown=tomcat:tomcat /usr/local/tomcat/webapps.dist $CATALINA_HOME/webapps.dist

# # 3. 필수 디렉토리 생성, 권한 설정 및 불필요한 기본 웹앱 제거
# # logs와 temp 디렉토리를 포함한 모든 필수 디렉토리에 tomcat 권한을 재귀적으로 부여합니다.
# RUN mkdir -p $CATALINA_HOME/webapps $CATALINA_HOME/temp $CATALINA_HOME/logs \
#     && chown -R tomcat:tomcat $CATALINA_HOME \
#     && rm -rf $CATALINA_HOME/webapps/* \
#     $CATALINA_HOME/webapps.dist/examples \
#     $CATALINA_HOME/webapps.dist/docs \
#     # bin 디렉토리 내 스크립트 실행 권한 부여
#     && chmod +x $CATALINA_HOME/bin/*.sh

# # 4. MySQL Connector 및 WAR 파일 복사 (권한 설정 포함)
# COPY --chown=tomcat:tomcat webapp/WEB-INF/lib/mysql-connector-j-8.0.33.jar $CATALINA_HOME/lib/
# COPY --chown=tomcat:tomcat build/community.war $CATALINA_HOME/webapps/ROOT.war

# # 5. 보안 강화를 위해 tomcat 사용자로 전환
# USER tomcat

# EXPOSE 8080

# # 6. 컨테이너 실행 명령 (Tomcat 실행)
# # CMD를 쉘 명령으로 변경하여 PATH와 환경 변수 해석을 보장합니다.
# CMD ["sh", "-c", "catalina.sh run"]