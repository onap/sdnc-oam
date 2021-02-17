# ============LICENSE_START=======================================================
#  Copyright (C) 2019 Nordix Foundation.
# ================================================================================
#  extended by highstreet technologies GmbH (c) 2020
#  Copyright (c) 2021 Nokia Intellectual Property.
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
import sys
import re
import http.client
import base64
import time
import zipfile
import shutil
import subprocess
import logging

odl_home = os.environ['ODL_HOME']
log_directory = odl_home + '/data/log/'
log_file = log_directory + 'installCerts.log'
with open(os.path.join(log_directory, 'installCerts.log'), 'w') as fp:
    pass
log_format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
if not os.path.exists(log_directory):
    os.makedirs(log_directory)
logging.basicConfig(filename=log_file,level=logging.DEBUG,filemode='w',format=log_format)
print ('Start cert provisioning. Log file: ' + log_file);

Path = "/tmp"
if "ODL_CERT_DIR" in os.environ:
    Path = os.environ['ODL_CERT_DIR']

zipFileList = []

username = os.environ['ODL_ADMIN_USERNAME']
password = os.environ['ODL_ADMIN_PASSWORD']
TIMEOUT=1000
INTERVAL=30
timePassed=0

postKeystore= "/rests/operations/netconf-keystore:add-keystore-entry"
postPrivateKey= "/rests/operations/netconf-keystore:add-private-key"
postTrustedCertificate= "/rests/operations/netconf-keystore:add-trusted-certificate"

truststore_pass_file = Path + '/truststore.pass'
truststore_file = Path + '/truststore.jks'

keystore_pass_file = Path + '/keystore.pass'
keystore_file = Path + '/keystore.jks'

jks_files = [truststore_pass_file, keystore_pass_file, keystore_file, truststore_file]

envOdlFeaturesBoot='ODL_FEATURES_BOOT'
# Strategy sli-api is default
certreadyCmd="POST"
certreadyUrl="/rests/operations/SLI-API:healthcheck"

if "SDNRWT" in os.environ: 
    sdnrWt = os.environ['SDNRWT']
    if sdnrWt == "true":
        certreadyCmd="GET"
        certreadyUrl="/rests/data/network-topology:network-topology"
logging.info('ODL ready strategy with command %s and url %s', certreadyCmd, certreadyUrl)

odl_port = 8181
cred_string = username + ":" + password
headers = {'Authorization':'Basic %s' % base64.b64encode(cred_string.encode()).decode(),
           'X-FromAppId': 'csit-sdnc',
           'X-TransactionId': 'csit-sdnc',
           'Accept':"application/json",
           'Content-type':"application/yang-data+json"}

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
    odl_private_key = "ODL_private_key_%d" %count

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
    if res.status != 200 and res.status != 204:
        logging.error("Error here, response back wasnt 200: Response was : %d , %s" % (res.status, res.reason))
        writeCertInstallStatus("NOTOK")
    else:
        logging.debug("Response :%s Reason :%s ",res.status, res.reason)

def extractZipFiles(zipFileList, count):
    for zipFolder in zipFileList:
        try:
                with zipfile.ZipFile(Path + "/" + zipFolder.strip(),"r") as zip_ref:
                    zip_ref.extractall(Path)
                folder = zipFolder.rsplit(".")[0]
                processFiles(folder, count)
        except Exception as e:
                logging.error("Error while extracting zip file(s). Exiting Certificate Installation.")
                logging.info("Error details : %s" % e)
                writeCertInstallStatus("NOTOK")

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
            writeCertInstallStatus("NOTOK")
    shutil.rmtree(Path + "/" + folder)
    post_content(clientKey, clientCrt, certList, count)

def post_content(clientKey, clientCrt, certList, count):
    logging.info('Post content: %d', count)
    conn = http.client.HTTPConnection("localhost",odl_port)

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
            conn = http.client.HTTPConnection("localhost",odl_port)
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
        writeCertInstallStatus("NOTOK")

    return connected


def timeIncrement(timePassed):
    time.sleep(INTERVAL)
    timePassed = timePassed + INTERVAL
    return timePassed


def get_pass(file_name):
    try:
        with open(file_name, 'r') as file_obj:
            password = file_obj.read().strip()
        return "'{}'".format(password)
    except Exception as e:
        logging.error("Error occurred while fetching password : %s", e)
        writeCertInstallStatus("NOTOK")

