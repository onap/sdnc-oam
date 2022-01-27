#!/usr/bin/python3
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

# opm = ODLUX package manager
# install odlux application inside of the container
# $1 install|uninstall
# $2 appName
# $3 zip file to add(extract)

import sys
from core import *




# install application
# $1 appName
# $2
# $2 zip file (optional)
def run_install(name, index=0, file=None):
    if name is None:
        error("no name given")
    add_application(name, index, file)
    update_index_html()


# install application from url
# $1 url
# $2 name (optional)
# $3 index (optional)
def run_install_from_url(url, name=None, index=0):
    if url is None:
        error("no url given")
    print("installing from url...")
    localFile = getRandomTempFile()
    download(url,localFile)
    if (name is None) or (index==0):
        infos = autoDetectInfosFromJar(localFile)
        if infos is not None:
            if name is None:
                name = infos['name']
            if index == 0:
                index = infos['index']
    add_application(name,index,localFile)

# uninstall application
# $1 appName
def run_uninstall(name):
    if name is None:
        error("no name given")
    apps = load_applications()
    apps = [app for app in apps if app['name']!=name]
    write_applications(apps)
    update_index_html()
    
def run_list(args):
    apps = load_applications()
    print('installed apps') 
    for app in apps:
        print('{} {}'.format(app['index'],app['name']))
    
def print_help():
    print("ODLUX package manager")
    print("=====================")
    print("usage:")
    print(" opm.py install --name myApplication --index 23 --file app.zip")
    print(" opm.py install --url https://link-to-my-odlux-application.jar")
    print(" opm.py list")
    print(" opm.py uninstall --name myApplication")

def error(msg):
    print('ERROR: {}'.format(msg))
    exit(1)

args = sys.argv
args.pop(0)
cmd = args.pop(0)
name=None
index=0
file=None
url=None
while(len(args)>0):
    x=args.pop(0)
    if x=='--name':
        name=args.pop(0) if len(args)>0 else error("no name given")
    elif x=='--index':
        index=int(args.pop(0)) if len(args)>0 else error("no index given")
    elif x=='--file':
        file=args.pop(0) if len(args)>0 else error("no file given")
    elif x=='--url':
        url=args.pop(0) if len(args)>0 else error("no file given")
    
print("command={} name={} index={} file={} url={}".format(cmd,name,index, file, url))
       
if cmd=='install':
    if url is not None:
        run_install_from_url(url, name, index)
    else:
        run_install(name,index,file)
elif cmd=='uninstall':
    run_uninstall(name)
elif cmd=='list':
    run_list(args)
else:
    print_help
    exit(1)
exit(0)
