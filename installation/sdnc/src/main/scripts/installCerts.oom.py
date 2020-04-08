# ============LICENSE_START=======================================================
#  Copyright (C) 2019 Nordix Foundation.
# ================================================================================
#  extended by highstreet technologies GmbH (c) 2020
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
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================
#


# coding=utf-8
import os
import httplib
import base64
import time
import zipfile
import shutil
import subprocess
import logging

odl_home = os.environ['ODL_HOME']
log_directory = odl_home + '/data/log/'
log_file = log_directory + 'installCerts.log'
log_format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
if not os.path.exists(log_directory):
    os.makedirs(log_directory)
logging.basicConfig(filename=log_file,level=logging.DEBUG,filemode='w',format=log_format)
print 'Start cert provisioning. Log file: ' + log_file;

Path = os.environ['ODL_CERT_DIR']

zipFileList = []

username = os.environ['ODL_ADMIN_USERNAME']
password = os.environ['ODL_ADMIN_PASSWORD']
TIMEOUT=1000
INTERVAL=30
timePassed=0

postKeystore= "/restconf/operations/netconf-keystore:add-keystore-entry"
postPrivateKey= "/restconf/operations/netconf-keystore:add-private-key"
postTrustedCertificate= "/restconf/operations/netconf-keystore:add-trusted-certificate"

envOdlFeaturesBoot='ODL_FEATURES_BOOT'
# Strategy sli-api is default
certreadyCmd="POST"
certreadyUrl="/restconf/operations/SLI-API:healthcheck"
odlFeaturesBoot=os.environ.get(envOdlFeaturesBoot)
if odlFeaturesBoot is not None:
    odlFeaturesBoot=odlFeaturesBoot.lower()
    if 'odl-netconf-topology' in odlFeaturesBoot or 'odl-netconf-clustered-topology' in odlFeaturesBoot:
        certreadyCmd="GET"
        certreadyUrl="/restconf/operational/network-topology:network-topology"
logging.info('ODL ready strategy with command %s and url %s', certreadyCmd, certreadyUrl)

cadi_file = '.pass'
odl_port = 8181
headers = {'Authorization':'Basic %s' % base64.b64encode(username + ":" + password),
           'X-FromAppId': 'csit-sdnc',
           'X-TransactionId': 'csit-sdnc',
           'Accept':"application/json",
           'Content-type':"application/json"}

def readFile(folder, file):
    key = open(Path + "/" + folder + "/" + file, "r")
    fileRead = key.read()
    key.close()
    fileRead = "\n".join(fileRead.splitlines()[1:-1])
    return fileRead

def readTrustedCertificate(folder, file):
    listCert = list()
    caPem = ""
    startCa = False
    key = open(folder + "/" + file, "r")
    lines = key.readlines()
    for line in lines:
        if not "BEGIN CERTIFICATE" in line and not "END CERTIFICATE" in line and startCa:
            caPem += line
        elif "BEGIN CERTIFICATE" in line:
            startCa = True
        elif "END CERTIFICATE" in line:
            startCa = False
            listCert.append(caPem)
            caPem = ""
    return listCert

def makeKeystoreKey(clientKey, count):
    odl_private_key="ODL_private_key_%d" %count

    json_keystore_key='{{\"input\": {{ \"key-credential\": {{\"key-id\": \"{odl_private_key}\", \"private-key\" : ' \
                      '\"{clientKey}\",\"passphrase\" : \"\"}}}}}}'.format(
        odl_private_key=odl_private_key,
        clientKey=clientKey)

    return json_keystore_key



def makePrivateKey(clientKey, clientCrt, certList, count):
    caPem = ""
    if certList:
        for cert in certList:
            caPem += '\"%s\",' % cert
        caPem = caPem.rsplit(',', 1)[0]
    odl_private_key="ODL_private_key_%d" %count

    json_private_key='{{\"input\": {{ \"private-key\":{{\"name\": \"{odl_private_key}\", \"data\" : ' \
                     '\"{clientKey}\",\"certificate-chain\":[\"{clientCrt}\",{caPem}]}}}}}}'.format(
        odl_private_key=odl_private_key,
        clientKey=clientKey,
        clientCrt=clientCrt,
        caPem=caPem)

    return json_private_key

