FROM alpine:3.16.1

# Setting environment variables
ENV JMETER_VERSION 5.5
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN	${JMETER_HOME}/bin
ENV TESTDIR /test
ENV PATH="~/.local/bin:$PATH"
ENV S3_URL <AWS S3 )bject URL for entrypoint.sh script>
ENV JMETER_URL https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}

# Install packages
RUN apk add --no-cache \
        python3 py3-pip libc6-compat ca-certificates bash curl \
    && update-ca-certificates \
    && curl -L --silent ${JMETER_URL}.tgz > /tmp/apache-jmeter-${JMETER_VERSION}.tgz \
    && tar -xzf /tmp/apache-jmeter-${JMETER_VERSION}.tgz -C /opt \
    && apk add --update openjdk8-jre tzdata curl unzip bash \
    && pip3 install --upgrade pip \
    && pip3 install awscli \     
    && apk upgrade  \
    && apk update  \
    && rm -rf /var/cache/apk/*
  
ENV PATH $PATH:$JMETER_BIN
WORKDIR	${TESTDIR}

# Copying entrypoint file
ADD $S3_URL $TESTDIR

# Give execute permissions to entrypoint file
RUN chmod u+x entrypoint.sh

# Docker entry point to run the test
ENTRYPOINT ["./entrypoint.sh"]