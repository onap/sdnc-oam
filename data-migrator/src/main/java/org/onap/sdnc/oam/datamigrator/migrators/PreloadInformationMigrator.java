package org.onap.sdnc.oam.datamigrator.migrators;

import org.onap.sdnc.oam.datamigrator.common.Description;

import java.util.HashMap;
import java.util.HashSet;

@Description("Migrator for container 'preload-vnf' in GENERIC-RESOURCE-API.yang")
public class PreloadInformationMigrator extends RenameDeleteLeafMigrator {

    private static final String YANG_MODULE = "GENERIC-RESOURCE-API";

    static{
        deletedFields = new HashSet<>();
        deletedFields.add("preload-vnfs.vnf-preload-list.preload-data.vnf-topology-information");
        deletedFields.add("preload-vnfs.vnf-preload-list.preload-data.network-topology-information.network-topology-identifier.service-type");
        deletedFields.add("preload-vnfs.vnf-preload-list.preload-data.oper-status.last-action");
        renamedFields = new HashMap<>();
        renamedFields.put("preload-vnfs","preload-information");
        renamedFields.put("preload-vnfs.vnf-preload-list","preload-list");
        renamedFields.put("preload-vnfs.vnf-preload-list.vnf-type","preload-type");
        renamedFields.put("preload-vnfs.vnf-preload-list.vnf-name","preload-id");
        renamedFields.put("preload-vnfs.vnf-preload-list.preload-data.oper-status","preload-oper-status");
        renamedFields.put("preload-vnfs.vnf-preload-list.preload-data.network-topology-information","preload-network-topology-information");
        renamedFields.put("preload-vnfs.vnf-preload-list.preload-data.network-topology-information.network-topology-identifier","network-topology-identifier-structure");
    }

    @Override
    public String getYangModuleName() {
        return YANG_MODULE;
    }

    @Override
    public String getSourcePath() {
        return "preload-vnfs";
    }

    @Override
    public String getTargetPath() {
        return "preload-information";
    }
}
