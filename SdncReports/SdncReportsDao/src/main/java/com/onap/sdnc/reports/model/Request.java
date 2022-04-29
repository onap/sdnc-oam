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
package com.onap.sdnc.reports.model;

public class Request {

	private VnfList[] vnfList;

	private ValidationTestType[] validationTestType;

	public VnfList[] getVnfList() {
		return vnfList;
	}

	public void setVnfList(VnfList[] vnfList) {
		this.vnfList = vnfList;
	}

	public ValidationTestType[] getValidationTestType() {
		return validationTestType;
	}

	public void setValidationTestType(ValidationTestType[] validationTestType) {
		this.validationTestType = validationTestType;
	}	
}