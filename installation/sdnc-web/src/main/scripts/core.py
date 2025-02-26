###
# ============LICENSE_START=======================================================
# ONAP : ccsdk distribution web
# ================================================================================
# Copyright (C) 2020 highstreet technologies GmbH Intellectual Property.
# All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=========================================================
###
import subprocess
import os
import json
import zipfile
import re
import uuid
import urllib3
import shutil
import re
import ssl
urllib3.disable_warnings()

APPLICATION_LISTFILE="/app/odlux.application.list"
INIT_FOLDER="/app/init.d"
ODLUX_BASE_FOLDER='/app/odlux'
INDEX_HTML=ODLUX_BASE_FOLDER+'/index.html'
INDEX_HTML_TEMPLATE=INDEX_HTML+'.template'
DEFAULT_APPLICATIONS=["connectApp" "faultApp" "maintenanceApp" "configurationApp" "performanceHistoryApp" "inventoryApp" "eventLogApp" "mediatorApp" "helpApp"]
http = urllib3.PoolManager(cert_reqs=ssl.CERT_NONE)
    
def exec(command):
    output = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE).stdout.read()
    return output
def execToStdOut(commandArray):
    process = subprocess.Popen(commandArray, shell=False)
    process.communicate()

def download(url, dst):
    print("downloading from {}...".format(url),end="")
    with open(dst, 'wb') as out_file:
        resp= http.request('GET',url, preload_content=False)
        shutil.copyfileobj(resp, out_file)
        resp.release_conn() 
    print("done")

def getEnv(key, defaultValue=None):
    x=os.getenv(key)
    return x if x is not None and len(x)>0 else defaultValue

def sedInFile(old, nu, fn):
    execToStdOut(['sed', '-i', 's|{}|{}|g'.format(old,nu),fn])

def add_application(name, index, file=None):
    apps = load_applications()
    if index==0:
        print("no index given. put it to last position")
        index=apps[len(apps)-1]['index']+10
    apps.append(dict(index=index,name=name))
    if file is not None and os.path.exists(file):
        extract(file)
    else:
        print('unable to find file {}'.format(file))
    write_applications(apps)
    print("{} installed on index {}".format(name, index)) 

def initial_load():
    files = os.listdir(INIT_FOLDER)
    regex = r"([0-9]+)([a-zA-Z]+)\.(jar|zip)"
    regexUrl = r"([0-9]+)([a-zA-Z]+)\.(url)"
    for file in files:
        matches = re.finditer(regex,file)
        match = next(matches, None)
        matchesUrl = re.finditer(regexUrl,file)
        matchUrl = next(matchesUrl, None)
        if match is not None:
            print("installing {}".format(file))
            index = int(match.group(1))
            name = match.group(2)
            add_application(name,index,INIT_FOLDER+'/'+file)
        elif matchUrl is not None:
            print("installing {}".format(file))
            index = int(match.group(1))
            name = match.group(2)
            add_application(name,index,INIT_FOLDER+'/'+file)
        else:
            print("no index naming format found. try to autodetect")
            infos = autoDetectInfosFromJar(file)
            if infos is None:
                print("unable to detect index and application name for {}".format(file))
            else:
               add_application(infos['name'],infos['index'],INIT_FOLDER+'/'+file) 



def containsBlueprintExpression(file) -> bool:
    print("check if file {} is blueprint".format(file))
    with open(file, 'r') as fp:
        lines = fp.readlines()
        for line in lines:
            if "<blueprint" in line:
                return True
        fp.close()
    return False

def findBlueprintXml(dir):
    result = [os.path.join(dp, f) for dp, dn, filenames in os.walk(dir) for f in filenames if os.path.splitext(f)[1] == '.xml']
    for file in result:
        if containsBlueprintExpression(file):
            return file
    return None

def autoDetectInfosFromJar(file):
    print("autodetect infos(appName and index) from jar {}".format(file))
    tmpDir=getRandomTempDir()
    regexBundleName = r"<property[\ ]+name=\"bundleName\"[\ ]+value=\"([^\"]+)\""
    regexIndex = r"<property[\ ]+name=\"index\"[\ ]+value=\"([^\"]+)\""
    name=None
    index=0
    with zipfile.ZipFile(file, 'r') as zip_ref:
        zip_ref.extractall(tmpDir)
        blueprint = findBlueprintXml(tmpDir)
        if blueprint is None:
            return None
        with open(blueprint) as fp:
            lines = fp.readlines()
            for line in lines:
                if name is None:
                    matches = re.finditer(regexBundleName, line)
                    match = next(matches,None)
                    if match is not None:
                        name = match.group(1)
                if index == 0:
                    matches = re.finditer(regexIndex, line)
                    match = next(matches,None)
                    if match is not None:
                        index = int(match.group(1))
       
            fp.close()
    print("found infos from jar: name={} index={}".format(name,index))
    return dict(index=index,name=name)
        
