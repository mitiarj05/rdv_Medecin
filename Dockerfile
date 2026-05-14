FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# 🔥 AFFICHER LE CONTENU COMPLET DU WAR
RUN echo "=== CONTENU COMPLET DU WAR ==="
RUN jar tf /app/target/rdv-medical.war
RUN echo "=== FIN DU CONTENU ==="

FROM tomcat:10.1-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# 🔥 VÉRIFIER LE CONTENU APRÈS DÉCOMPRESSION
RUN cd /usr/local/tomcat/webapps && \
    unzip -q ROOT.war -d ROOT && \
    echo "=== CONTENU APRÈS DÉCOMPRESSION ===" && \
    ls -la ROOT/ && \
    ls -la ROOT/views/ && \
    ls -la ROOT/views/shared/

EXPOSE 8080
CMD ["catalina.sh", "run"]