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

package com.onap.sdnc.vnfconfigcomparsion.model;

public class VnfDetails {

	private String vnfId;
	private String vnfDeatils;
	private String vnfversion;
	
	public String getVnfversion() {
		return vnfversion;
	}
	public void setVnfversion(String vnfversion) {
		this.vnfversion = vnfversion;
	}
	public String getVnfDeatils() {
		return vnfDeatils;
	}
	public void setVnfDeatils(String vnfDeatils) {
		this.vnfDeatils = vnfDeatils;
	}
	public String getVnfId() {
		return vnfId;
	}
	public void setVnfId(String vnfId) {
		this.vnfId = vnfId;
	}
}
