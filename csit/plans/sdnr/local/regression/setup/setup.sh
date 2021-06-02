source ${WORKSPACE}/scripts/sdnr/sdnr-launch.sh
onap_dependent_components_launch
vescollector_launch
simulators_launch
sdnr_launch

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="--variablefile=${WORKSPACE}/plans/sdnr/local/environment/localhost.py"


