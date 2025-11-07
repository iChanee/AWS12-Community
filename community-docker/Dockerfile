FROM tomcat:10.1-jdk17

# 기본 앱 제거
RUN rm -rf /usr/local/tomcat/webapps/*

# MySQL Connector를 Tomcat lib로 복사 (중요!)
COPY webapp/WEB-INF/lib/mysql-connector-j-8.0.33.jar /usr/local/tomcat/lib/

# WAR 파일 복사
COPY build/community.war /usr/local/tomcat/webapps/ROOT.war

# 포트 노출
EXPOSE 8080

CMD ["catalina.sh", "run"]
