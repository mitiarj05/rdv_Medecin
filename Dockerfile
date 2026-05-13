# Dockerfile simplifié - utilise le WAR à la racine
FROM tomcat:10.1-jdk17-temurin-jammy

# Supprimer les applications par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR depuis la racine du projet (pas depuis target/)
COPY rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Exposer le port
EXPOSE 8080

# Démarrer Tomcat
CMD ["catalina.sh", "run"]