def makeTrustedCertificate(certList, count):
    number = 0
    json_cert_format = ""
    for cert in certList:
        cert_name = "xNF_CA_certificate_%d_%d" %(count, number)
        json_cert_format += '{{\"name\": \"{trusted_name}\",\"certificate\":\"{cert}\"}},\n'.format(
            trusted_name=cert_name,
            cert=cert.strip())
        number += 1

    json_cert_format = json_cert_format.rsplit(',', 1)[0]
    json_trusted_cert='{{\"input\": {{ \"trusted-certificate\": [{certificates}]}}}}'.format(
        certificates=json_cert_format)
    return json_trusted_cert


def makeRestconfPost(conn, json_file, apiCall):
    req = conn.request("POST", apiCall, json_file, headers=headers)
    res = conn.getresponse()
    res.read()
    if res.status != 200:
        logging.error("Error here, response back wasnt 200: Response was : %d , %s" % (res.status, res.reason))
    else:
        logging.debug("Response :%s Reason :%s ",res.status, res.reason)

def extractZipFiles(zipFileList, count):
    for zipFolder in zipFileList:
        with zipfile.ZipFile(Path + "/" + zipFolder.strip(),"r") as zip_ref:
            zip_ref.extractall(Path)
        folder = zipFolder.rsplit(".")[0]
        processFiles(folder, count)

def processFiles(folder, count):
    logging.info('Process folder: %d %s', count, folder)
    for file in os.listdir(Path + "/" + folder):
        if os.path.isfile(Path + "/" + folder + "/" + file.strip()):
            if ".key" in file:
                clientKey = readFile(folder, file.strip())
            elif "trustedCertificate" in file:
                certList = readTrustedCertificate(Path + "/" + folder, file.strip())
            elif ".crt" in file:
                clientCrt = readFile(folder, file.strip())
        else:
            logging.error("Could not find file %s" % file.strip())
    shutil.rmtree(Path + "/" + folder)
    post_content(clientKey, clientCrt, certList, count)

def post_content(clientKey, clientCrt, certList, count):
    logging.info('Post content: %d', count)
    conn = httplib.HTTPConnection("localhost",odl_port)
    if clientKey:
        json_keystore_key = makeKeystoreKey(clientKey, count)
        logging.debug("Posting private key in to ODL keystore")
        makeRestconfPost(conn, json_keystore_key, postKeystore)

    if certList:
        json_trusted_cert = makeTrustedCertificate(certList, count)
        logging.debug("Posting trusted cert list in to ODL")
        makeRestconfPost(conn, json_trusted_cert, postTrustedCertificate)

    if clientKey and clientCrt and certList:
        json_private_key = makePrivateKey(clientKey, clientCrt, certList, count)
        logging.debug("Posting the cert in to ODL")
        makeRestconfPost(conn, json_private_key, postPrivateKey)


def makeHealthcheckCall(headers, timePassed):
    connected = False
    # WAIT 10 minutes maximum and test every 30 seconds if HealthCheck API is returning 200
    while timePassed < TIMEOUT:
        try:
            conn = httplib.HTTPConnection("localhost",odl_port)
            req = conn.request(certreadyCmd, certreadyUrl,headers=headers)
            res = conn.getresponse()
            res.read()
            httpStatus = res.status
            if httpStatus == 200:
                logging.debug("Healthcheck Passed in %d seconds." %timePassed)
                connected = True
                break
            else:
                logging.debug("Sleep: %d seconds before testing if Healthcheck worked. Total wait time up now is: %d seconds. Timeout is: %d seconds. Problem code was: %d" %(INTERVAL, timePassed, TIMEOUT, httpStatus))
        except:
            logging.error("Cannot execute REST call. Sleep: %d seconds before testing if Healthcheck worked. Total wait time up now is: %d seconds. Timeout is: %d seconds." %(INTERVAL, timePassed, TIMEOUT))
        timePassed = timeIncrement(timePassed)

    if timePassed > TIMEOUT:
        logging.error("TIME OUT: Healthcheck not passed in  %d seconds... Could cause problems for testing activities..." %TIMEOUT)

    return connected


