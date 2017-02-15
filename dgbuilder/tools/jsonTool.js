var obj={};
function dotToJson(str,value,obj){
    //var objArr = path.split("."), part;
    var objArr = str.split(".");
	var prevStr;
	var currObj;
	var prevObj;
	//console.log(str);
	var isArray = false;
	var prevObjIsArray = false;
	for(var i=0;i<objArr.length -1;i++){
		var subStr= objArr[i] ;
		if(isArray){
			prevObjIsArray = true;	
		}
		isArray = false;
		if(subStr.indexOf(']') == subStr.length -1){
			subStr = subStr.substring(0,subStr.length -2);
			isArray = true;
		}
		//console.log("subStr:" + subStr + isArray);
		//console.dir(prevObj);
		if(isArray){
			if(i==0 && obj[subStr] == undefined ){
				//console.log("i==0 && obj[subStr] ");
				obj[subStr]=[];
			}else if(i==0 && obj[subStr][0] == undefined ){
						obj[subStr][0]={};
			}else if(i==0 && obj[subStr][0] != undefined ){
				currObj= obj[subStr][0];
			}else{
				if(i == 1){
					//console.log("i==1 && obj[prevStr] ");
	 				prevObj=obj[prevStr];
					if(prevObj[subStr][0] == undefined){
						prevObj[subStr] = [];
						prevObj[subStr][0] = {};
						currObj = prevObj[subStr][0];
					}else{
						currObj = prevObj[subStr][0];
					}
				}else{
					if(prevObj[subStr] == undefined){
						prevObj[subStr]=[];
						prevObj[subStr][0]={};
						currObj = prevObj[subStr][0];
					}else{
						currObj = prevObj[subStr][0];
					}
				}
			}
		}else{
			if(i==0 && obj[subStr] == undefined ){
				obj[subStr] = {};
				currObj= obj[subStr];
			}else if(i==0 && obj[subStr] != undefined ){
				currObj=obj[subStr];
			//console.log("in gkjgjkg");
			}else{
				if(i == 1){
	 				prevObj=obj[prevStr];
					if(prevObj[subStr] == undefined){
						prevObj[subStr] = {};
						currObj = prevObj[subStr];
					}else{
						currObj = prevObj[subStr];
					}
				}else{
					if(prevObj[subStr] == undefined){
						prevObj[subStr] = {};
						currObj = prevObj[subStr];
					}else{
						currObj = prevObj[subStr];
					}
				}
			}
		}
		prevStr=subStr;
		if(i <objArr.length-2){
			//console.dir(currObj);
			prevObj=currObj;	
		}
	}
	var lastStr = objArr[objArr.length-1];
	if(isArray){
		currObj[lastStr] = value;
	}else{
		currObj[lastStr] = value;
	}
	//prevObj[lastStr] = value;
	//console.dir(currObj);
	return obj;
}
function printObj(obj){
for( j in obj){
	console.log(j + ":" + obj[j]);
	if(typeof obj[j] == "object" ){
		printObj(obj[j]);
	}

}
}

