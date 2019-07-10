/*
 * ============LICENSE_START==========================================
 * Copyright (c) 2019 PANTHEON.tech s.r.o.
 * ===================================================================
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
 * OF ANY KIND, either express or implied. See the License for the specific language governing permissions and
 * limitations under the License.
 * ============LICENSE_END============================================
 *
 */
package org.onap.sdnc.oam.lighty;

import io.lighty.core.controller.api.AbstractLightyModule;
import io.lighty.core.controller.api.LightyController;
import io.lighty.core.controller.api.LightyModule;
import io.lighty.core.controller.impl.LightyControllerBuilder;
import io.lighty.core.controller.impl.config.ConfigurationException;
import io.lighty.core.controller.impl.config.ControllerConfiguration;
import io.lighty.modules.northbound.restconf.community.impl.CommunityRestConf;
import io.lighty.modules.northbound.restconf.community.impl.CommunityRestConfBuilder;
import io.lighty.modules.northbound.restconf.community.impl.config.RestConfConfiguration;
import io.lighty.modules.northbound.restconf.community.impl.util.RestConfConfigUtils;
import io.lighty.modules.southbound.netconf.impl.NetconfTopologyPluginBuilder;
import io.lighty.modules.southbound.netconf.impl.config.NetconfConfiguration;
import io.lighty.modules.southbound.netconf.impl.util.NetconfConfigUtils;
import org.onap.ccsdk.sli.core.lighty.common.CcsdkLightyUtils;
import org.onap.ccsdk.sli.distribution.lighty.CcsdkLightyModule;
import org.opendaylight.aaa.encrypt.impl.AAAEncryptionServiceImpl;
import org.opendaylight.controller.md.sal.binding.api.DataBroker;
import org.opendaylight.controller.md.sal.binding.api.MountPointService;
import org.opendaylight.controller.md.sal.binding.api.NotificationPublishService;
import org.opendaylight.controller.sal.binding.api.RpcProviderRegistry;
import org.opendaylight.mdsal.binding.api.RpcProviderService;
import org.opendaylight.mdsal.singleton.common.api.ClusterSingletonServiceProvider;
import org.opendaylight.netconf.sal.connect.util.NetconfSalKeystoreService;
import org.opendaylight.yang.gen.v1.config.aaa.authn.encrypt.service.config.rev160915.AaaEncryptServiceConfig;
import org.opendaylight.yang.gen.v1.config.aaa.authn.encrypt.service.config.rev160915.AaaEncryptServiceConfigBuilder;
import org.opendaylight.yang.gen.v1.urn.opendaylight.netconf.keystore.rev171017.NetconfKeystoreService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The implementation of the {@link io.lighty.core.controller.api.LightyModule} that groups all necessary components
 * needed to start the SDNC lighty.io application.
 */
public class SdncLightyApplication extends AbstractLightyModule {

    private static final Logger LOG = LoggerFactory.getLogger(SdncLightyApplication.class);

    private ControllerConfiguration controllerConfiguration;
    private RestConfConfiguration restConfConfiguration;
    private NetconfConfiguration netconfSBPConfig;

    private LightyController lightyController;
    private CommunityRestConf communityRestConf;
    private LightyModule netconfSouthboundPlugin;
    private CcsdkLightyModule ccsdkLightyModule;
    private SdncLightyModule sdncModule;

    public SdncLightyApplication(ControllerConfiguration controllerConfiguration,
            RestConfConfiguration restConfConfiguration, NetconfConfiguration netconfSBPConfig) {
        this.controllerConfiguration = controllerConfiguration;
        this.restConfConfiguration = restConfConfiguration;
        this.netconfSBPConfig = netconfSBPConfig;
    }

