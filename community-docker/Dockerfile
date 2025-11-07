# JRE17 사용 (Alpine은 Tomcat 10.1에서 공식 지원 안 함)
FROM tomcat:10.1-jre17

# 불필요한 파일 제거
RUN rm -rf /usr/local/tomcat/webapps/* \
    /usr/local/tomcat/webapps.dist \
    /usr/local/tomcat/temp/*

# MySQL Connector 복사
COPY webapp/WEB-INF/lib/mysql-connector-j-8.0.33.jar /usr/local/tomcat/lib/

# WAR 파일 복사
COPY build/community.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
