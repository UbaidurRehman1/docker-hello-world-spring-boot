# Maven build container 

FROM maven:3.6.3-jdk-14 as maven_build

COPY pom.xml /tmp/

COPY src /tmp/src/

WORKDIR /tmp/

RUN mvn package

#pull base image

FROM openjdk:14-jdk-buster

#maintainer 
MAINTAINER dstar55@yahoo.com
#expose port 8080
EXPOSE 8080 9001

#RUN wget https://download-gcdn.ej-technologies.com/jprofiler/jprofiler_linux_11_1_2.tar.gz -P /tmp/ && \
#  tar -xzf /tmp/jprofiler_linux_11_1_2.tar.gz -C /usr/local &&\
#  rm /tmp/jprofiler_linux_11_1_2.tar.gz

ENV JPAGENT_PATH="-agentpath:/usr/local/jprofiler11/bin/linux-x64/libjprofilerti.so=port=8849"

RUN mkdir /app && \
groupadd -r ubaid -g 433 && \
useradd -u 431 -r -g ubaid -d /app -s /sbin/nologin -c "Docker image user" ubaid && \
chown -R ubaid:ubaid /app

#copy hello world to docker image from builder image

USER ubaid:ubaid
COPY --from=maven_build /tmp/target/hello-world-0.1.0.jar /app/hello-world-0.1.0.jar


#default command
#CMD java -jar /app/hello-world-0.1.0.jar -agentpath:/usr/local/jprofiler11/bin/linux-x64/libjprofilerti.so=port=8849
ENTRYPOINT ["java",  "-jar", "/app/hello-world-0.1.0.jar",
 "-Dcom.sun.management.jmxremote",
 "-Dcom.sun.management.jmxremote.local.only=false",
 "-Dcom.sun.management.jmxremote.port=9001",
 "-Dcom.sun.management.jmxremote.authenticate=false",
 "-Dcom.sun.management.jmxremote.ssl=false",
 "-Dcom.sun.management.jmxremote.rmi.port=9001",
 "-Djava.rmi.server.hostname=35.232.192.246"]