# Inspired by sonatype/nexus:oss
FROM       centos:centos7
MAINTAINER Fabio Napoleoni <f.napoleoni@gmail.com>

ENV SCM_HOME /data
ENV SCM_MANAGER_VERSION 1.46

RUN yum install -y \
  curl tar createrepo \
  && yum clean all

RUN cd /var/tmp \
  && curl --fail --silent --location --retry 3 -O \
  --header "Cookie: oraclelicense=accept-securebackup-cookie; " \
  http://download.oracle.com/otn-pub/java/jdk/7u76-b13/jdk-7u76-linux-x64.rpm \
  && rpm -Ui jdk-7u76-linux-x64.rpm \
  && rm -rf jdk-7u76-linux-x64.rpm

RUN mkdir -p /opt/scm-manager \
  && curl --fail --silent --location --retry 3 \
    http://maven.scm-manager.org/nexus/content/repositories/releases/sonia/scm/scm-server/${SCM_MANAGER_VERSION}/scm-server-${SCM_MANAGER_VERSION}-app.tar.gz \
  | gunzip | tar x -C /tmp scm-server \
  && mv /tmp/scm-server/* /opt/scm-manager \
  && rm -rf /tmp/scm-server

RUN useradd -r -u 300 -m -c "Scm manager account" -s /bin/false scm-manager

# Ensure the data folder exist and is owned by scm-manager
RUN mkdir -p ${SCM_HOME}
RUN chown -R scm-manager ${SCM_HOME}
# Ensure software is owned by user
RUN chown -R scm-manager /opt/scm-manager

VOLUME ${SCM_HOME}

EXPOSE 8080
WORKDIR /opt/scm-manager
USER scm-manager
# Repeat for user scm-manager
ENV SCM_HOME /data
ENV MAX_HEAP 768m
ENV MIN_HEAP 256m
ENV JAVA_HOME /usr/java/default/
ENV JAVA_OPTS -server -XX:MaxPermSize=192m -Djava.net.preferIPv4Stack=true -Xms${MIN_HEAP} -Xmx${MAX_HEAP}
# Run the process from current directory
CMD bin/scm-server