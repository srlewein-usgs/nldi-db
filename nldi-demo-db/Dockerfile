FROM nldidb_nldi_db

MAINTAINER David Steinich <drsteini@usgs.gov>

############################################
# Grab Files to Load the Demo Database Data
############################################

COPY ./3_load_demo.sh /docker-entrypoint-initdb.d/

ADD https://cida.usgs.gov/artifactory/nldi/datasets/nldi_data.crawler_source.pgdump.gz $LIQUIBASE_HOME/
ADD https://cida.usgs.gov/artifactory/nldi/datasets/feature_wqp_yahara.backup.gz $LIQUIBASE_HOME/
ADD https://cida.usgs.gov/artifactory/nldi/datasets/feature_huc12pp_yahara.backup.gz $LIQUIBASE_HOME/
ADD https://cida.usgs.gov/artifactory/nldi/datasets/feature_np21_nwis_yahara.backup.gz $LIQUIBASE_HOME/
