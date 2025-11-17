# Multi-stage build for smaller runtime image
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /workspace

# Copy Maven wrapper and pom to leverage layer caching
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN chmod +x mvnw
RUN ./mvnw -q -DskipTests dependency:go-offline

# Copy source
COPY src ./src
# Build application (skip tests for speed; run tests separately in CI)
RUN ./mvnw -q -DskipTests package

# Runtime image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# Copy built jar
COPY --from=build /workspace/target/*.jar app.jar
# Expose port (overridden by server.port env if supplied)
EXPOSE 8080
# Health check (optional)
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java","-jar","/app/app.jar"]
