package org.onap.sdnc.oam.datamigrator;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DataMigration {

    private static final Logger LOG = LoggerFactory.getLogger(DataMigration.class);

    public static void main(String[] args) {
        try {
            DataMigrationInternal dataMigrationInternal = new DataMigrationInternal(LOG);
            dataMigrationInternal.run(args);
        }catch (Exception e){
            e.printStackTrace();
            LOG.error("Error in DataMigration" + e.getMessage());
        }
        return;
    }
}
