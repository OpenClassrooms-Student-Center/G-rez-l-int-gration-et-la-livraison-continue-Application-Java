# --- Build stage ---
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

COPY gradlew ./
COPY gradle gradle
COPY build.gradle settings.gradle ./
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew && ./gradlew --no-daemon --version

COPY src src

RUN ./gradlew --no-daemon clean test bootWar

# --- Runtime stage ---
FROM eclipse-temurin:21-jre AS runtime
WORKDIR /app

RUN groupadd --system spring && useradd --system --gid spring spring
COPY --from=build --chown=spring:spring /app/build/libs/*.war app.war
USER spring:spring

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.war"]