def getRandomTempDir(create=False):
    while(True):
        dir='/tmp/{}'.format(uuid.uuid4())
        if not os.path.exists(dir):
#            print("found random not-existing dir {}".format(dir))
            if create:
                os.makedirs(dir)
            return dir
#        print("dir {} already exists. try new".format(dir))
    return None

def getRandomTempFile():
    dir = getRandomTempDir(True)
    if dir is None:
        return None

    while True:
        file='{}/{}.dat'.format(dir,uuid.uuid4())
        if not os.path.exists(file):
#            print("found random not-existing file {}".format(file))
            return file
#        print("file {} already exists. try new".format(file))
    return None

def extract(fn):

    tmpDir=getRandomTempDir()  
    with zipfile.ZipFile(fn, 'r') as zip_ref:
        zip_ref.extractall(tmpDir)
        exec(" ".join(['cp','-r',tmpDir+'/odlux/*',ODLUX_BASE_FOLDER+'/']))
        zip_ref.close()


def load_applications():
    apps=[]
    if os.path.exists(APPLICATION_LISTFILE):
        with open(APPLICATION_LISTFILE,'r') as fp:
            lines= fp.readlines()
            for line in lines:
                if len(line.rstrip())<=0:
                    continue
                try:
                    hlp=line.split(' ')
                    apps.append(dict(index=int(hlp[0]),name=hlp[1].rstrip()))
                except:
                    print('problem reading line {}'.format(line))
            fp.close()
    else:
        index=10
        for app in DEFAULT_APPLICATIONS:
            apps.append(dict(index=index,name=app))
            index+=10
#    print('applications loaded={}'.format(apps))
    return sorted(apps, key=lambda d: d['index']) 
  
def write_applications(apps):
#    print('saving applications={}'.format(apps))
    apps = sorted(apps, key=lambda d: d['index'])
    os.remove(APPLICATION_LISTFILE)
    with open(APPLICATION_LISTFILE,'w') as fp:
        for app in apps:
            fp.write('{} {}\n'.format(app['index'], app['name']))
        fp.close()

def update_index_html(apps=None):
 
#     # Backup the index.html file
    if not os.path.exists(INDEX_HTML_TEMPLATE):
        execToStdOut(['cp',INDEX_HTML,INDEX_HTML_TEMPLATE])
    else:
        execToStdOut(['cp',INDEX_HTML_TEMPLATE,INDEX_HTML])
#     #default values
    if apps is None:
        apps=load_applications()
    ODLUX_AUTH_METHOD="basic"
    ENABLE_ODLUX_RBAC=getEnv('ENABLE_ODLUX_RBAC','false')
    TRPCEGUIURL=getEnv('TRPCEGUIURL')

    if getEnv('ENABLE_OAUTH') == "true":
        ODLUX_AUTH_METHOD="oauth"
    ODLUX_CONFIG=dict(authentication=ODLUX_AUTH_METHOD,enablePolicy=ENABLE_ODLUX_RBAC == 'true')
    print("authentication is {}".format(ODLUX_AUTH_METHOD))
    print("rbac access is enabled: {}".format(ENABLE_ODLUX_RBAC))
   
    if TRPCEGUIURL is not None:
        ODLUX_CONFIG['transportpceUrl']=TRPCEGUIURL
        print("trpce gui url is: {}".format(TRPCEGUIURL))

    requireArg=""
    fnArgs=""
    appCalls=""
    for app in apps:
        requireArg+='"{}",'.format(app['name'])
        fnArgs+='{},'.format(app['name'])
        appCalls+='{}.register();\\n'.format(app['name'])
    #replace require expression
    execToStdOut(['sed', '-z', 's/require(\["run"\],\ function\ (run)/require\(\[{}\"run\"\], function \({}run\)/'.format(requireArg,fnArgs), '-i', INDEX_HTML]) 
    #replace run.runApplication expression
    execToStdOut(['sed','-z', 's/run.runApplication();/{}run.runApplication();/'.format(appCalls), '-i',INDEX_HTML])
    #replace run.configure expression if exists
    execToStdOut(['sed', '-z', 's|run.configureApplication([^)]\+)|run.configureApplication({});|'.format(json.dumps(ODLUX_CONFIG)), '-i', INDEX_HTML]) 
  

def check_for_rule_template():
    if os.path.exists('/opt/bitnami/nginx/conf/server_blocks/location.rules.tmpl'):
        print("using template for forwarding rules")
        execToStdOut(['cp','/opt/bitnami/nginx/conf/server_blocks/location.rules.tmpl','/opt/bitnami/nginx/conf/server_blocks/location.rules'])

