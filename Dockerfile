# Buildivaihe (Java Development Kit, kääntäjä)
FROM eclipse-temurin:11-jdk AS builder
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y maven
RUN mvn clean package -DskipTests

# Paketointivaihe (Java Runtime Environment, suoritusympäristö)
FROM eclipse-temurin:11-jre
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
