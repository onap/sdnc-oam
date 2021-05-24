--
-- Dumping data for table `SERVICE_MODEL`
--

LOCK TABLES `SERVICE_MODEL` WRITE;
/*!40000 ALTER TABLE `SERVICE_MODEL` DISABLE KEYS */;
INSERT INTO `SERVICE_MODEL` VALUES ('00e50cbd-ef0f-4b28-821e-f2b583752dd3','!!com.att.sdnctl.uebclient.SdncNetworkServiceModel\ndescription: null\nimports:\n- Second try_vbng: {file: resource-SecondTryVbng-template.yml}\nmetadata: {invariantUUID: dbf9288d-18ef-4d28-82cb-29373028f367, UUID: 00e50cbd-ef0f-4b28-821e-f2b583752dd3,\n  name: vBNG_0202, description: Virtual, type: Service, category: Network L1-3, serviceEcompNaming: false,\n  serviceHoming: false}\ntopology_template:\n  node_templates:\n    Second try_vbng 1:\n      type: com.att.d2.resource.vf.SecondTryVbng\n      metadata: {invariantUUID: 57516bfc-35f5-4169-a4ee-66a495a9c645, UUID: f196fdad-9b74-4fcc-9d38-72f4a71aea77,\n        customizationUUID: 72a9f413-4d16-4f7b-b0bc-d98f87997f01, version: \'1.0\', name: Second try_vbng,\n        description: ntwork, type: VF, category: Generic, subcategory: Network Elements}\n  groups:\n    secondtry_vbng1..SecondTryVbng..VSR_base_hot..module-0:\n      type: com.att.d2.groups.VfModule\n      metadata: {vfModuleModelName: SecondTryVbng..VSR_base_hot..module-0, vfModuleModelInvariantUUID: b73fcd7d-f374-4e7e-a905-f5e58eb8a34a,\n        vfModuleModelUUID: 3b3ff306-b493-4b3d-bb3d-baa13c2d82c7, vfModuleModelVersion: \'1\',\n        vfModuleModelCustomizationUUID: d106e920-0188-48b7-9f90-ae7c1ab43b73}\n      properties: {min_vf_module_instances: 1, vf_module_label: VSR_base_hot, max_vf_module_instances: 1,\n        vf_module_type: Base, vf_module_description: null, volume_group: false, initial_count: 1}\n  substitution_mappings:\n    node_type: com.att.d2.service.Vbng0202\n    capabilities:\n      Second try_vbng 1.attachment_iom_ctrl_fabric_0_port:\n        type: tosca.capabilities.Attachment\n        occurrences: [0, UNBOUNDED]\n      Second try_vbng 1.os_CPM:\n        type: tosca.capabilities.OperatingSystem\n        occurrences: [1, UNBOUNDED]\n        properties:\n          distribution: {type: string, required: false}\n          type: {type: string, required: false}\n          version: {type: version, required: false}\n          architecture: {type: string, required: false}\n      Second try_vbng 1.scalable_CPM:\n        type: tosca.capabilities.Scalable\n        occurrences: [1, UNBOUNDED]\n        properties:\n          max_instances: {type: integer, default: 1, required: false}\n          min_instances: {type: integer, default: 1, required: false}\n          default_instances: {type: integer, required: false}\n      Second try_vbng 1.binding_iom_data_0_port:\n        type: tosca.capabilities.network.Bindable\n        occurrences: [0, UNBOUNDED]\n        valid_source_types: [com.att.d2.resource.cp.nodes.heat.network.contrailV2.VLANSubInterface]\n      Second try_vbng 1.attachment_iom_mgt_0_port:\n        type: tosca.capabilities.Attachment\n        occurrences: [0, UNBOUNDED]\n      Second try_vbng 1.binding_cpm_ctrl_fabric_0_port:\n        type: tosca.capabilities.network.Bindable\n        occurrences: [0, UNBOUNDED]\n        valid_source_types: [com.att.d2.resource.cp.nodes.heat.network.contrailV2.VLANSubInterface]\n      Second try_vbng 1.scalable_IOM:\n        type: tosca.capabilities.Scalable\n        occurrences: [1, UNBOUNDED]\n        properties:\n          max_instances: {type: integer, default: 1, required: false}\n          min_instances: {type: integer, default: 1, required: false}\n          default_instances: {type: integer, required: false}\n      Second try_vbng 1.attachment_iom_data_0_port:\n        type: tosca.capabilities.Attachment\n        occurrences: [0, UNBOUNDED]\n      Second try_vbng 1.host_CPM:\n        type: tosca.capabilities.Container\n        occurrences: [1, UNBOUNDED]\n        valid_source_types: [tosca.nodes.SoftwareComponent]\n        properties:\n          num_cpus: {type: integer, required: false}\n          disk_size: {type: scalar-unit.size, required: false}\n          cpu_frequency: {type: scalar-unit.frequency, required: false}\n          mem_size: {type: scalar-unit.size, required: false}\n      Second try_vbng 1.attachment_cpm_mgt_0_port:\n        type: tosca.capabilities.Attachment\n        occurrences: [0, UNBOUNDED]\n      Second try_vbng 1.binding_iom_data_1_port:\n        type: tosca.capabilities.network.Bindable\n        occurrences: [0, UNBOUNDED]\n        valid_source_types: [com.att.d2.resource.cp.nodes.heat.network.contrailV2.VLANSubInterface]\n      Second try_vbng 1.attachment_iom_data_3_port:\n        type: tosca.capabilities.Attachment\n        occurrences: [0, UNBOUNDED]\n      Second try_vbng 1.binding_iom_mgt_0_port:\n        type: tosca.capabilities.network.Bindable\n        occurrences: [0, UNBOUNDED]\n        valid_source_types: [com.att.d2.resource.cp.nodes.heat.network.contrailV2.VLANSubInterface]\n      Second try_vbng 1.attachment_iom_data_2_port:\n        type: tosca.capabilities.Attachment\n        occurrences: [0, UNBOUNDED]\n      Second try_vbng 1.binding_iom_data_2_port:\n        type: tosca.capabilities.network.Bindable\n        occurrences: [0, UNBOUNDED]\n        valid_source_types: [com.att.d2.resource.cp.nodes.heat.network.contrailV2.VLANSubInterface]\n      Second try_vbng 1.endpoint_CPM:\n        type: tosca.capabilities.Endpoint.Admin\n        occurrences: [1, UNBOUNDED]\n        properties:\n          port_name: {type: string, required: false}\n          protocol: {type: string, default: tcp, required: false}\n          port: {type: PortDef, required: false}\n          initiator: {type: string, default: source, required: false}\n          network_name: {type: string, default: PRIVATE, required: false}\n          secure: {type: boolean, default: true, required: false}\n          ports:\n            type: map\n            required: false\n            entry_schema: {type: PortSpec}\n          url_path: {type: string, required: false}\n      Second try_vbng 1.binding_cpm_mgt_0_port:\n        type: tosca.capabilities.network.Bindable\n        occurrences: [0, UNBOUNDED]\n        valid_source_types: [com.att.d2.resource.cp.nodes.heat.network.contrailV2.VLANSubInterface]\n      Second try_vbng 1.feature:\n        type: tosca.capabilities.Node\n        occurrences: [1, UNBOUNDED]\n      Second try_vbng 1.binding_IOM:\n        type: tosca.capabilities.network.Bindable\n        occurrences: [1, UNBOUNDED]\n      Second try_vbng 1.attachment_cpm_ctrl_fabric_0_port:\n        type: tosca.capabilities.Attachment\n        occurrences: [0, UNBOUNDED]\n      Second try_vbng 1.binding_iom_ctrl_fabric_0_port:\n        type: tosca.capabilities.network.Bindable\n        occurrences: [0, UNBOUNDED]\n        valid_source_types: [com.att.d2.resource.cp.nodes.heat.network.contrailV2.VLANSubInterface]\n      Second try_vbng 1.binding_iom_data_3_port:\n        type: tosca.capabilities.network.Bindable\n        occurrences: [0, UNBOUNDED]\n        valid_source_types: [com.att.d2.resource.cp.nodes.heat.network.contrailV2.VLANSubInterface]\n      Second try_vbng 1.binding_CPM:\n        type: tosca.capabilities.network.Bindable\n        occurrences: [1, UNBOUNDED]\n      Second try_vbng 1.attachment_iom_data_1_port:\n        type: tosca.capabilities.Attachment\n        occurrences: [0, UNBOUNDED]\n      Second try_vbng 1.host_IOM:\n        type: tosca.capabilities.Container\n        occurrences: [1, UNBOUNDED]\n        valid_source_types: [tosca.nodes.SoftwareComponent]\n        properties:\n          num_cpus: {type: integer, required: false}\n          disk_size: {type: scalar-unit.size, required: false}\n          cpu_frequency: {type: scalar-unit.frequency, required: false}\n          mem_size: {type: scalar-unit.size, required: false}\n      Second try_vbng 1.os_IOM:\n        type: tosca.capabilities.OperatingSystem\n        occurrences: [1, UNBOUNDED]\n        properties:\n          distribution: {type: string, required: false}\n          type: {type: string, required: false}\n          version: {type: version, required: false}\n          architecture: {type: string, required: false}\n      Second try_vbng 1.endpoint_IOM:\n        type: tosca.capabilities.Endpoint.Admin\n        occurrences: [1, UNBOUNDED]\n        properties:\n          port_name: {type: string, required: false}\n          protocol: {type: string, default: tcp, required: false}\n          port: {type: PortDef, required: false}\n          initiator: {type: string, default: source, required: false}\n          network_name: {type: string, default: PRIVATE, required: false}\n          secure: {type: boolean, default: true, required: false}\n          ports:\n            type: map\n            required: false\n            entry_schema: {type: PortSpec}\n          url_path: {type: string, required: false}\n    requirements:\n      Second try_vbng 1.local_storage_IOM:\n        occurrences: [0, UNBOUNDED]\n        capability: tosca.capabilities.Attachment\n        node: tosca.nodes.BlockStorage\n        relationship: tosca.relationships.AttachesTo\n      Second try_vbng 1.link_iom_ctrl_fabric_0_port:\n        occurrences: [1, 1]\n        capability: tosca.capabilities.network.Linkable\n        node: tosca.nodes.Root\n        relationship: tosca.relationships.network.LinksTo\n      Second try_vbng 1.link_cpm_ctrl_fabric_0_port:\n        occurrences: [1, 1]\n        capability: tosca.capabilities.network.Linkable\n        node: tosca.nodes.Root\n        relationship: tosca.relationships.network.LinksTo\n      Second try_vbng 1.link_cpm_mgt_0_port:\n        occurrences: [1, 1]\n        capability: tosca.capabilities.network.Linkable\n        node: tosca.nodes.Root\n        relationship: tosca.relationships.network.LinksTo\n      Second try_vbng 1.link_iom_data_3_port:\n        occurrences: [1, 1]\n        capability: tosca.capabilities.network.Linkable\n        node: tosca.nodes.Root\n        relationship: tosca.relationships.network.LinksTo\n      Second try_vbng 1.local_storage_CPM:\n        occurrences: [0, UNBOUNDED]\n        capability: tosca.capabilities.Attachment\n        node: tosca.nodes.BlockStorage\n        relationship: tosca.relationships.AttachesTo\n      Second try_vbng 1.dependency:\n        occurrences: [0, UNBOUNDED]\n        capability: tosca.capabilities.Node\n        node: tosca.nodes.Root\n        relationship: tosca.relationships.DependsOn\n      Second try_vbng 1.link_iom_data_2_port:\n        occurrences: [1, 1]\n        capability: tosca.capabilities.network.Linkable\n        node: tosca.nodes.Root\n        relationship: tosca.relationships.network.LinksTo\n      Second try_vbng 1.link_iom_data_0_port:\n        occurrences: [1, 1]\n        capability: tosca.capabilities.network.Linkable\n        node: tosca.nodes.Root\n        relationship: tosca.relationships.network.LinksTo\n      Second try_vbng 1.link_iom_mgt_0_port:\n        occurrences: [1, 1]\n        capability: tosca.capabilities.network.Linkable\n        node: tosca.nodes.Root\n        relationship: tosca.relationships.network.LinksTo\n      Second try_vbng 1.port:\n        occurrences: [0, UNBOUNDED]\n        capability: tosca.capabilities.Attachment\n        node: com.att.d2.resource.cp.nodes.heat.network.neutron.Port\n        relationship: com.att.d2.relationships.AttachesTo\n      Second try_vbng 1.link_iom_data_1_port:\n        occurrences: [1, 1]\n        capability: tosca.capabilities.network.Linkable\n        node: tosca.nodes.Root\n        relationship: tosca.relationships.network.LinksTo\ntosca_definitions_version: tosca_simple_yaml_1_0\n','dbf9288d-18ef-4d28-82cb-29373028f367',NULL,'vBNG_0202','Virtual','Service','Network L1-3','N','Vbng0202','service-Vbng0202-template.yml',NULL);
/*!40000 ALTER TABLE `SERVICE_MODEL` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `NETWORK_MODEL`
--

LOCK TABLES `NETWORK_MODEL` WRITE;
/*!40000 ALTER TABLE `NETWORK_MODEL` DISABLE KEYS */;
INSERT INTO `NETWORK_MODEL` VALUES ('b0cf3385-a390-488c-b6a0-d879fb4a4825','00e50cbd-ef0f-4b28-821e-f2b583752dd3','null','206d5e6c-4cba-4c14-b942-5d946c881869','9b7c1cbe-ddcd-458c-8792-d76391419b72','NEUTRON','VcpesvcVbng0412a.bng_mux','NEUTRON',NULL,NULL,NULL,'Y',NULL,'N',NULL,NULL,'N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1.0');
/*!40000 ALTER TABLE `NETWORK_MODEL` ENABLE KEYS */;
UNLOCK TABLES;
--
-- Dumping data for table `VFC_MODEL`
--

