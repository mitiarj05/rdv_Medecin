FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:10.1-jdk17

# Supprimer l'application par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Extraire correctement le WAR dans ROOT/
RUN cd /usr/local/tomcat/webapps && \
    mkdir -p ROOT && \
    cd ROOT && \
    unzip -q ../ROOT.war && \
    cd .. && \
    rm ROOT.war && \
    chmod -R 755 ROOT

# Vérification que les JSP sont bien présentes
RUN echo "=== Vérification des fichiers JSP ===" && \
    ls -la /usr/local/tomcat/webapps/ROOT/ && \
    echo "=== Vérification views/shared ===" && \
    ls -la /usr/local/tomcat/webapps/ROOT/views/shared/ && \
    echo "=== Vérification WEB-INF ===" && \
    ls -la /usr/local/tomcat/webapps/ROOT/WEB-INF/

EXPOSE 8080
CMD ["catalina.sh", "run"]