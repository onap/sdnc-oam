package org.onap.sdnc.oam.datamigrator.common;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URL;
import java.util.Properties;

public class MigratorConfiguration {

    private String sourceHost ;
    private String sourceUser ;
    private String sourcePassword ;
    private String targetHost ;
    private String targetUser ;
    private String targetPassword ;
    private String dataPath;

    private static final String SDNC_CONFIG_DIR = "SDNC_CONFIG_DIR";
    private static final Logger LOG = LoggerFactory
            .getLogger(MigratorConfiguration.class);

    public MigratorConfiguration (){
        String propDir = System.getenv(SDNC_CONFIG_DIR);
        if (propDir == null) {
            propDir = "/opt/sdnc/data/properties";
        }
        try {
            init(propDir);
        } catch (Exception e) {
            LOG.error("Cannot initialize MigratorConfiguration", e);
        }
    }

    public MigratorConfiguration (String propDir){
        try {
            init(propDir);
        } catch (Exception e) {
            LOG.error("Cannot initialize MigratorConfiguration", e);
        }
    }

    public void init(String propDir) throws IOException {
        String propPath = propDir + "/data-migrator.properties";
        URL propPathUrl= getClass().getClassLoader().getResource(propPath);
        File propFile = (propPathUrl != null) ? new File(propPathUrl.getFile()) : new File(propPath); 
        if (!propFile.exists()) {
            throw new FileNotFoundException(
                    "Missing configuration properties file : "
                            + propFile);
        }

        Properties props = new Properties();
        props.load(new FileInputStream(propFile));
        this.sourceHost = props.getProperty("org.onap.sdnc.datamigrator.source.host");
        this.sourceUser = props.getProperty("org.onap.sdnc.datamigrator.source.user");
        this.sourcePassword = props.getProperty("org.onap.sdnc.datamigrator.source.password");
        this.targetHost = props.getProperty("org.onap.sdnc.datamigrator.target.host");
        this.targetUser = props.getProperty("org.onap.sdnc.datamigrator.target.user");
        this.targetPassword = props.getProperty("org.onap.sdnc.datamigrator.target.password");
        this.dataPath = props.getProperty("org.onap.sdnc.datamigrator.data.path");
    }

    public String getSourceHost() {
        return sourceHost;
    }

    public String getSourceUser() {
        return sourceUser;
    }

    public String getSourcePassword() {
        return sourcePassword;
    }

    public String getTargetHost() {
        return targetHost;
    }

    public String getTargetUser() {
        return targetUser;
    }

    public String getTargetPassword() {
        return targetPassword;
    }

    public String getDataPath() {
        return dataPath;
    }

    public void setDataPath(String dataPath) {
        this.dataPath = dataPath;
    }
}
