FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:10.1-jdk17

# Supprimer l'application par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier les classes compilées (vos servlets) depuis le build Maven
COPY --from=build /app/target/rdv-medical/WEB-INF/classes /usr/local/tomcat/webapps/ROOT/WEB-INF/classes
COPY --from=build /app/target/rdv-medical/WEB-INF/lib /usr/local/tomcat/webapps/ROOT/WEB-INF/lib

# Copier les fichiers web (JSP, HTML, etc.)
COPY src/main/webapp /usr/local/tomcat/webapps/ROOT

# Télécharger JSTL (au cas où)
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/lib
RUN curl -L -o /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/jakarta.servlet.jsp.jstl-api-3.0.0.jar \
    https://repo1.maven.org/maven2/jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/3.0.0/jakarta.servlet.jsp.jstl-api-3.0.0.jar
RUN curl -L -o /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/jakarta.servlet.jsp.jstl-3.0.1.jar \
    https://repo1.maven.org/maven2/org/glassfish/web/jakarta.servlet.jsp.jstl/3.0.1/jakarta.servlet.jsp.jstl-3.0.1.jar

EXPOSE 8080
CMD ["catalina.sh", "run"]
