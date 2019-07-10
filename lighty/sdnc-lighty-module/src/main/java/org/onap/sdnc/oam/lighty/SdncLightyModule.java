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

import com.google.common.collect.ImmutableSet;
import io.lighty.core.controller.api.AbstractLightyModule;
import java.util.Optional;
import java.util.Set;
import org.onap.ccsdk.features.sdnr.northbound.oofpcipoc.lighty.OofpcipocModule;
import org.onap.ccsdk.features.sdnr.wt.lighty.SdnrWtModule;
import org.onap.ccsdk.sli.core.lighty.common.CcsdkLightyUtils;
import org.onap.ccsdk.sli.core.sli.provider.SvcLogicService;
import org.onap.sdnc.northbound.lighty.SdncNorthboundModule;
import org.opendaylight.controller.md.sal.binding.api.DataBroker;
import org.opendaylight.controller.md.sal.binding.api.MountPointService;
import org.opendaylight.controller.md.sal.binding.api.NotificationPublishService;
import org.opendaylight.controller.sal.binding.api.RpcProviderRegistry;
import org.opendaylight.mdsal.binding.api.RpcProviderService;
import org.opendaylight.mdsal.singleton.common.api.ClusterSingletonServiceProvider;
import org.opendaylight.yangtools.yang.binding.YangModuleInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The implementation of the {@link io.lighty.core.controller.api.LightyModule} that groups all other LightyModules
 * from the SDNC project so they can be all treated as one component (for example started/stopped at once).
 * For more information about the lighty.io visit the website https://lighty.io.
 */
public class SdncLightyModule extends AbstractLightyModule {

    private static final Logger LOG = LoggerFactory.getLogger(SdncLightyModule.class);

    public static final Set<YangModuleInfo> YANG_MODELS = ImmutableSet.of(
            org.opendaylight.yang.gen.v1.org.onap.ccsdk.features.sdnr.northbound.oofpcipoc.rev190308.$YangModuleInfoImpl.getInstance(),
            org.opendaylight.yang.gen.v1.org.onap.ccsdk.rev190308.$YangModuleInfoImpl.getInstance(),
            org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.devicemanager.rev190109.$YangModuleInfoImpl.getInstance(),
            org.opendaylight.yang.gen.v1.urn.ietf.params.xml.ns.yang.ietf.ptp.dataset.rev170208.$YangModuleInfoImpl.getInstance(),
            org.opendaylight.yang.gen.v1.urn.onf.otcc.wireless.yang.radio.access.rev180408.$YangModuleInfoImpl.getInstance(),
            org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.websocketmanager.rev150105.$YangModuleInfoImpl.getInstance(),
            org.opendaylight.yang.gen.v1.org.onap.sdnc.northbound.generic.resource.rev170824.$YangModuleInfoImpl.getInstance(),
            org.opendaylight.yang.gen.v1.org.onap.sdnctl.vnf.rev150720.$YangModuleInfoImpl.getInstance()
    );

    private final DataBroker dataBroker;
    private final RpcProviderRegistry rpcProviderRegistry;
    private final NotificationPublishService notificationPublishService;
    private final MountPointService mountPointService;
    private final ClusterSingletonServiceProvider clusteringSingletonService;
    private final SvcLogicService svcLogicService;
    private final RpcProviderService rpcProviderService;
    private final boolean startSdnr;

    private SdncNorthboundModule sdncNorthboundModule;

    private SdnrWtModule sdnrWtModule;
    private OofpcipocModule oofpcipocModule;

    public SdncLightyModule(DataBroker dataBroker, RpcProviderRegistry rpcProviderRegistry,
            NotificationPublishService notificationPublishService, MountPointService mountPointService,
            ClusterSingletonServiceProvider clusteringSingletonService, SvcLogicService svcLogicService,
            RpcProviderService rpcProviderService, boolean startSdnr) {
        this.dataBroker = dataBroker;
        this.rpcProviderRegistry = rpcProviderRegistry;
        this.notificationPublishService = notificationPublishService;
        this.mountPointService = mountPointService;
        this.clusteringSingletonService = clusteringSingletonService;
        this.svcLogicService = svcLogicService;
        this.rpcProviderService = rpcProviderService;
        this.startSdnr = startSdnr;
    }

    @Override
    protected boolean initProcedure() {
        LOG.debug("Initializing SDNC Lighty module...");

        this.sdncNorthboundModule = new SdncNorthboundModule(svcLogicService, dataBroker, notificationPublishService,
                rpcProviderRegistry);
        if (!CcsdkLightyUtils.startLightyModule(sdncNorthboundModule)) {
            return false;
        }

        if (startSdnr) {
            LOG.debug("Starting SNDR modules");
            this.sdnrWtModule =
                    new SdnrWtModule(dataBroker, rpcProviderRegistry, notificationPublishService, mountPointService,
                            clusteringSingletonService, rpcProviderService);
            if (!CcsdkLightyUtils.startLightyModule(sdnrWtModule)) {
                return false;
            }

            this.oofpcipocModule =
                    new OofpcipocModule(svcLogicService, dataBroker, notificationPublishService, rpcProviderRegistry);
            if (!CcsdkLightyUtils.startLightyModule(oofpcipocModule)) {
                return false;
            }
        }

        LOG.debug("SDNC Lighty module was initialized successfully");
        return true;
    }

    @Override
    protected boolean stopProcedure() {
        LOG.debug("Stopping SDNC Lighty module...");

        boolean stopSuccessful = true;

        if (startSdnr) {
            if (!CcsdkLightyUtils.stopLightyModule(oofpcipocModule)) {
                stopSuccessful = false;
            }

            if (!CcsdkLightyUtils.stopLightyModule(sdnrWtModule)) {
                stopSuccessful = false;
            }
        }

        if (!CcsdkLightyUtils.stopLightyModule(sdncNorthboundModule)) {
            stopSuccessful = false;
        }

        if (stopSuccessful) {
            LOG.debug("SDNC Lighty module was stopped successfully");
        } else {
            LOG.error("SDNC Lighty module was not stopped successfully!");
        }
        return stopSuccessful;
    }

    public SdncNorthboundModule getSdncNorthboundModule() {
        return sdncNorthboundModule;
    }

    public Optional<SdnrWtModule> getSdnrWtModule() {
        return Optional.ofNullable(sdnrWtModule);
    }

    public Optional<OofpcipocModule> getOofpcipocModule() {
        return Optional.ofNullable(oofpcipocModule);
    }
}
