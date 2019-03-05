package org.onap.sdnc.oam.datamigrator.datamigrator;

import com.github.tomakehurst.wiremock.client.WireMock;
import com.github.tomakehurst.wiremock.junit.WireMockRule;
import org.junit.Rule;
import org.junit.Test;
import org.onap.sdnc.oam.datamigrator.common.Operation;
import org.onap.sdnc.oam.datamigrator.common.RestconfClient;
import org.onap.sdnc.oam.datamigrator.migrators.PreloadInformationMigrator;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;

public class PreloadInformationMigratorTest {

    @Rule
    public WireMockRule service1 = new WireMockRule(8081);

    @Rule
    public WireMockRule service2 = new WireMockRule(8082);
    PreloadInformationMigrator migrator = new PreloadInformationMigrator();
    private ClassLoader classLoader = getClass().getClassLoader();
    private  String preloadVnfResponseJson = new String(Files.readAllBytes(Paths.get(classLoader.getResource("wiremock/preloadVnfResponse.json").toURI())));
    private String preloadInformationRequestJson = new String(Files.readAllBytes(Paths.get(classLoader.getResource("wiremock/preloadInformationRequest.json").toURI())));

    public PreloadInformationMigratorTest() throws IOException, URISyntaxException {
    }

    @Test
    public void testRun (){
        service1.stubFor(WireMock.get(WireMock.urlEqualTo("/restconf/config/GENERIC-RESOURCE-API:preload-vnfs")).willReturn(
                WireMock.aResponse()
                        .withStatus(200)
                        .withBody(preloadVnfResponseJson)));
        service2.stubFor(WireMock.put(WireMock.urlEqualTo("/restconf/config/GENERIC-RESOURCE-API:preload-information")).withRequestBody(WireMock.equalTo(preloadInformationRequestJson)).willReturn(
                WireMock.aResponse()
                        .withStatus(200)));
        RestconfClient sourceClient = new RestconfClient("http://localhost:8081","admin","Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U");
        migrator.setSourceClient(sourceClient);
        RestconfClient targetClient = new RestconfClient("http://localhost:8082","admin","Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U");
        migrator.setTargetClient(targetClient);
        migrator.run(Operation.MIGRATE);
    }

    @Test
    public void testRunNoData (){
        service1.stubFor(WireMock.get(WireMock.urlEqualTo("/restconf/config/GENERIC-RESOURCE-API:preload-vnfs")).willReturn(
                WireMock.aResponse()
                        .withStatus(404)));
        service2.stubFor(WireMock.put(WireMock.urlEqualTo("/restconf/config/GENERIC-RESOURCE-API:preload-information")).withRequestBody(WireMock.equalTo(preloadInformationRequestJson)).willReturn(
                WireMock.aResponse()
                        .withStatus(200)));
        RestconfClient sourceClient = new RestconfClient("http://localhost:8081","admin","Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U");
        migrator.setSourceClient(sourceClient);
        RestconfClient targetClient = new RestconfClient("http://localhost:8082","admin","Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U");
        migrator.setTargetClient(targetClient);
        migrator.run(Operation.MIGRATE);
    }
}