a=[
'service-configuration-operation-input.service-information.service-instance-id',
'service-configuration-operation-input.service-information.subscriber-name',
'service-configuration-operation-input.service-information.service-type',
'service-configuration-operation-input.svc-config-additional-data.management-ip',
'service-configuration-operation-input.sdnc-request-header.svc-request-id',
'service-configuration-operation-input.sdnc-request-header.svc-notification-url',
'service-configuration-operation-input.sdnc-request-header.svc-action',
'service-configuration-operation-input.vr-lan.routing-protocol',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-vr-lan-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].vr-designation',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-vr-lan-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-vr-lan-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-vr-lan-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].t-defaulted-v6-vrlan',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-vce-loopback-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-vce-wan-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-dhcp-server-enabled',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-dhcp-server-enabled',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].use-v4-default-pool',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-dhcp-default-pool-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-dhcp-default-pool-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].excluded-v4-dhcp-addresses-from-default-pool[].excluded-v4-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].excluded-v4-dhcp-addresses-from-default-pool[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].use-v6-default-pool',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-dhcp-default-pool-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-dhcp-default-pool-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].excluded-v6-dhcp-addresses-from-default-pool[].excluded-v6-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].excluded-v6-dhcp-addresses-from-default-pool[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-dhcp-pools[].v6-dhcp-pool-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-dhcp-pools[].v6-dhcp-pool-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-dhcp-pools[].v6-dhcp-relay-gateway-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-dhcp-pools[].v6-dhcp-relay-next-hop-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-dhcp-pools[].excluded-v6-addresses[].excluded-v6-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-dhcp-pools[].excluded-v6-addresses[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-dhcp-pools[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-dhcp-pools[].v4-dhcp-relay-next-hop-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-dhcp-pools[].v4-dhcp-pool-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-dhcp-pools[].v4-dhcp-pool-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-dhcp-pools[].v4-dhcp-relay-gateway-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-dhcp-pools[].excluded-v4-addresses[].excluded-v4-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-dhcp-pools[].excluded-v4-addresses[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-dhcp-pools[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-nat-enabled',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-nat-mapping-entries[].v4-nat-internal',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-nat-mapping-entries[].v4-nat-next-hop-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-nat-mapping-entries[].v4-nat-external',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-nat-mapping-entries[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].t-provided-v6-lan-public-prefixes[].request-index',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].t-provided-v6-lan-public-prefixes[].v6-next-hop-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].t-provided-v6-lan-public-prefixes[].v6-lan-public-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].t-provided-v6-lan-public-prefixes[].v6-lan-public-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].t-provided-v6-lan-public-prefixes[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].t-provided-v4-lan-public-prefixes[].request-index',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].t-provided-v4-lan-public-prefixes[].v4-lan-public-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].t-provided-v4-lan-public-prefixes[].v4-next-hop-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].t-provided-v4-lan-public-prefixes[].v4-lan-public-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].t-provided-v4-lan-public-prefixes[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-static-routes[].v6-static-route-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-static-routes[].v6-next-hop-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-static-routes[].v6-static-route-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-static-routes[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-static-routes[].v4-static-route-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-static-routes[].v4-next-hop-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-static-routes[].v4-static-route-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-static-routes[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-pat-enabled',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-pat-default-pool-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].use-v4-default-pool',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-pat-default-pool-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-pat-pools[].v4-pat-pool-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-pat-pools[].v4-pat-pool-next-hop-address',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-pat-pools[].v4-pat-pool-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-pat-pools[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-firewall-packet-filters[].v6-firewall-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-firewall-packet-filters[].v6-firewall-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-firewall-packet-filters[].allow-icmp-ping',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-firewall-packet-filters[].udp-port-list[].port-number',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-firewall-packet-filters[].udp-port-list[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-firewall-packet-filters[].tcp-port-list[].port-number',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-firewall-packet-filters[].tcp-port-list[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v6-firewall-packet-filters[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].stateful-firewall-lite-v4-enabled',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].stateful-firewall-lite-v6-enabled',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-firewall-packet-filters[].allow-icmp-ping',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-firewall-packet-filters[].udp-port-list[].port-number',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-firewall-packet-filters[].udp-port-list[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-firewall-packet-filters[].tcp-port-list[].port-number',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-firewall-packet-filters[].tcp-port-list[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-firewall-packet-filters[].v4-firewall-prefix',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-firewall-packet-filters[].v4-firewall-prefix-length',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].v4-firewall-packet-filters[].key',
'service-configuration-operation-input.vr-lan.vr-lan-interface[].key',
'service-configuration-operation-input.internet-evc-access-information.internet-evc-speed-value',
'service-configuration-operation-input.internet-evc-access-information.ip-version',
'service-configuration-operation-input.internet-evc-access-information.internet-evc-speed-units',
'service-configuration-operation-input.l2-homing-information.preferred-aic-clli',
'service-configuration-operation-input.l2-homing-information.evc-name',
'service-configuration-operation-input.l2-homing-information.topology',
'service-configuration-operation-input.internet-service-change-details.internet-evc-speed-value',
'service-configuration-operation-input.internet-service-change-details.internet-evc-speed-units',
'service-configuration-operation-input.internet-service-change-details.t-provided-v4-lan-public-prefixes[].request-index',
'service-configuration-operation-input.internet-service-change-details.t-provided-v4-lan-public-prefixes[].v4-lan-public-prefix',
'service-configuration-operation-input.internet-service-change-details.t-provided-v4-lan-public-prefixes[].v4-lan-public-prefix-length',
'service-configuration-operation-input.internet-service-change-details.t-provided-v4-lan-public-prefixes[].key',
'service-configuration-operation-input.internet-service-change-details.t-provided-v6-lan-public-prefixes[].request-index',
'service-configuration-operation-input.internet-service-change-details.t-provided-v6-lan-public-prefixes[].v6-lan-public-prefix',
'service-configuration-operation-input.internet-service-change-details.t-provided-v6-lan-public-prefixes[].v6-lan-public-prefix-length',
'service-configuration-operation-input.internet-service-change-details.t-provided-v6-lan-public-prefixes[].key'
];

