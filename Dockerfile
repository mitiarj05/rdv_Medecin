FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:10.1-jdk17

# Supprimer les apps par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Créer le dossier d'explosion
RUN mkdir -p /usr/local/tomcat/webapps/ROOT

# Copier et décompresser le WAR directement
COPY --from=build /app/target/rdv-medical.war /tmp/app.war
RUN cd /usr/local/tomcat/webapps/ROOT && \
    unzip -q /tmp/app.war && \
    rm /tmp/app.war

# Vérifier les fichiers
RUN ls -la /usr/local/tomcat/webapps/ROOT/
RUN ls -la /usr/local/tomcat/webapps/ROOT/views/shared/ || echo "views/shared manquant"

EXPOSE 8080
CMD ["catalina.sh", "run"]