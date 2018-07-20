/*
* ============LICENSE_START=======================================================
* ONAP : SDNC-FEATURES
* ================================================================================
* Copyright 2018 TechMahindra
*=================================================================================
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
* ============LICENSE_END=========================================================
*/

package com.onap.sdnc.vnfconfigcomparsion.service;


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.mockito.Matchers.anyString;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.runners.MockitoJUnitRunner;

import com.onap.sdnc.vnfcomparsion.dao.VnfComparisonRepository;
import com.onap.sdnc.vnfconfigcomparsion.model.VnfCompareResponse;
import com.onap.sdnc.vnfconfigcomparsion.model.VnfConfigDetailsDB;
import com.onap.sdnc.vnfconfigcomparsion.model.VnfDetails;



@RunWith(MockitoJUnitRunner.class)
public class VnfComparisonServiceTest {

	@InjectMocks
	VnfComparisonService vnfComparisonService;
	
	@Mock
	VnfComparisonRepository vnfComparisonRepository;
	
	@Test
	public void testGetConfigurationDeatils_1() throws JSONException {
		VnfCompareResponse response = new VnfCompareResponse();
		String exampleJson = "{\"vnfname\":\"vnfversion\":[\"vnf1\",\"1.0\"]}";
		JSONObject vnfVersionNames = new JSONObject("{ \"versionNames\":[\"1.0\"]  }");
		String vnfId = "1a";
		List<VnfDetails> vnfDetailslist = new ArrayList<VnfDetails>();
		VnfDetails vnfdetails = new VnfDetails();
		JSONArray vnfIdArray = vnfVersionNames.getJSONArray("versionNames");
		VnfConfigDetailsDB value = new VnfConfigDetailsDB();
		value.setVnfid("1a");
		value.setConfiginfo(exampleJson);
		value.setId(1);
		value.setLastupdated("05-22-2018");
		value.setStatus("Y");
		value.setVnfname("vnf1");
		value.setVnfversion("1.0");

		//Mockito.when(vnfComparisonRepository.getVnfDetails(anyString(), anyString())).thenReturn(value);
		response.setVnfDetails(vnfDetailslist);
		response = vnfComparisonService.getConfigurationDeatils(vnfVersionNames, vnfId);
		assertEquals(value.getConfiginfo(), exampleJson);
		
	}
	
	@Test
	public void testGetConfigurationDeatils() throws Exception {
		VnfCompareResponse response = new VnfCompareResponse();
		String exampleJson = "{\"vnfname\":\"vnfversion\":[\"vnf1\",\"1.0\"]}";
		JSONObject vnfVersionNames = new JSONObject("{ \"versionNames\":[\"1.0\",\"2.0\"]  }");
		// String vnfversion = "{ \"versionNames\":[\"Version-1\"] }";
		String vnfId = "1a";
		List<VnfDetails> vnfDetailslist = new ArrayList<VnfDetails>();
		VnfDetails vnfdetails = new VnfDetails();
		JSONArray vnfIdArray = vnfVersionNames.getJSONArray("versionNames");
		VnfConfigDetailsDB value = new VnfConfigDetailsDB();
		value.setVnfid("1a");
		value.setConfiginfo(exampleJson);
		value.setId(1);
		value.setLastupdated("05-22-2018");
		value.setStatus("Y");
		value.setVnfname("vnf1");
		value.setVnfversion("1.0");

		Mockito.when(vnfComparisonRepository.getVnfDetails(anyString(), anyString())).thenReturn(value);
		response.setVnfDetails(vnfDetailslist);

		response = vnfComparisonService.getConfigurationDeatils(vnfVersionNames, vnfId);
		System.out.println(response);
		assertNotNull(response);
		assertEquals(value.getConfiginfo(), exampleJson);
		assertEquals(value.getVnfid(), vnfId);
		assertEquals(value.getStatus(), "Y");
	}
	
	@Test
	public void testgetConfigDeatilsByVnfIdVnfVersion() throws JSONException {
		VnfCompareResponse response = new VnfCompareResponse();
		String exampleJson = "{\"vnfname\":\"vnfversion\":[\"vnf1\",\"1.0\"]}";
		JSONObject vnfVersionNames = new JSONObject("{ \"versionNames\":[\"1.0\",\"2.0\"]  }");
		// String vnfversion = "{ \"versionNames\":[\"Version-1\"] }";
		String vnfId = "1a";
		List<VnfDetails> vnfDetailslist = new ArrayList<VnfDetails>();
		VnfDetails vnfdetails = new VnfDetails();
		JSONArray vnfIdArray = vnfVersionNames.getJSONArray("versionNames");
		VnfConfigDetailsDB value = new VnfConfigDetailsDB();
		value.setVnfid("1a");
		value.setConfiginfo(exampleJson);
		value.setId(1);
		value.setLastupdated("05-22-2018");
		value.setStatus("Y");
		value.setVnfname("vnf1");
		value.setVnfversion("1.0");

		Mockito.when(vnfComparisonRepository.getVnfDetails(anyString(), anyString())).thenReturn(value);
		response.setVnfDetails(vnfDetailslist);

		response = vnfComparisonService.getConfigDeatilsByVnfIdVnfVersion(vnfVersionNames, vnfId);
		System.out.println(response);
		assertNotNull(response);
		assertEquals(value.getConfiginfo(), exampleJson);
		assertEquals(value.getVnfid(), vnfId);
		assertEquals(value.getStatus(), "Y");
	}


}
