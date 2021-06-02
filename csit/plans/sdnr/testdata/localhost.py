#!python

# This file describes test all paramters for a specific test environment and system under test.
# SDNR Custom keywords and test suites use this file to be independent
# This file es created once for a test system
# in robot commandline pass the file with '--variablefile <my_environment>.py'

## Access SDNR cluster
SDNR_PROTOCOL = "http://"
SDNR_HOST = "127.0.0.1"
SDNR_PORT = "8181"
SDNR_USER = "admin"
SDNR_PASSWORD = "Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U"

# for odlux gui testing
WEBDRIVER_PATH = "/usr/local/bin/chromedriver"

# Access to elastic search SDNRDB
SDNRDB = {'PROTOCOL': 'http', 'IP': '127.0.0.1', 'PORT': '8181', 'USE_API_GATEWAY': True, 'USE_SSL': False,
          'VERIFY_CERTS': False}
# elastic DB to store statistic datas
ELASTIC_LOG_DB = SDNRDB
RESTCONF_TIMEOUT = '90 s'
# Restconf response time longer than VALID_RESPONSE_TIME in s will be notified as warning in the robot logs
VALID_RESPONSE_TIME = 5


VESCOLLECTOR = {"SCHEME": "https", "IP": "172.40.0.1", "PORT": 8443, "AUTHMETHOD": "basic-auth", "USERNAME": "sample1",
                "PASSWORD": "sample1"}

NTS_SSH_CONNECTIONS = 10
NTS_TLS_CONNECTIONS = 10
# ssh settings for karaf-shell
# list of default log topics, short name (defined in ...) or long name
KARAF_CONSOLE = {'KARAF_USER': "karaf", 'KARAF_PASSWORD': "karaf", 'KARAF_LOG_LEVEL': "DEFAULT",
                 'KARAF_LOGGER_LIST': ['netconf', 'wtfeatures'],
                 'HOST_LIST': [{'KARAF_HOST': "127.0.0.1", 'KARAF_PORT': 8101}
                               ]}
# define log level used by default
KARAF_LOG_LEVEL = "DEFAULT"
# save karaf logs after test execution
KARAF_GET_LOG = True
KARAF_LOG_FILE_PATH = '/opt/opendaylight/data/log/'
# KARAF_LOG_FILE_PATH = '/var/log/onap/sdnc/karaf.log'
# write useful statistics in background
WRITE_STATISTICS_BACKGROUND = False
WRITE_STATISTICS_BACKGROUND_INTERVAL = 5

GLOBAL_SUITE_SETUP_CONFIG = {'setup_ssh_lib': True}
