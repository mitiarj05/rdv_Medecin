FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package

FROM tomcat:10.1-jdk17-temurin-jammy
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Extraire manuellement le WAR
RUN cd /usr/local/tomcat/webapps && \
    mkdir ROOT && \
    cd ROOT && \
    jar -xf ../ROOT.war

# Vérifier que les fichiers sont bien présents
RUN ls -la /usr/local/tomcat/webapps/ROOT/WEB-INF/ && \
    ls -la /usr/local/tomcat/webapps/ROOT/views/shared/

EXPOSE 8080

CMD ["catalina.sh", "run"]