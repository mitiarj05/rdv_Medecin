FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package

FROM tomcat:10.1-jdk17-temurin-jammy
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Extraire manuellement le WAR et vérifier les fichiers (TOUT DANS UNE SEULE COMMANDE)
RUN cd /usr/local/tomcat/webapps && \
    mkdir -p ROOT && \
    cd ROOT && \
    jar -xf ../ROOT.war && \
    echo "=== Contenu du dossier ROOT ===" && \
    ls -la && \
    echo "=== Contenu du dossier WEB-INF ===" && \
    ls -la WEB-INF/ && \
    echo "=== Contenu du dossier views/shared ===" && \
    ls -la views/shared/ || echo "views/shared non trouvé !"

EXPOSE 8080

CMD ["catalina.sh", "run"]