a=[
    "service-configuration-operation-input.sdnc-request-header.svc-notification-url",
    "service-configuration-operation-input.sdnc-request-header.svc-request-id",
    "service-configuration-operation-input.sdnc-request-header.svc-action",
    "service-configuration-operation-input.vpe-vpn-service.route-target",
    "service-configuration-operation-input.vpe-vpn-service.e2e-vpn-key",
    "service-configuration-operation-input.vpe-vpn-service.vpn-id",
    "service-configuration-operation-input.vpe-vpn-service.vpn-vame",
    "service-configuration-operation-input.vpe-vpn-service.spoke-routes.route-target",
    "service-configuration-operation-input.vpe-vpn-service.spoke-routes.max-threshold",
    "service-configuration-operation-input.vpe-vpn-service.spoke-routes.max-routes-limit",
    "service-configuration-operation-input.vpe-vpn-service.v4-max-routes.max-routes-limit-warning",
    "service-configuration-operation-input.vpe-vpn-service.v4-max-routes.max-routes-limit",
    "service-configuration-operation-input.vpe-vpn-service.v6-max-routes.max-routes-limit-warning",
    "service-configuration-operation-input.vpe-vpn-service.v6-max-routes.max-routes-limit",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.vpn-multicast-planned-region[].regions",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.vpn-multicast-planned-region[].key",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.vpn-v4-multicast-enabled",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.max-routes-limit-warning",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.max-routes-limit",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-data-mdt",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-static-rp-triplet[].rp-address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-static-rp-triplet[].c-groups[].group-address-prefix-length",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-static-rp-triplet[].c-groups[].c-group-address-prefix",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-static-rp-triplet[].c-groups[].key",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-static-rp-triplet[].key",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-pim-sm-static-override",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-pim-ssm-default-range",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-pim-ssm-groups[].v4-pim-ssm-group-address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-pim-ssm-groups[].v4-pim-ssm-group-address-prefix-length",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-pim-ssm-groups[].key",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-default-mdt",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-data-mdt-wildcard-mask",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.vpn-v6-multicast-enabled",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.max-routes-limit-warning",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.max-routes-limit",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-static-rp-triplet[].rp-address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-static-rp-triplet[].c-groups[].group-address-prefix-length",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-static-rp-triplet[].c-groups[].c-group-address-prefix",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-static-rp-triplet[].c-groups[].key",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-static-rp-triplet[].key",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-pim-sm-static-override",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-pim-ssm-default-range",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-pim-ssm-groups[].v6-pim-ssm-group-address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-pim-ssm-groups[].v6-pim-ssm-group-address-prefix-length",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-pim-ssm-groups[].key",
    "service-configuration-operation-input.vpe-vpn-service.customer-id",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].router-distinguisher",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vpe-name",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vrf-import-details[].vrf-import",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vrf-import-details[].key",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].member",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].name",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vrf-name",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vrf-export-details[].vrf-export",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vrf-export-details[].key",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].apply-group-template[].apply-group",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].apply-group-template[].key",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].key",
    "service-configuration-operation-input.service-information.subscriber-name",
    "service-configuration-operation-input.service-information.subscriber-global-id",
    "service-configuration-operation-input.service-information.service-type",
    "service-configuration-operation-input.service-information.service-instance-id",
    "service-configuration-operation-input.request-information.notification-url",
    "service-configuration-operation-input.request-information.order-number",
    "service-configuration-operation-input.request-information.order-version",
    "service-configuration-operation-input.request-information.request-action",
    "service-configuration-operation-input.request-information.request-sub-action",
    "service-configuration-operation-input.request-information.source",
    "service-configuration-operation-input.request-information.request-id",
    "service-configuration-operation-output.configuration-response-common.svc-request-id",
    "service-configuration-operation-output.configuration-response-common.response-message",
    "service-configuration-operation-output.configuration-response-common.ack-final-indicator",
    "service-configuration-operation-output.configuration-response-common.response-code"
];
var nObj={};
for(var i=0;i<a.length;i++){
	dotToJson(a[i],'',nObj);
}
var a = [
    "service-configuration-operation-input.sdnc-request-header.svc-notification-url:String",
    "service-configuration-operation-input.sdnc-request-header.svc-request-id:String",
    "service-configuration-operation-input.sdnc-request-header.svc-action:Enum:[Createupdatevpn]",
    "service-configuration-operation-input.vpe-vpn-service.route-target:String",
    "service-configuration-operation-input.vpe-vpn-service.e2e-vpn-key:String",
    "service-configuration-operation-input.vpe-vpn-service.vpn-id:Integer",
    "service-configuration-operation-input.vpe-vpn-service.vpn-vame:String",
    "service-configuration-operation-input.vpe-vpn-service.spoke-routes.route-target:String",
    "service-configuration-operation-input.vpe-vpn-service.spoke-routes.max-threshold:Short",
    "service-configuration-operation-input.vpe-vpn-service.spoke-routes.max-routes-limit:BigInteger",
    "service-configuration-operation-input.vpe-vpn-service.v4-max-routes.max-routes-limit-warning:Short",
    "service-configuration-operation-input.vpe-vpn-service.v4-max-routes.max-routes-limit:BigInteger",
    "service-configuration-operation-input.vpe-vpn-service.v6-max-routes.max-routes-limit-warning:Short",
    "service-configuration-operation-input.vpe-vpn-service.v6-max-routes.max-routes-limit:BigInteger",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.vpn-multicast-planned-region[].regions:Enum:[EMEA, US, AP, LA, Canada]",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.vpn-multicast-planned-region[].key:Identifier",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.vpn-v4-multicast-enabled:Enum:[Y, N]",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.max-routes-limit-warning:Short",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.max-routes-limit:BigInteger",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-data-mdt:Ipv4Address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-static-rp-triplet[].rp-address:Ipv4Address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-static-rp-triplet[].c-groups[].group-address-prefix-length:Short",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-static-rp-triplet[].c-groups[].c-group-address-prefix:Ipv4Address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-static-rp-triplet[].c-groups[].key:Identifier",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-static-rp-triplet[].key:Identifier",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-pim-sm-static-override:Enum:[Y, N]",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-pim-ssm-default-range:Enum:[Y, N]",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-pim-ssm-groups[].v4-pim-ssm-group-address:Ipv4Address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-pim-ssm-groups[].v4-pim-ssm-group-address-prefix-length:Short",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-pim-ssm-groups[].key:Identifier",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-default-mdt:Ipv4Address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v4-multicast.v4-data-mdt-wildcard-mask:Ipv4Address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.vpn-v6-multicast-enabled:Enum:[Y, N]",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.max-routes-limit-warning:Short",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.max-routes-limit:BigInteger",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-static-rp-triplet[].rp-address:Ipv6Address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-static-rp-triplet[].c-groups[].group-address-prefix-length:Short",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-static-rp-triplet[].c-groups[].c-group-address-prefix:Ipv6Address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-static-rp-triplet[].c-groups[].key:Identifier",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-static-rp-triplet[].key:Identifier",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-pim-sm-static-override:Enum:[Y, N]",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-pim-ssm-default-range:Enum:[Y, N]",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-pim-ssm-groups[].v6-pim-ssm-group-address:Ipv6Address",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-pim-ssm-groups[].v6-pim-ssm-group-address-prefix-length:Short",
    "service-configuration-operation-input.vpe-vpn-service.multicast-parameters.v6-multicast.v6-pim-ssm-groups[].key:Identifier",
    "service-configuration-operation-input.vpe-vpn-service.customer-id:String",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].router-distinguisher:String",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vpe-name:String",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vrf-import-details[].vrf-import:String",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vrf-import-details[].key:Identifier",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].member:String",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].name:String",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vrf-name:String",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vrf-export-details[].vrf-export:String",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].vrf-export-details[].key:Identifier",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].apply-group-template[].apply-group:String",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].apply-group-template[].key:Identifier",
    "service-configuration-operation-input.vpe-vpn-service.vrf-details[].key:Identifier",
    "service-configuration-operation-input.service-information.subscriber-name:String",
    "service-configuration-operation-input.service-information.subscriber-global-id:String",
    "service-configuration-operation-input.service-information.service-type:Enum:[NBIPVPN]",
    "service-configuration-operation-input.service-information.service-instance-id:String",
    "service-configuration-operation-input.request-information.notification-url:String",
    "service-configuration-operation-input.request-information.order-number:String",
    "service-configuration-operation-input.request-information.order-version:String",
    "service-configuration-operation-input.request-information.request-action:Enum:[Layer3ServiceVPNRequest]",
    "service-configuration-operation-input.request-information.request-sub-action:Enum:[ACTIVATE, COMPLETE, CANCEL, SUPP]",
    "service-configuration-operation-input.request-information.source:String",
    "service-configuration-operation-input.request-information.request-id:String"
]
var nObj={};
for(var i=0;i<a.length;i++){
	var key =a[i].substring(0,a[i].indexOf(':'));
	console.log(key);
	var value =a[i].substring(a[i].indexOf(':') +1);
	if(value == undefined) value ="";
	dotToJson(key,value,nObj);
}
//nObj={};,
//var a1='service-configuration-operation-input[].vr-lan.vr-lan-interface[].v4-firewall-packet-filters[].v4-firewall-prefix-length';,
	//dotToJson(a1,'',nObj);
console.log(JSON.stringify(nObj,null,4));
//console.log (stringToObj('abc.ebg.h',"",{}));
