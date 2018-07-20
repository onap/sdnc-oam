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

import java.sql.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Lob;
import javax.persistence.Table;

@Entity
@Table(name = "vnfconfigdetails", schema = "testreports")
public class VnfConfigDetailsDB {

	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue
	private int id;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getVnfid() {
		return vnfid;
	}

	public void setVnfid(String vnfid) {
		this.vnfid = vnfid;
	}

	public String getVnfversion() {
		return vnfversion;
	}

	public void setVnfversion(String vnfversion) {
		this.vnfversion = vnfversion;
	}

	public String getVnfname() {
		return vnfname;
	}

	public void setVnfname(String vnfname) {
		this.vnfname = vnfname;
	}

	public String getConfiginfo() {
		return configinfo;
	}

	public void setConfiginfo(String configinfo) {
		this.configinfo = configinfo;
	}

	public Date getCreationdate() {
		return creationdate;
	}

	public void setCreationdate(Date creationdate) {
		this.creationdate = creationdate;
	}

	public String getLastupdated() {
		return lastupdated;
	}

	public void setLastupdated(String lastupdated) {
		this.lastupdated = lastupdated;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	@Column(name = "vnfid")
	private String vnfid;

	@Column(name = "vnfversion")
	private String vnfversion;

	@Column(name = "vnfname")
	private String vnfname;

	@Column(name = "configinfo")
	@Lob
	private String configinfo;

	@Column(name = "creationdate")
	private Date creationdate;

	@Column(name = "lastupdated")
	private String lastupdated;

	@Column(name = "status")
	private String status;
	

}
