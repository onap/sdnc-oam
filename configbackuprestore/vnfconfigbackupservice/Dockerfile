FROM anapsix/alpine-java:jdk8

#Used to create sdnc_report_service docker image

MAINTAINER dt00503496@techmahindra.com

#EXPOSE 8081

#install Spring Boot artifact

VOLUME /tmp

RUN rm -rf /tmp/*

COPY . tmp/

WORKDIR "/tmp/"

ENTRYPOINT ["java","-jar","target/vnfconfigbackupservice-1.5.0-SNAPSHOT.jar"]