FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn clean package -DskipTests -q

FROM tomcat:10.1-jdk17

# Supprimer les apps par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR complet (contient toutes les dépendances)
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Copier le script d'initialisation DB
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]