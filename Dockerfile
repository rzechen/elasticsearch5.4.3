FROM centos
MAINTAINER ranzechen@dingtalk.com

#base config
ENV ES_VERSION 5.4.3
ENV ES_CONFIG_PATH /usr/local/app/elasticsearch-${ES_VERSION}/config/elasticsearch.yml

#install base command
RUN yum -y install unzip zip lsof 

#tar es
ADD elasticsearch-${ES_VERSION}.tar.gz /usr/local/app/
ADD elasticsearch-analysis-ik-${ES_VERSION}.zip /usr/local/app/elasticsearch-${ES_VERSION}/plugins/elasticsearch-analysis-ik/
RUN unzip /usr/local/app/elasticsearch-${ES_VERSION}/plugins/elasticsearch-analysis-ik/elasticsearch-analysis-ik-${ES_VERSION}.zip -d /usr/local/app/elasticsearch-${ES_VERSION}/plugins/elasticsearch-analysis-ik/
RUN rm /usr/local/app/elasticsearch-${ES_VERSION}/plugins/elasticsearch-analysis-ik/elasticsearch-analysis-ik-${ES_VERSION}.zip

#JAVA config
ADD jdk-8u161-linux-x64.tar.gz /usr/local/app/
ENV JAVA_HOME /usr/local/app/jdk1.8.0_161
ENV JRE_HOME ${JAVA_HOME}/jre
ENV CLASSPATH .:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV PATH ${JAVA_HOME}/bin:$PATH

#create es user and chown
RUN useradd es
RUN chown es.es /usr/local/app/elasticsearch-${ES_VERSION}/ -R 
USER es

#install ingest-attachment
COPY ingest-attachment-${ES_VERSION}.zip /usr/local/app/elasticsearch-${ES_VERSION}/
RUN /usr/local/app/elasticsearch-${ES_VERSION}/bin/elasticsearch-plugin install file:///usr/local/app/elasticsearch-${ES_VERSION}/ingest-attachment-${ES_VERSION}.zip

#es config
RUN sed -i "s/#cluster.name: my-application/ cluster.name: es-cluster/g" ${ES_CONFIG_PATH}
RUN sed -i "s/#node.name: node-1/ node.name: node-1/g" ${ES_CONFIG_PATH}
RUN sed -i "s/#path.data: \/path\/to\/data/ path.data: \/usr\/local\/app\/elasticsearch-${ES_VERSION}\/data/g" ${ES_CONFIG_PATH}
RUN sed -i "s/#path.logs: \/path\/to\/logs/ path.logs: \/usr\/local\/app\/elasticsearch-${ES_VERSION}\/logs/g" ${ES_CONFIG_PATH}
RUN sed -i "s/#http.port: 9200/ http.port: 9200/g" ${ES_CONFIG_PATH}
RUN sed -i "s/#network.host: 192.168.0.1/ network.host: 0.0.0.0/g" ${ES_CONFIG_PATH}
RUN echo " bootstrap.memory_lock: false" >> ${ES_CONFIG_PATH}
RUN echo " bootstrap.system_call_filter: false" >> ${ES_CONFIG_PATH}

#create es log dir and data dir
RUN mkdir /usr/local/app/elasticsearch-${ES_VERSION}/{data,logs}

#public ports
EXPOSE 9200 9300

ENTRYPOINT cat ${ES_CONFIG_PATH}
ENTRYPOINT /usr/local/app/elasticsearch-${ES_VERSION}/bin/elasticsearch && tail -f /usr/local/app/elasticsearch-${ES_VERSION}/logs/es-cluster.log
