FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:10.1-jdk17

# Copier le WAR
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Créer le fichier setenv.sh pour que Tomcat charge les variables d'env
RUN mkdir -p /usr/local/tomcat/bin
RUN echo '#!/bin/bash' > /usr/local/tomcat/bin/setenv.sh && \
    echo 'export DB_URL="'$DB_URL'"' >> /usr/local/tomcat/bin/setenv.sh && \
    echo 'export DB_USERNAME="'$DB_USERNAME'"' >> /usr/local/tomcat/bin/setenv.sh && \
    echo 'export DB_PASSWORD="'$DB_PASSWORD'"' >> /usr/local/tomcat/bin/setenv.sh && \
    echo 'export MAIL_USERNAME="'$MAIL_USERNAME'"' >> /usr/local/tomcat/bin/setenv.sh && \
    echo 'export MAIL_PASSWORD="'$MAIL_PASSWORD'"' >> /usr/local/tomcat/bin/setenv.sh && \
    chmod +x /usr/local/tomcat/bin/setenv.sh

# Afficher les variables pour déboguer (optionnel)
RUN cat /usr/local/tomcat/bin/setenv.sh

EXPOSE 8080
CMD ["catalina.sh", "run"]