def update_nginx_site_conf():
    FN=None
    if getEnv('WEBPROTOCOL') == "HTTPS":
        FN='/opt/bitnami/nginx/conf/server_blocks/https_site.conf'
        execToStdOut(['rm', '/opt/bitnami/nginx/conf/server_blocks/http_site.conf'])
        SSL_CERT_DIR=getEnv('SSL_CERT_DIR')
        SSL_CERTIFICATE=getEnv('SSL_CERTIFICATE')
        SSL_CERTIFICATE_KEY=getEnv('SSL_CERTIFICATE_KEY')
        sedInFile('SSL_CERTIFICATE_KEY',SSL_CERTIFICATE_KEY,FN)
        sedInFile('SSL_CERT_DIR',SSL_CERT_DIR,FN)
        sedInFile('SSL_CERTIFICATE',SSL_CERTIFICATE, FN)
        
    elif getEnv('WEBPROTOCOL') == "HTTP":
        FN='/opt/bitnami/nginx/conf/server_blocks/http_site.conf'
        execToStdOut(['rm', '/opt/bitnami/nginx/conf/server_blocks/https_site.conf'])

    WEBPROTOCOL=getEnv('WEBPROTOCOL')
    WEBPORT=getEnv('WEBPORT')
    SDNRPROTOCOL=getEnv('SDNRPROTOCOL')
    SDNRHOST=getEnv('SDNRHOST')
    SDNRPORT=getEnv('SDNRPORT')
    SDNRWEBSOCKETPORT=getEnv('SDNRWEBSOCKETPORT',SDNRPORT)
    DNS_RESOLVER=getEnv('DNS_RESOLVER')
    DNS_INTERNAL_RESOLVER=getEnv('DNS_INTERNAL_RESOLVER')
    if FN is None:
        print("unknown env WEBPROTOCOL: {}".format(WEBPROTOCOL))
        exit(1)
    
    # replace needed base parameters
    sedInFile('WEBPORT',WEBPORT,FN)

    FN='/opt/bitnami/nginx/conf/server_blocks/location.rules'
    # replace needed parameters in forwarding rules
    sedInFile('WEBPORT',WEBPORT,FN)
    sedInFile('SDNRPROTOCOL',SDNRPROTOCOL,FN)
    sedInFile('SDNRHOST',SDNRHOST ,FN)
    sedInFile('SDNRPORT',SDNRPORT,FN)
    sedInFile('SDNRWEBSOCKETPORT',SDNRWEBSOCKETPORT, FN)
    sedInFile('DNS_RESOLVER',DNS_RESOLVER ,FN)
    sedInFile('DNS_INTERNAL_RESOLVER',DNS_INTERNAL_RESOLVER ,FN)

    TRPCEURL=getEnv('TRPCEURL')
    TOPOURL=getEnv('TOPOURL')
    SITEDOCURL=getEnv('SITEDOCURL')
    TILEURL=getEnv('TILEURL')
    DATAPROVIDERURL=getEnv('DATAPROVIDERURL')
    TERRAINURL=getEnv('TERRAINURL')
    ELECTROMAGNETICFIELDURL=getEnv('ELECTROMAGNETICFIELDURL')
    ELECTROMAGNETICFIELDBAUTHTOKEN=getEnv('ELECTROMAGNETICFIELDBAUTHTOKEN')
    # handle optional parameters
    if TRPCEURL is None:
        print("transportPCE forwarding disabled")
        sedInFile('proxy_pass TRPCEURL/$1;','return 404;',FN)
    else:
        sedInFile('TRPCEURL',TRPCEURL ,FN)

    if TOPOURL is None:
        print("topology api forwarding disabled")
        sedInFile('proxy_pass TOPOURL;','return 404;',FN)
    else:
        sedInFile('TOPOURL',TOPOURL ,FN)
    
    if SITEDOCURL is None:
        print("sitedoc api forwarding disabled")
        sedInFile('proxy_pass SITEDOCURL/topology/stadok/$1;','return 404;', FN)
    else:
        sedInFile('SITEDOCURL',SITEDOCURL, FN)
    
    if TILEURL is None:
        print("tile server forwarding disabled")
        sedInFile('proxy_pass TILEURL/$1;','return 404;',FN)
    else:
        sedInFile('TILEURL',TILEURL ,FN)
    
    if DATAPROVIDERURL is None:
        print("data provider forwarding disabled")
        sedInFile('proxy_pass DATAPROVIDERURL/$1;','return 404;',FN)
    else:
        sedInFile('DATAPROVIDERURL',DATAPROVIDERURL ,FN)
    
    if TERRAINURL is None:
        print("terrain server forwarding disabled")
        sedInFile('proxy_pass TERRAINURL/$1;','return 404;',FN)
    else:
        sedInFile('TERRAINURL',TERRAINURL ,FN)
        
    if ELECTROMAGNETICFIELDURL is None:
        print("electromagnetic-field server forwarding disabled")
        sedInFile('proxy_pass ELECTROMAGNETICFIELDURL/$1;','return 404;',FN)
    else:
        sedInFile('ELECTROMAGNETICFIELDURL',ELECTROMAGNETICFIELDURL ,FN)
        sedInFile('ELECTROMAGNETICFIELDBAUTHTOKEN',ELECTROMAGNETICFIELDBAUTHTOKEN ,FN)       
