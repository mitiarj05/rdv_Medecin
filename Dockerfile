# Étape 1 : Construction du WAR avec Maven
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# Étape 2 : Déploiement sur Tomcat
FROM tomcat:10.1-jdk17

# Supprimer les applications par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le fichier WAR depuis l'étape de construction
# Tomcat le déploiera automatiquement à la racine ('ROOT')
COPY --from=build /app/target/rdv-medical.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

# Lancer Tomcat
CMD ["catalina.sh", "run"]
