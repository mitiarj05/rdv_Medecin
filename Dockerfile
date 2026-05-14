FROM tomcat:10.1-jdk17

# Supprimer l'application par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier directement les fichiers web
COPY src/main/webapp /usr/local/tomcat/webapps/ROOT

# 🔥 TÉLÉCHARGER JSTL DIRECTEMENT DANS TOMCAT
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/lib
RUN curl -L -o /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/jakarta.servlet.jsp.jstl-api-3.0.0.jar \
    https://repo1.maven.org/maven2/jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/3.0.0/jakarta.servlet.jsp.jstl-api-3.0.0.jar
RUN curl -L -o /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/jakarta.servlet.jsp.jstl-3.0.1.jar \
    https://repo1.maven.org/maven2/org/glassfish/web/jakarta.servlet.jsp.jstl/3.0.1/jakarta.servlet.jsp.jstl-3.0.1.jar

EXPOSE 8080
CMD ["catalina.sh", "run"]
