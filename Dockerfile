FROM mdillon/postgis:10-alpine

MAINTAINER David Steinich <drsteini@usgs.gov>

############################################
# Required for JRE 8 - Java 8 is required to run the Liquibase JAR - lifted from https://github.com/docker-library/openjdk
############################################

RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:$JAVA_HOME/bin

RUN set -x \
    && apk update && apk upgrade \
    && apk add --no-cache bash \
    && apk add --no-cache openjdk8 \
    && [ "$JAVA_HOME" = "$(docker-java-home)" ]


############################################
# Install Liquibase
############################################

ENV LIQUIBASE_HOME /opt/liquibase
ENV JENKINS_WORKSPACE /var/jenkins_home/jobs/LiquibaseNLDI/workspace
ENV LOCALONLY "-c listen_addresses='127.0.0.1, ::1'"

ADD https://github.com/liquibase/liquibase/releases/download/liquibase-parent-3.6.2/liquibase-3.6.2-bin.tar.gz $LIQUIBASE_HOME/

ADD http://search.maven.org/remotecontent?filepath=org/slf4j/slf4j-api/1.7.25/slf4j-api-1.7.25.jar $LIQUIBASE_HOME/lib/slf4j-api.jar

ADD https://jdbc.postgresql.org/download/postgresql-42.2.5.jar $LIQUIBASE_HOME/lib/

RUN tar -xzf $LIQUIBASE_HOME/liquibase-3.6.2-bin.tar.gz -C $LIQUIBASE_HOME/


############################################
# Grab Files to Configure Database with Liquibase
############################################

COPY ./dbInit/1_run_liquibase.sh /docker-entrypoint-initdb.d/

COPY ./dbInit/liquibase.properties $LIQUIBASE_HOME/

COPY ./dbInit/liquibasePostgres.properties $LIQUIBASE_HOME/

COPY ./nldi-liquibase $JENKINS_WORKSPACE/nldi-liquibase

RUN chmod -R 777 $LIQUIBASE_HOME

############################################
# Grab Files to Load the Network Database Data
############################################

COPY ./dbInit/2_load_network.sh /docker-entrypoint-initdb.d/

ADD https://cida.usgs.gov/artifactory/nldi/datasets/nhdplus.yahara.pgdump.gz $LIQUIBASE_HOME/

ADD https://cida.usgs.gov/artifactory/nldi/datasets/characteristic_data.yahara.pgdump.gz $LIQUIBASE_HOME/
