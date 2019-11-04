FROM adoptopenjdk:11-jdk-openj9
RUN mkdir /app
ARG VERSION=1.0.0
COPY build/libs/spring-application-${VERSION}.jar /app/spring-application.jar
WORKDIR  /app
ENTRYPOINT exec java ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom -jar /app/spring-application.jar