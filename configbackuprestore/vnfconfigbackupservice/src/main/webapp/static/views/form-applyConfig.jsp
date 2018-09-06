<!-- /*
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
    -->
<div class="ReportMain" >
   <div class="heading"><img src="static/images/Apply.jpg" width=70 height="40"  style="margin-left:5px;">&nbsp;&nbsp;Apply Configruation</div>
   <form name="myForm" style="background-color:#f2f2f2; border: 1px solid #ddd;">
    <div growl></div>
    
      <div class="row" style="background-color:#f2f2f2;width:100%;margin-left:1px;height:75px">
         <div class="column" style="width:30%;background-color:#f2f2f2;height:55px;margin-left:40px;"> 
            <label class="labeltext">Select Avaliable VNF</label>
         </div>
         <div  class="column" style="background-color:#f2f2f2;width:60%;height:55px;margin-left:0px;">
            <select  class="form-control" style="width:100%;margin-top:0px;" ng-model="selectedValueVnf"  ng-change="selectVnf(selectedValueVnf)">
               <option  ng-repeat="vnf in objvnfList" value="{{vnf.vnfid}}">VnfId- {{vnf.vnfid}}&nbsp;VnfName- {{vnf.vnfname}}</option>
               <option  value="">Select VNFId</option>
            </select>
         </div>
      </div>
        <div class="row" style="background-color:#f2f2f2;width:100%;margin-left:1px;height:100px">  
        <div class="column" style="width:30%;height:55px;margin-left:35px;"> 
	<input type="file" style="width:300px" id="myFileInput" ng-model="file" accept=".json"/>
	</div>
 	<div class="column" style="width:50%;height:55px;margin-left:10px;"> 
 	<button type="submit" class="btnapply" ng-click="submit()">Apply Config</button>
   </div>
   </div>
    </form>
</div>
</body>
</html>