def timeIncrement(timePassed):
    time.sleep(INTERVAL)
    timePassed = timePassed + INTERVAL
    return timePassed

def get_cadi_password():
    try:
        with open(Path + '/' + cadi_file , 'r') as file_obj:
            cadi_pass = file_obj.read().split('=', 1)[1].strip()
        return cadi_pass
    except Exception as e:
        logging.error("Error occurred while fetching password : %s", e)
        exit()

def cleanup():
    for file in os.listdir(Path):
        if os.path.isfile(Path + '/' + file):
            logging.debug("Cleaning up the file %s", Path + '/'+ file)
            os.remove(Path + '/'+ file)

def extract_content(file, password, count):
    try:
        certList = []
        key = None
        cert = None
        if (file.endswith('.jks')):
            p12_file = file.replace('.jks', '.p12')
            jks_cmd = 'keytool -importkeystore -srckeystore {src_file} -destkeystore {dest_file} -srcstoretype JKS -srcstorepass {src_pass} -deststoretype PKCS12 -deststorepass {dest_pass}'.format(src_file=file, dest_file=p12_file, src_pass=password, dest_pass=password)
            logging.debug("Converting %s into p12 format", file)
            os.system(jks_cmd)
            file = p12_file

        clcrt_cmd = 'openssl pkcs12 -in {src_file} -clcerts -nokeys  -passin pass:{src_pass}'.format(src_file=file, src_pass=password)
        clkey_cmd = 'openssl pkcs12 -in {src_file}  -nocerts -nodes -passin pass:{src_pass}'.format(src_file=file, src_pass=password)
        trust_file = file.split('/')[2] + '.trust'
        trustCerts_cmd = 'openssl pkcs12 -in {src_file} -out {out_file} -cacerts -nokeys -passin pass:{src_pass} '.format(src_file=file, out_file=Path + '/' + trust_file, src_pass=password)

        result_key = subprocess.check_output(clkey_cmd , shell=True)
        if result_key:
            key = result_key.split('-----BEGIN PRIVATE KEY-----', 1)[1].lstrip().split('-----END PRIVATE KEY-----')[0]

        os.system(trustCerts_cmd)
        if os.path.exists(Path + '/' + trust_file):
            certList = readTrustedCertificate(Path, trust_file)

        result_crt = subprocess.check_output(clcrt_cmd , shell=True)
        if result_crt:
            cert = result_crt.split('-----BEGIN CERTIFICATE-----', 1)[1].lstrip().split('-----END CERTIFICATE-----')[0]
        """
        To-do: Posting the key, cert, certList might need modification
        based on how AAF distributes the files.

        """
        post_content(key, cert, certList, count)
    except Exception as e:
        logging.error("Error occurred while processing the file %s : %s", file,e)

def lookforfiles():
    count = 0
    for file in os.listdir(Path):
        if (file.endswith(('.p12', '.jks'))):
            if os.path.exists(Path + '/' + cadi_file):
                cert_password = get_cadi_password()
                logging.debug("Extracting contents from the file %s", file)
                extract_content(Path + '/' + file, cert_password, count)
                count += 1
            else:
                logging.error("Cadi password file %s not present under cert directory", cadi_file)
                exit()
    if count > 0:
        cleanup()
    else:
        logging.debug("No jks/p12 files found under cert directory %s", Path)


def readCertProperties():
    connected = makeHealthcheckCall(headers, timePassed)
    logging.info('Connected status: %s', connected)
    if connected:
        count = 0
        if os.path.isfile(Path + "/certs.properties"):
            with open(Path + "/certs.properties", "r") as f:
                for line in f:
                    if not "*****" in line:
                        zipFileList.append(line)
                    else:
                        extractZipFiles(zipFileList, count)
                        count += 1
                        del zipFileList[:]
        else:
            logging.debug("No zipfiles present under cert directory")

        logging.info("Looking for jks/p12 files under cert directory")
        lookforfiles()

readCertProperties()
logging.info('Cert installation ending')