def cleanup():
    for file in os.listdir(Path):
        if os.path.isfile(Path + '/' + file):
            logging.debug("Cleaning up the file %s", Path + '/'+ file)
            os.remove(Path + '/'+ file)


def jks_to_p12(file, password):
    """Converts jks format into p12"""
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
             return file
    except Exception as e:
        logging.error("Error occurred while converting jks to p12 format : %s", e)
        writeCertInstallStatus("NOTOK")


def make_cert_chain(cert_chain, pattern):
    cert_list = []
    if cert_chain:
        cert_chain = cert_chain.decode('utf-8')
        matches = re.findall(pattern, cert_chain, re.DOTALL | re.MULTILINE)
        for cert in matches:
            cert_list.append(cert.strip())
        return cert_list
    else:
        logging.debug(" Certificate Chain empty: %s " % cert_chain)


def process_jks_files(count):
    ca_cert_list = []
    logging.info("Processing JKS files found in %s directory " % Path)
    try:
        if all([os.path.isfile(f) for f in jks_files]):
            keystore_pass = get_pass(keystore_pass_file)
            keystore_file_p12 = jks_to_p12(keystore_file, keystore_pass)

            client_key_cmd = 'openssl pkcs12 -in {src_file} -nocerts -nodes -passin pass:{src_pass}'.format(
                src_file=keystore_file_p12, src_pass=keystore_pass)
            client_crt_cmd = 'openssl pkcs12 -in {src_file} -clcerts -nokeys  -passin pass:{src_pass}'.format(
                src_file=keystore_file_p12, src_pass=keystore_pass)

            truststore_pass = get_pass(truststore_pass_file)
            truststore_p12 = jks_to_p12(truststore_file, truststore_pass)

            trust_cert_cmd = 'openssl pkcs12 -in {src_file} -cacerts -nokeys -passin pass:{src_pass} '.format(
                src_file=truststore_p12, src_pass=truststore_pass)

            key_pattern = r'(?<=-----BEGIN PRIVATE KEY-----).*?(?=-----END PRIVATE KEY-----)'
            client_key = subprocess.check_output(client_key_cmd, shell=True)
            if client_key:
                client_key = make_cert_chain(client_key, key_pattern)[0]
                logging.debug("Key Ok")

            cert_pattern = r'(?<=-----BEGIN CERTIFICATE-----).*?(?=-----END CERTIFICATE-----)'
            client_cert = subprocess.check_output(client_crt_cmd, shell=True)
            if client_cert:
                client_cert = make_cert_chain(client_cert, cert_pattern)[0]
                logging.debug("Client Cert Ok")

            ca_cert = subprocess.check_output(trust_cert_cmd, shell=True)
            if ca_cert:
                ca_cert_list = make_cert_chain(ca_cert, cert_pattern)
                logging.debug("CA Cert Ok")

            if client_key and client_cert and ca_cert:
                post_content(client_key, client_cert, ca_cert_list, count)
        else:
            logging.debug("No JKS files found in %s directory" % Path)
    except subprocess.CalledProcessError as err:
        print("CalledProcessError Execution of OpenSSL command failed: %s" % err)
        writeCertInstallStatus("NOTOK")
    except Exception as e:
        logging.error("UnExpected Error while processing JKS files at {0}, Caused by: {1}".format(Path, e))
        writeCertInstallStatus("NOTOK")

def readCertProperties():
    '''
    This function searches for manually copied zip file
    containing certificates. This is required as part
    of backward compatibility.
    If not foud, it searches for jks certificates.
    '''
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
            logging.debug("No certs.properties/zip files exist at: " + Path)
            logging.info("Processing any  available jks/p12 files under cert directory")
            process_jks_files(count)
    else:
        logging.info('Connected status: %s', connected)
        logging.info('Stopping SDNR due to inability to install certificates')
        writeCertInstallStatus("NOTOK")
        
def writeCertInstallStatus(installStatus):
    if installStatus == "NOTOK":
        with open(os.path.join(log_directory, 'INSTALLCERTSFAIL'), 'w') as fp:
            pass
            sys.exit(1)
    elif installStatus == "OK":
        with open(os.path.join(log_directory, 'INSTALLCERTSPASS'), 'w') as fp:
            pass
            sys.exit(0)

readCertProperties()
logging.info('Cert installation ending')
writeCertInstallStatus("OK")