LOCK TABLES `VFC_MODEL` WRITE;
/*!40000 ALTER TABLE `VFC_MODEL` DISABLE KEYS */;
INSERT INTO `VFC_MODEL` VALUES ('8b84aeae-51cf-48c2-8bb1-50c7aa444a16','null','84dfff0d-74df-4782-afc9-8a902db20c89','621eac8e-ade1-4d21-86a4-1a66caf964db','1.0',NULL,'Y',NULL,'vgmux','vgmux','vgmux','vgmux2-base-ubuntu-16-04','m1.medium',NULL,'{ecomp_generated_naming=true}',0,NULL);
/*!40000 ALTER TABLE `VFC_MODEL` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `VFC_TO_NETWORK_ROLE_MAPPING`
--

LOCK TABLES `VFC_TO_NETWORK_ROLE_MAPPING` WRITE;
/*!40000 ALTER TABLE `VFC_TO_NETWORK_ROLE_MAPPING` DISABLE KEYS */;
INSERT INTO `VFC_TO_NETWORK_ROLE_MAPPING` VALUES (2034,'8b84aeae-51cf-48c2-8bb1-50c7aa444a16','default-network-role','vgmux','mux_gw_private',0,0,'N',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `VFC_TO_NETWORK_ROLE_MAPPING` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `VF_MODEL`
--

LOCK TABLES `VF_MODEL` WRITE;
/*!40000 ALTER TABLE `VF_MODEL` DISABLE KEYS */;
INSERT INTO `VF_MODEL` VALUES ('5724fcc8-2ae2-45ce-8d44-795092b85dee','null','b3dc6465-942c-42af-8464-2bf85b6e504b','ba3b8981-9a9c-4945-92aa-486234ec321f','1.0','vcpevsp_vgmux_0412',NULL,'Y',1,NULL,NULL,NULL,NULL,'integration','1.0', NULL, NULL, NULL);
/*!40000 ALTER TABLE `VF_MODEL` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `VF_MODULE_MODEL`
--

LOCK TABLES `VF_MODULE_MODEL` WRITE;
/*!40000 ALTER TABLE `VF_MODULE_MODEL` DISABLE KEYS */;
INSERT INTO `VF_MODULE_MODEL` VALUES ('59ffe5ba-cfaf-4e83-a2f3-159522dcebac','null','7ca7567c-f42c-4ed8-bcde-f8971b92d90a','513cc9fc-fff5-4c46-9728-393437536c4d','1','Base',NULL,NULL,'5724fcc8-2ae2-45ce-8d44-795092b85dee','base_vcpe_vgmux');
/*!40000 ALTER TABLE `VF_MODULE_MODEL` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `VF_MODULE_TO_VFC_MAPPING`
--

LOCK TABLES `VF_MODULE_TO_VFC_MAPPING` WRITE;
/*!40000 ALTER TABLE `VF_MODULE_TO_VFC_MAPPING` DISABLE KEYS */;
INSERT INTO `VF_MODULE_TO_VFC_MAPPING` VALUES (1668,'59ffe5ba-cfaf-4e83-a2f3-159522dcebac','8b84aeae-51cf-48c2-8bb1-50c7aa444a16','vgmux',1);
/*!40000 ALTER TABLE `VF_MODULE_TO_VFC_MAPPING` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-11-02 21:47:47
