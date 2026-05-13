FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package

FROM tomcat:10.1-jdk17-temurin-jammy
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/rdv-medical.war

# Extraire manuellement le WAR (important pour Render)
RUN cd /usr/local/tomcat/webapps && \
    mkdir -p rdv-medical && \
    cd rdv-medical && \
    jar -xf ../rdv-medical.war

# Supprimer le WAR après extraction (optionnel)
RUN rm /usr/local/tomcat/webapps/rdv-medical.war

# Exposer le port 8080
EXPOSE 8080

# Démarrer Tomcat
CMD ["catalina.sh", "run"]