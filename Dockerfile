# ----------- Stage 1: Build the Java application -----------
FROM maven:3.8.7-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# ----------- Stage 2: Run the app -----------
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=builder /build/target/*.jar app.jar
EXPOSE 9090
CMD ["java", "-jar", "app.jar"]
