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

import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.onap.sdnc.vnfcomparsion.dao.VnfComparisonRepository;
import com.onap.sdnc.vnfconfigcomparsion.model.VnfCompareResponse;
import com.onap.sdnc.vnfconfigcomparsion.model.VnfConfigDetailsDB;
import com.onap.sdnc.vnfconfigcomparsion.model.VnfDetails;

@Service
public class VnfComparisonService {

	private static final Logger logger = LogManager.getLogger(VnfComparisonService.class);

	@Autowired
	VnfComparisonRepository vnfComparisonRepository;

	//Returns vnfconfig details if at list 2 or at most 4 versions selected.
	public VnfCompareResponse getConfigurationDeatils(JSONObject vnfVersionNames, String vnfId) {
		VnfCompareResponse vnfCompareResponse = new VnfCompareResponse();
		List<VnfDetails> vnfDetailsList = new ArrayList<VnfDetails>();
		VnfDetails vnfDetails = null;
		try {
			JSONArray vnfIdArray = vnfVersionNames.getJSONArray("versionNames");
			if (vnfIdArray.length() >= 2 && vnfIdArray.length() <= 4) {
				for (int i = 0; i < vnfIdArray.length(); i++) {
					
						VnfConfigDetailsDB vnfconfigdetails = vnfComparisonRepository
								.getVnfDetails(vnfIdArray.get(i).toString(), vnfId);
						vnfDetails = new VnfDetails();
						vnfDetails.setVnfDeatils(vnfconfigdetails.getConfiginfo());
						vnfDetails.setVnfId(vnfconfigdetails.getVnfid());
						vnfDetails.setVnfversion(vnfconfigdetails.getVnfversion());
						vnfDetailsList.add(vnfDetails);
						logger.debug("Versions : " + vnfIdArray.get(i));
				}
			}
		} catch (JSONException jSONException1) {
			
			logger.debug("JSONException occered " + jSONException1);
			
		}
		vnfCompareResponse.setVnfDetails(vnfDetailsList);
		return vnfCompareResponse;
	}

	//Returns vnfconfig details for any version.
	public VnfCompareResponse getConfigDeatilsByVnfIdVnfVersion(JSONObject vnfVersionNames, String vnfId) {
		VnfCompareResponse vnfCompareResponse = new VnfCompareResponse();
		List<VnfDetails> vnfDetailsList = new ArrayList<VnfDetails>();
		VnfDetails vnfDetails = null;
		try {
			JSONArray vnfIdArray = vnfVersionNames.getJSONArray("versionNames");
			for (int i = 0; i < vnfIdArray.length(); i++) {
				VnfConfigDetailsDB vnfconfigdetails = vnfComparisonRepository
						.getVnfDetails(vnfIdArray.get(i).toString(), vnfId);
				vnfDetails = new VnfDetails();
				vnfDetails.setVnfDeatils(vnfconfigdetails.getConfiginfo());
				vnfDetails.setVnfId(vnfconfigdetails.getVnfid());
				vnfDetails.setVnfversion(vnfconfigdetails.getVnfversion());
				vnfDetailsList.add(vnfDetails);
				logger.debug("Versions : " + vnfIdArray.get(i));
			}
		} catch (JSONException jSONException2) {

			logger.debug("JSONException occered " + jSONException2);
		}
		vnfCompareResponse.setVnfDetails(vnfDetailsList);
		return vnfCompareResponse;
	}
	
	//Returns backup vnf details according to vnf id.
	public List<VnfConfigDetailsDB> getConfigurationDeatils(String vnfId) {
		List<VnfConfigDetailsDB> vnfconfigdetails = vnfComparisonRepository.getVnfDetailsByVnfID(vnfId);
		return vnfconfigdetails;
	}

	//Returns all backup vnf details.
	public List<VnfConfigDetailsDB> getAllBackupVnfIds() {
		List<VnfConfigDetailsDB> vnfconfigdetails = vnfComparisonRepository.findvnfid();
		
		return vnfconfigdetails;
	}

}
