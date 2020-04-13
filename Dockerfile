# Maven build container 

FROM maven:3.5.2-jdk-8-alpine AS maven_build

COPY pom.xml /tmp/

COPY src /tmp/src/

WORKDIR /tmp/

RUN mvn package

#pull base image

FROM openjdk:8-jdk-alpine

#maintainer 
MAINTAINER dstar55@yahoo.com
#expose port 8080
EXPOSE 8080 8849

RUN wget https://download-gcdn.ej-technologies.com/jprofiler/jprofiler_linux_11_1_2.tar.gz -P /tmp/ && \
  tar -xzf /tmp/jprofiler_linux_11_1_2.tar.gz -C /usr/local &&\
  rm /tmp/jprofiler_linux_11_1_2.tar.gz

ENV JPAGENT_PATH="-agentpath:/usr/local/jprofiler11/bin/linux-x64/libjprofilerti.so=port=8849"

#RUN groupadd -r ubaid -g 433 && \
#useradd -u 431 -r -g ubaid -d / -s /sbin/nologin -c "Docker image user" ubaid && \
#chown -R ubaid:ubaid /

#copy hello world to docker image from builder image

COPY --from=maven_build /tmp/target/hello-world-0.1.0.jar /data/hello-world-0.1.0.jar


#default command
CMD java -jar /data/hello-world-0.1.0.jar -agentpath:/usr/local/jprofiler11/bin/linux-x64/libjprofilerti.so=port=8849
