package com.onap.sdnc.vnfbackupservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

import com.onap.sdnc.vnfbackupservice.model.VnfServiceResponse;
import com.onap.sdnc.vnfbackupservice.scheduler.VnfConfigBackupScheduler;
import com.onap.sdnc.vnfbackupservice.service.VnfbackupService;

@RestController
public class VnfBackupServiceController {

	@Autowired
	VnfbackupService vnfbackupService;
	
	@Autowired	
	VnfConfigBackupScheduler vnfConfigBackupScheduler;
	
	@RequestMapping("/")
	ModelAndView home(ModelAndView modelAndView) {
		modelAndView.setViewName("index");
		return modelAndView;
	}
	
	@RequestMapping(value="/getAllVnfIds", method=RequestMethod.GET,produces="application/json")
	public VnfServiceResponse  getAllVnfIds() {
		return vnfbackupService.getAllVnfDetails();
	}
	
	@RequestMapping(value="/backupVnfconfigById/{vnfId}", method=RequestMethod.GET)
	public String  getAllVnfIds(@PathVariable("vnfId") String vnfId) {
		return vnfbackupService.backupVnfconfig(vnfId);
		
	}
	
	@RequestMapping(value="/vnf-list/{vnf-Id}", method=RequestMethod.PUT)
	public String  putOneVnfconfig(@RequestBody String configfile, @PathVariable("vnf-Id") String vnfId) {
		System.out.println(configfile);
		String vnfconfigupdated = vnfbackupService.putVnfconfig(configfile,vnfId);
		
		return vnfconfigupdated;
	}
	
	@RequestMapping(value="/backup", method=RequestMethod.GET, produces="application/text")
	public String backupVnfConfigs() {
		
		return "current time:  " + vnfConfigBackupScheduler.initiateBackupService() ;
	}

	
	@RequestMapping(value="/backuptime", method=RequestMethod.GET, produces="application/text")
	public String lastUpdatedBackuptime() {
		
		return vnfbackupService.updatedBackuptime();
	}
}
