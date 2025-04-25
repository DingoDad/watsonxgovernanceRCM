#
# Licensed Materials - Property of IBM
#
#
# watsonx.governance RCM - Compliance Accelerator Loaders
#
#  © Copyright IBM Corporation 2021 - 2025. All Rights Reserved.
#
# US Government Users Restricted Rights- Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# On-Prem: ./load-wxgov-artifacts-phase1.sh <OpenPages Admin UserName> <OpenPages Admin Password>
# Cloud: ./load-wxgov-artifacts-phase1.sh isCloud
# AWS: ./load-wxgov-artifacts-phase1.sh apikey <API Key>

# Set the ObjectManager config filename for the load
OM_CONFIG_FILE="_wxgov.loader.RCM.txt"

set -x

# Determine if the environment is IBM Cloud or SaaS based on the first parameter
USE_CLOUD=false
if [ "${1}" = "isCloud" ]; then
  USE_CLOUD=true
fi

export currentPath=\"$(pwd)\"

# Define the command prefix based on the environment
if [ "$USE_CLOUD" = true ]; then
  # Setting the values for Cloud environment 
  OBJECT_MANAGER_CMD="ibmcloud openpages objectmanager"
  BATCH_COMMAND="$OBJECT_MANAGER_CMD batch"
  EXECUTE_BATCH="$BATCH_COMMAND ${currentPath} "

  # Generate the ObjectManager.properties file for Cloud
  ibmcloud openpages objectmanager create-templates ${currentPath}
  OPConfDir=${currentPath}
else
  # Setting the values for On-Prem environment
  OBJECT_MANAGER_CMD="./ObjectManager.sh"
  BATCH_COMMAND="$OBJECT_MANAGER_CMD b c ${1} ${2}"
  EXECUTE_BATCH="$BATCH_COMMAND ${currentPath} ${currentPath}/"

  OPClientDir=$OPC_BIN_DIR
  [ OPClientDir == "" ] && OPClientDir="/home/opuser/OP/OpenPages/openpages-tools-client/bin"
  [ ! -d "$OPClientDir" ] && OPClientDir="/home/opuser/OP/OpenPages/bin"
  [ ! -d "$OPClientDir" ] && { echo "Error: The location of the ObjectManager client has not been set.  You must create the environment variable, OPC_BIN_DIR, with the location of the object manager client.  For example, export OPC_BIN_DIR=/home/opuser/OP/OpenPages/bin"; exit $ERRCODE; }

  OPConfDir="/home/opuser/OP/OpenPages/openpages-tools-client/conf"
  [ ! -d "$OPConfDir" ] && OPConfDir=${OPClientDir}

  cd ${OPClientDir}
fi

sed -i '/configuration.manager.force.update.object.strings[[:blank:]]*=[[:blank:]]*false/c\configuration.manager.force.update.object.strings=true' ${OPConfDir}/ObjectManager.properties
sed -i '/configuration.manager.vendor.mode[[:blank:]]*=[[:blank:]]*false/c\configuration.manager.vendor.mode=true' ${OPConfDir}/ObjectManager.properties
sed -i '/configuration.manager.force.update.application.strings[[:blank:]]*=[[:blank:]]*false/c\configuration.manager.force.update.application.strings=true' ${OPConfDir}/ObjectManager.properties

bash <(echo "${EXECUTE_BATCH}${OM_CONFIG_FILE}")

sed -i '/configuration.manager.force.update.object.strings[[:blank:]]*=[[:blank:]]*true/c\configuration.manager.force.update.object.strings=false' ${OPConfDir}/ObjectManager.properties
sed -i '/configuration.manager.vendor.mode[[:blank:]]*=[[:blank:]]*true/c\configuration.manager.vendor.mode=false' ${OPConfDir}/ObjectManager.properties
sed -i '/configuration.manager.force.update.application.strings[[:blank:]]*=[[:blank:]]*true/c\configuration.manager.force.update.application.strings=false' ${OPConfDir}/ObjectManager.properties
