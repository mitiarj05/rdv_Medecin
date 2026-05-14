FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM jetty:11-jdk17

# Supprimer l'app par défaut
RUN rm -rf /var/lib/jetty/webapps/*

# Copier le WAR
COPY --from=build /app/target/rdv-medical.war /var/lib/jetty/webapps/ROOT.war

EXPOSE 8080
CMD ["jetty.sh", "run"]