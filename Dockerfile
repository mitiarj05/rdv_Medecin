FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:10.1-jdk17

# Supprimer l'application par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier directement le WAR comme ROOT.war (Tomcat le déploiera automatiquement)
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Pas besoin d'extraire ! Tomcat le fait tout seul au démarrage

EXPOSE 8080
CMD ["catalina.sh", "run"]