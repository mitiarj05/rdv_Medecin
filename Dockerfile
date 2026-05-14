# 1. On prend une image Tomcat toute prête comme base
FROM tomcat:10.1-jdk17

# 2. On supprime le contenu par défaut de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# 3. On copie ton application dans le dossier "ROOT" pour qu'elle soit accessible directement à la racine
COPY target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# 4. On expose le port sur lequel Tomcat écoute
EXPOSE 8080

# 5. On démarre Tomcat
CMD ["catalina.sh", "run"]