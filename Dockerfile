# Étape 1 : Construction avec Maven (sur Render)
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

# Copier le pom.xml d'abord (optimisation du cache)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copier tout le code source
COPY src ./src

# Compiler le projet et générer le WAR
RUN mvn clean package -DskipTests

# Étape 2 : Image finale Tomcat
FROM tomcat:10.1-jdk17

# Supprimer le contenu par défaut de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR depuis l'étape de build
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

# Exposer le port
EXPOSE 8080

# Démarrer Tomcat
CMD ["catalina.sh", "run"]