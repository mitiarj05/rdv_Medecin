FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:10.1-jdk17

# Installer curl et unzip
RUN apt-get update && apt-get install -y curl unzip

# Supprimer l'application par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Décompresser le WAR pour inspection et ajout des libs
RUN cd /usr/local/tomcat/webapps && \
    unzip -q ROOT.war -d ROOT && \
    rm ROOT.war

# Copier les classes compilées (au cas où)
COPY --from=build /app/target/rdv-medical/WEB-INF/classes /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

# Télécharger JSTL
RUN curl -L -o /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/jakarta.servlet.jsp.jstl-api-3.0.0.jar \
    https://repo1.maven.org/maven2/jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/3.0.0/jakarta.servlet.jsp.jstl-api-3.0.0.jar

RUN curl -L -o /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/jakarta.servlet.jsp.jstl-3.0.1.jar \
    https://repo1.maven.org/maven2/org/glassfish/web/jakarta.servlet.jsp.jstl/3.0.1/jakarta.servlet.jsp.jstl-3.0.1.jar

# Vérifier que les servlets sont présentes
RUN echo "=== Vérification des servlets ===" && \
    ls -la /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/com/rdv/servlet/ && \
    echo "================================"

EXPOSE 8080
CMD ["catalina.sh", "run"]
