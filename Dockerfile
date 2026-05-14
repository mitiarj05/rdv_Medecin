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

# Décompresser le WAR pour ajouter JSTL
RUN cd /usr/local/tomcat/webapps && \
    unzip -q ROOT.war -d ROOT && \
    rm ROOT.war

# Télécharger JSTL directement dans WEB-INF/lib
RUN curl -L -o /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/jakarta.servlet.jsp.jstl-api-3.0.0.jar \
    https://repo1.maven.org/maven2/jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/3.0.0/jakarta.servlet.jsp.jstl-api-3.0.0.jar

RUN curl -L -o /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/jakarta.servlet.jsp.jstl-3.0.1.jar \
    https://repo1.maven.org/maven2/org/glassfish/web/jakarta.servlet.jsp.jstl/3.0.1/jakarta.servlet.jsp.jstl-3.0.1.jar

EXPOSE 8080
CMD ["catalina.sh", "run"]
