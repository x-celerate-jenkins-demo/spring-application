FROM eclipse-temurin:11-jdk as builder
RUN mkdir /app
ARG VERSION=1.0.0
COPY build/libs/spring-application-${VERSION}.jar /app/spring-application.jar
WORKDIR  /app
RUN java -Djarmode=layertools -jar spring-application.jar extract

FROM eclipse-temurin:11-jdk
WORKDIR app
COPY --from=builder app/dependencies/ ./
COPY --from=builder app/spring-boot-loader/ ./
COPY --from=builder app/snapshot-dependencies/ ./
COPY --from=builder app/application/ ./
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=50", "-XX:+HeapDumpOnOutOfMemoryError", "-XX:HeapDumpPath=/dumps", "-Djava.security.egd=file:/dev/./urandom", "org.springframework.boot.loader.JarLauncher"]