    @Override
    protected boolean initProcedure() {
        // Start Lighty Controller with base OLD services
        LightyControllerBuilder lightyControllerBuilder = new LightyControllerBuilder();
        try {
            lightyController = lightyControllerBuilder.from(controllerConfiguration).build();
        } catch (ConfigurationException e) {
            LOG.error("Exception thrown while starting Lighty controller!", e);
            return false;
        }
        if (!CcsdkLightyUtils.startLightyModule(lightyController)) {
            LOG.error("Unable to start Lighty controller!");
            return false;
        }

        // Prepare needed ODL services
        DataBroker controllerDataBroker = lightyController.getServices().getControllerBindingDataBroker();
        org.opendaylight.mdsal.binding.api.DataBroker dataBroker =
                lightyController.getServices().getBindingDataBroker();
        NotificationPublishService notificationPublishService = lightyController.getServices()
                .getControllerBindingNotificationPublishService();
        RpcProviderRegistry rpcProviderRegistry = lightyController.getServices().getControllerRpcProviderRegistry();
        RpcProviderService rpcProviderService = lightyController.getServices().getRpcProviderService();
        MountPointService mountPointService = lightyController.getServices().getControllerBindingMountPointService();
        ClusterSingletonServiceProvider clusteringSingletonService =
                lightyController.getServices().getClusterSingletonServiceProvider();

        // Prepare AAA/security services
        java.security.Security.addProvider(
                new org.bouncycastle.jce.provider.BouncyCastleProvider()
        );
        AaaEncryptServiceConfig aaaEncryptConfig = createDefaultAaaEncryptServiceConfig();
        AAAEncryptionServiceImpl aaaEncryptionService = new AAAEncryptionServiceImpl(aaaEncryptConfig, dataBroker);
        NetconfSalKeystoreService netconfSalKeystoreService =
                new NetconfSalKeystoreService(dataBroker, aaaEncryptionService);
        lightyController.getServices().getRpcProviderService().registerRpcImplementation(NetconfKeystoreService.class,
                netconfSalKeystoreService);

        // Start RestConf
        CommunityRestConfBuilder communityRestConfBuilder = new CommunityRestConfBuilder();
        communityRestConf = communityRestConfBuilder
                .from(RestConfConfigUtils.getRestConfConfiguration(restConfConfiguration,
                        lightyController.getServices()))
                .build();
        if (!CcsdkLightyUtils.startLightyModule(communityRestConf)) {
            LOG.error("Unable to start RestConf!");
            return false;
        }

        // Start NetConf
        try {
            netconfSBPConfig = NetconfConfigUtils.injectServicesToTopologyConfig(
                    netconfSBPConfig, lightyController.getServices());
            netconfSBPConfig.setAaaService(aaaEncryptionService);
        } catch (ConfigurationException e) {
            LOG.error("Exception thrown while preparing configuration for NetConf!", e);
            return false;
        }
        NetconfTopologyPluginBuilder netconfSBPBuilder = new NetconfTopologyPluginBuilder();
        netconfSouthboundPlugin = netconfSBPBuilder
                .from(netconfSBPConfig, lightyController.getServices())
                .build();
        if (!CcsdkLightyUtils.startLightyModule(netconfSouthboundPlugin)) {
            LOG.error("Unable to start NetConf!");
            return false;
        }

        // Start Lighty CCSDK
        ccsdkLightyModule = new CcsdkLightyModule(controllerDataBroker, notificationPublishService,
                rpcProviderRegistry, aaaEncryptionService);
        if (!CcsdkLightyUtils.startLightyModule(ccsdkLightyModule)) {
            LOG.error("Unable to start CCSDK Lighty module!");
            return false;
        }

        // Start Lighty SDNC
        sdncModule = new SdncLightyModule(controllerDataBroker, rpcProviderRegistry, notificationPublishService, mountPointService,
                clusteringSingletonService, ccsdkLightyModule.getSliModule().getSvcLogicServiceImpl(),
                rpcProviderService, false);
        if (!CcsdkLightyUtils.startLightyModule(sdncModule)) {
            LOG.error("Unable to start SDNC Lighty module!");
            return false;
        }

        return true;
    }

    @Override
    protected boolean stopProcedure() {
        boolean stopSuccessful = true;

        if (!CcsdkLightyUtils.stopLightyModule(sdncModule)) {
            stopSuccessful = false;
        }

        if (!CcsdkLightyUtils.stopLightyModule(ccsdkLightyModule)) {
            stopSuccessful = false;
        }

        if (!CcsdkLightyUtils.stopLightyModule(netconfSouthboundPlugin)) {
            stopSuccessful = false;
        }

        if (!CcsdkLightyUtils.stopLightyModule(communityRestConf)) {
            stopSuccessful = false;
        }

        if (!CcsdkLightyUtils.stopLightyModule(lightyController)) {
            stopSuccessful = false;
        }

        return stopSuccessful;
    }

    private AaaEncryptServiceConfig createDefaultAaaEncryptServiceConfig() {
        return new AaaEncryptServiceConfigBuilder()
                .setEncryptKey("V1S1ED4OMeEh")
                .setPasswordLength(12)
                .setEncryptSalt("TdtWeHbch/7xP52/rp3Usw==")
                .setEncryptMethod("PBKDF2WithHmacSHA1")
                .setEncryptType("AES")
                .setEncryptIterationCount(32768)
                .setEncryptKeyLength(128)
                .setCipherTransforms("AES/CBC/PKCS5Padding")
                .build();
    }

}
