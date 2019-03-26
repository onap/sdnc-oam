# ============LICENSE_START=======================================================
#  Copyright (C) 2019 Nordix Foundation.
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

Path = "/tmp"

zipFileList = []
username = "admin"
password = "Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U"

TIME_OUT=1000
INTERVAL=30
TIME=0

postKeystore= "/restconf/operations/netconf-keystore:add-keystore-entry"
postPrivateKey= "/restconf/operations/netconf-keystore:add-private-key"
postTrustedCertificate= "/restconf/operations/netconf-keystore:add-trusted-certificate"


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
    caPem = ""
    serverCrt = ""
    startCa = False
    startCrt = False
    key = open(Path + "/" + folder + "/" + file, "r")
    lines = key.readlines()
    for line in lines:
        if not "BEGIN CERTIFICATE CA.pem" in line and not "END CERTIFICATE CA.pem" in line and startCa:
            caPem += line
        elif "BEGIN CERTIFICATE CA.pem" in line:
            startCa = True
        elif "END CERTIFICATE CA.pem" in line:
            startCa = False

        if not "BEGIN CERTIFICATE Server.crt" in line and not "END CERTIFICATE Server.crt" in line and startCrt:
            serverCrt += line
        elif "BEGIN CERTIFICATE Server.crt" in line:
            startCrt = True
        elif "END CERTIFICATE Server.crt" in line:
            startCrt = False
    return caPem, serverCrt

def makeKeystoreKey(clientKey, count):
    odl_private_key="ODL_private_key_%d" %count

    json_keystore_key='{{\"input\": {{ \"key-credential\": {{\"key-id\": \"{odl_private_key}\", \"private-key\" : ' \
                      '\"{clientKey}\",\"passphrase\" : \"\"}}}}}}'.format(
        odl_private_key=odl_private_key,
        clientKey=clientKey)

    return json_keystore_key



def makePrivateKey(clientKey, clientCrt, caPem, count):
    odl_private_key="ODL_private_key_%d" %count

    json_private_key='{{\"input\": {{ \"private-key\":{{\"name\": \"{odl_private_key}\", \"data\" : ' \
                     '\"{clientKey}\",\"certificate-chain\":[\"{clientCrt}\",\"{caPem}\"]}}}}}}'.format(
        odl_private_key=odl_private_key,
        clientKey=clientKey,
        clientCrt=clientCrt,
        caPem=caPem)

    return json_private_key

def makeTrustedCertificate(serverCrt, caPem, count):
    trusted_cert_name = "xNF_Server_certificate_%d" %count
    trusted_name = "xNF_CA_certificate_%d" %count

    json_trusted_cert='{{\"input\": {{ \"trusted-certificate\": [{{\"name\":\"{trusted_cert_name}\",\"certificate\" : ' \
                      '\"{serverCrt}\"}},{{\"name\": \"{trusted_name}\",\"certificate\":\"{caPem}\"}}]}}}}'.format(
        trusted_cert_name=trusted_cert_name,
        serverCrt=serverCrt,
        trusted_name=trusted_name,
        caPem=caPem)

    return json_trusted_cert


def makeRestconfPost(conn, json_file, apiCall):
    req = conn.request("POST", apiCall, json_file, headers=headers)
    res = conn.getresponse()
    res.read()
    if res.status != 200:
        print "Error here, response back wasnt 200: Response was : %d , %s" % (res.status, res.reason)
    else:
        print res.status, res.reason

def extractZipFiles(zipFileList, count):
    for zipFolder in zipFileList:
        with zipfile.ZipFile(Path + "/" + zipFolder.strip(),"r") as zip_ref:
            zip_ref.extractall(Path)
        folder = zipFolder.rsplit(".")[0]
        processFiles(folder, count)

def processFiles(folder, count):
    conn = httplib.HTTPConnection("localhost",8181)
    for file in os.listdir(Path + "/" + folder):
        if os.path.isfile(Path + "/" + folder + "/" + file.strip()):
            if ".key" in file:
                clientKey = readFile(folder, file.strip())
            elif "trustedCertificate" in file:
                caPem, serverCrt = readTrustedCertificate(folder, file.strip())
            elif ".crt" in file:
                clientCrt = readFile(folder, file.strip())
        else:
            print "Could not find file %s" % file.strip()
    shutil.rmtree(Path + "/" + folder)
    json_keystore_key = makeKeystoreKey(clientKey, count)
    json_private_key = makePrivateKey(clientKey, clientCrt, caPem, count)
    json_trusted_cert = makeTrustedCertificate(serverCrt, caPem, count)

    makeRestconfPost(conn, json_keystore_key, postKeystore)
    makeRestconfPost(conn, json_private_key, postPrivateKey)
    makeRestconfPost(conn, json_trusted_cert, postTrustedCertificate)

def makeHealthcheckCall(headers):
    conn = httplib.HTTPConnection("localhost",8181)
    req = conn.request("POST", "/restconf/operations/SLI-API:healthcheck",headers=headers)
    res = conn.getresponse()
    res.read()
    if res.status == 200:
        print ("Healthcheck Passed in %d seconds." %TIME)
    else:
        print ("Sleep: %d seconds before testing if Healtcheck worked. Total wait time up now is: %d seconds. Timeout is: %d seconds" %(INTERVAL, TIME, TIME_OUT))
    return res.status


def timeIncrement(TIME):
    time.sleep(INTERVAL)
    TIME = TIME + INTERVAL
    return TIME

def healthcheck(TIME):
    # WAIT 10 minutes maximum and test every 30 seconds if HealthCheck API is returning 200
    while TIME < TIME_OUT:
        try:
            status = makeHealthcheckCall(headers)
            if status == 200:
                connected = True
                break
        except:
            print ("Sleep: %d seconds before testing if Healthcheck worked. Total wait time up now is: %d seconds. Timeout is: %d seconds" %(INTERVAL, TIME, TIME_OUT))

        TIME = timeIncrement(TIME)

    if TIME > TIME_OUT:
        print ("TIME OUT: Healthcheck not passed in  %d seconds... Could cause problems for testing activities..." %TIME_OUT)

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
            print "Error: File not found in path entered"
    else:
        print "This was a problem here, Healthcheck never passed, please check is your instance up and running."


healthcheck(TIME)
