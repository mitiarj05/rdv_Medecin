FROM tomcat:10.1-jdk17-temurin-jammy

# Supprimer les applications par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR dans webapps (sans le renommer en ROOT.war)
COPY rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Exposer le port
EXPOSE 8080

CMD ["catalina.sh", "run"]