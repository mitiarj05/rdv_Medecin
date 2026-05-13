# On utilise l'image officielle de Tomcat 10
FROM tomcat:10.1-jdk17-temurin-jammy

# On supprime les applications par défaut de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# On copie notre fichier WAR dans le dossier webapps de Tomcat
# Le fichier WAR doit s'appeler ROOT.war pour qu'il soit accessible à la racine
COPY target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Le port 8080 est exposé par défaut
EXPOSE 8080

# On démarre Tomcat
CMD ["catalina.sh", "run"]