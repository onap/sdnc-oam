#!/bin/bash
#
# Copyright (c) 2022 highstreet technologies GmbH Property
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# generates fresh certificates for netconfserver


tls_dir=$1

cd $tls_dir
echo "generate all required certificates and store in $tls_dir"
openssl version
openssl req -newkey rsa:4096 -keyform PEM -keyout ca.key -x509 -days 3650 -outform PEM -out ca.crt -nodes \
    -subj "/C=DE/ST=Berlin/L=Berlin/O=ONAP/OU=SDNC/CN=www.onap.org/emailAddress=dev@www.example.com"
openssl genrsa -out client.key 4096
openssl req -new -key client.key -out client.req -nodes \
    -subj "/C=PL/ST=DS/L=Wroclaw/O=ONAP/OU=SDNC/CN=www.onap.org"
openssl x509 -req -in client.req -CA ca.crt -CAkey ca.key -set_serial 101 -extensions client -days 365 -outform PEM -out client.crt
openssl genrsa -out server_key.pem 4096
openssl req -new -key server_key.pem -out server.req -sha256 -nodes \
    -subj "/C=PL/ST=DS/L=Wroclaw/O=ONAP/OU=SDNC/CN=www.onap.org"
openssl x509 -req -in server.req -CA ca.crt -CAkey ca.key -set_serial 100 -extensions server -days 1460 -outform PEM -out server_cert.crt -sha256

