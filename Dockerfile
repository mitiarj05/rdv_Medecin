FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# 🔥 AJOUTEZ CETTE LIGNE POUR VOIR LE CONTENU DU WAR
RUN jar tf /app/target/rdv-medical.war | grep -E "\.jsp|views" | head -20

FROM tomcat:10.1-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]