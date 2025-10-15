# -------- Stage 1: Build the application --------
FROM maven:3.8.7-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /build

# Copy Maven project files
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# -------- Stage 2: Create runtime image --------
FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /build/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
