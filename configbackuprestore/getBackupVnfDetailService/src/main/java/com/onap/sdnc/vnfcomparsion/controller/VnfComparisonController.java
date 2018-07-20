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

package com.onap.sdnc.vnfcomparsion.controller;

import java.util.List;

import org.apache.log4j.Logger;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import com.onap.sdnc.vnfconfigcomparsion.model.VnfCompareResponse;
import com.onap.sdnc.vnfconfigcomparsion.model.VnfConfigDetailsDB;
import com.onap.sdnc.vnfconfigcomparsion.service.VnfComparisonService;


@RestController
public class VnfComparisonController {
	
	private static final Logger logger = Logger.getLogger(VnfComparisonController.class);

	@Autowired
	VnfComparisonService vnfComparisonService;
	
	
	@RequestMapping(value="/getAllBackupVnfIds", method=RequestMethod.GET,produces="application/json")
	public List<VnfConfigDetailsDB>  getAllBackupVnfIds() {
		return vnfComparisonService.getAllBackupVnfIds();
	}
	
	
	@RequestMapping(value="/configcomparison/{vnfid}", method = RequestMethod.POST,produces="application/json")
	public VnfCompareResponse configComparison(@RequestBody String versionNames,@PathVariable("vnfid") String vnfId) {
		VnfCompareResponse vnfCompareResponse = null;
		try {
			JSONObject versionId = new JSONObject(versionNames);
			vnfCompareResponse = vnfComparisonService.getConfigurationDeatils(versionId,vnfId);
		
	} catch (JSONException e1) {
		logger.error("exception occered"+e1);
	}
	
	return vnfCompareResponse;
}
	
	@RequestMapping(value="/configDetailsByIdVersion/{vnfid}", method = RequestMethod.POST,produces="application/json")
	public VnfCompareResponse getVnfDetailsOfVersionsAndVnfID(@RequestBody String versionNames,@PathVariable("vnfid") String vnfId) {
		VnfCompareResponse vnfCompareResponse = null;
		try {
			JSONObject versionId = new JSONObject(versionNames);
			vnfCompareResponse = vnfComparisonService.getConfigDeatilsByVnfIdVnfVersion(versionId,vnfId);
		
	} catch (JSONException e1) {
		logger.error("exception occered"+e1);
	}
	
	return vnfCompareResponse;
}
	
	@RequestMapping(value="/configDetailsById/{vnfid}", method = RequestMethod.GET,produces="application/json")
	public List<VnfConfigDetailsDB> getVnfDetailsOfVnfID(@PathVariable("vnfid") String vnfId) {
		List<VnfConfigDetailsDB> vnfConfigDetails = null;
		vnfConfigDetails = vnfComparisonService.getConfigurationDeatils(vnfId);
	return vnfConfigDetails;
}
}
