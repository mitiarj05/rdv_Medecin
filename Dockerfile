FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:10.1-jdk17

# Installer unzip et curl
RUN apt-get update && apt-get install -y unzip curl

# Supprimer l'application par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Décompresser le WAR (cela extrait TOUTES les classes et JSP)
RUN cd /usr/local/tomcat/webapps && \
    unzip -q ROOT.war -d ROOT && \
    rm ROOT.war

# Vérifier que les servlets sont bien présentes
RUN echo "=== Vérification des servlets ===" && \
    ls -la /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/com/rdv/servlet/ && \
    echo "=== Fin vérification ==="

EXPOSE 8080
CMD ["catalina.sh", "run"]
