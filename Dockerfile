FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/rdv-medical.war /app/rdv-medical.war
EXPOSE 8080
CMD ["java", "-jar", "rdv-medical.war"]