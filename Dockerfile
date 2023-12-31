
#Stage 1: Build the Jar
# initialize build and set base image for first stage
FROM maven:3.6.3-adoptopenjdk-11 as Build
# speed up Maven JVM a bit
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
# set working directory
WORKDIR /app
# copy just pom.xml
COPY pom.xml .
# go-offline using the pom.xml
RUN mvn dependency:go-offline
# copy your other files
COPY ./src ./src
# compile the source code and package it in a jar file
RUN mvn clean install -Dmaven.test.skip=true

#Stage 2: Run The Application
# set base image for second stage
FROM adoptopenjdk/openjdk11:jre-11.0.9_11-alpine
# set deployment directory
WORKDIR /app
# copy over the built artifact from the maven image
COPY --from=Build /app/target/*.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]