FROM alpine:3.10

ARG duration
ARG base_url
ARG uri
ARG threads
ARG throughput
ARG rid
ARG eid

ENV duration $duration
ENV base_url $base_url
ENV uri $uri
ENV threads $threads
ENV throughput $throughput
ENV rid $rid
ENV eid $eid

ARG JMETER_VERSION="5.3"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

RUN    apk update \
  && apk upgrade \
  && apk add ca-certificates \
  && update-ca-certificates \
  && apk add --update openjdk8-jre tzdata curl bash npm zip unzip python g++ \
  && apk add --no-cache nss \
  && rm -rf /var/cache/apk/* \
  && mkdir -p /tmp/dependencies  \
  && curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
  && mkdir -p /opt  \
  && tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
  && cd /opt/apache-jmeter-${JMETER_VERSION}/bin \
  && sed -i -e 's/#httpclient4.validate_after_inactivity=4900/httpclient4.validate_after_inactivity=66600/g' jmeter.properties \
  && sed -i -e 's/#httpclient4.time_to_live=60000/httpclient4.time_to_live=70000 /g' jmeter.properties \
  && rm -rf /tmp/dependencies

RUN npm config set unsafe-perm true
RUN npm install azure-cli -g

ENV PATH $PATH:$JMETER_BIN
WORKDIR	${JMETER_HOME}

COPY test-plan.jmx test-plan.jmx

RUN jmeter -Jrid=${rid} -Jeid=${eid} -Jduration=${duration} -Jbase_url=${base_url} -Juri=${uri} -Jthreads=${threads} -Jthroughput=${throughput} -n -t test-plan.jmx -l results.jtl -e -o report

ENV REPORT "report_${rid}_${eid}.zip"
RUN zip -r ${REPORT} report
RUN azure telemetry --disable
RUN azure storage blob upload --connection-string AZURE_STORAGE_CONNECTION_STRING ${REPORT} AZURE_STORAGE_CONTAINER_NAME
