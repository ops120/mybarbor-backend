# Backend Dockerfile
FROM eclipse-temurin:17-jdk-alpine as builder

WORKDIR /app
COPY pom.xml .
COPY src ./src

# Use Aliyun Maven mirror
RUN apk add --no-cache maven && \
    mkdir -p /usr/share/maven/ref/conf && \
    echo '<?xml version="1.0" encoding="UTF-8"?><settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd"><mirrors><mirror><id>aliyun</id><name>Aliyun Maven</name><url>https://maven.aliyun.com/repository/public</url><mirrorOf>central</mirrorOf></mirror></mirrors></settings>' > /usr/share/maven/ref/conf/settings.xml && \
    mvn clean package -DskipTests -s /usr/share/maven/ref/conf/settings.xml

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENV JAVA_OPTS="-Xms256m -Xmx512m"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
