:: ***************************************************************************
:: Licensed Materials - Property of IBM
::
::
:: watsonx.governance RCM - Compliance Accelerator Loaders
::
:: © Copyright IBM Corporation 2021 - 2025. All Rights Reserved.
::
:: US Government Users Restricted Rights- Use, duplication or
:: disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
:: 
:: On-Prem: load-wxgov-artifacts-RCM.bat <OpenPages Admin UserName> <OpenPages Admin Password>
:: Cloud: load-wxgov-artifacts-RCM.bat isCloud
:: AWS: load-wxgov-artifacts-RCM.bat apikey <API Key>
:: ***************************************************************************

@echo off

:: Set the ObjectManager config filename for the load
set OM_CONFIG_FILE=_wxgov.loader.RCM.txt

set currentPath=%cd%

:: Determine if the environment is IBM Cloud or SaaS based on the first parameter
set USE_CLOUD=false
if "%1"=="isCloud" set USE_CLOUD=true

:: Define commands based on environment
if "%USE_CLOUD%"=="true" (
	:: Setting the values for Cloud environment 
    set "EXECUTE_BATCH=ibmcloud openpages objectmanager batch "%currentPath%" "
    set objMgrProp=%currentPath%\\ObjectManager.properties

    :: Generate the ObjectManager.properties file for Cloud
    ibmcloud openpages objectmanager create-templates "%currentPath%"
	goto GOTO_OM_LOAD
)
	:: Setting the values for On-Prem environment
	set "OPLibDir=%OPC_BIN_DIR%"
    if "%OPLibDir%" == "" set "OPLibDir=C:\\IBM\\OP\\OpenPages\\openpages-tools-client\\bin"
	if not exist "%OPLibDir%" set "OPLibDir=C:\\IBM\\OP\\OpenPages\\bin"
    if not exist "%OPLibDir%" goto EXIT_WITH_ERROR

    set "EXECUTE_BATCH=ObjectManager b c %1 %2 "%currentPath%" "%currentPath%"\"
    set objMgrProp=%OPLibDir%\\ObjectManager.properties

    cd %OPLibDir%

:GOTO_OM_LOAD

:: Enabling the ObjectManager properties settings before the load
powershell -Command "(Get-Content -Path '%objMgrProp%') -replace 'configuration\.manager\.force\.update\.object\.strings\s*=\s*false', 'configuration.manager.force.update.object.strings = true' | Set-Content -Path '%objMgrProp%'"
powershell -Command "(Get-Content -Path '%objMgrProp%') -replace 'configuration\.manager\.vendor\.mode\s*=\s*false', 'configuration.manager.vendor.mode = true' | Set-Content -Path '%objMgrProp%'"
powershell -Command "(Get-Content -Path '%objMgrProp%') -replace 'configuration\.manager\.force\.update\.application\.strings\s*=\s*false', 'configuration.manager.force.update.application.strings = true' | Set-Content -Path '%objMgrProp%'"

:: Execute batch command
%EXECUTE_BATCH%%OM_CONFIG_FILE%

:: Disabling the ObjectManager properties settings after the load
powershell -Command "(Get-Content -Path '%objMgrProp%') -replace 'configuration\.manager\.force\.update\.object\.strings\s*=\s*true', 'configuration.manager.force.update.object.strings = false' | Set-Content -Path '%objMgrProp%'"
powershell -Command "(Get-Content -Path '%objMgrProp%') -replace 'configuration\.manager\.vendor\.mode\s*=\s*true', 'configuration.manager.vendor.mode = false' | Set-Content -Path '%objMgrProp%'"
powershell -Command "(Get-Content -Path '%objMgrProp%') -replace 'configuration\.manager\.force\.update\.application\.strings\s*=\s*true', 'configuration.manager.force.update.application.strings = false' | Set-Content -Path '%objMgrProp%'"

goto :END

:EXIT_WITH_ERROR
echo Error: The location of the ObjectManager client has not been set.  You must create the environment variable, OPC_BIN_DIR, with the location of the object manager client.
echo For example, set OPC_BIN_DIR=c:\IBM\OpenPages\openpages-tools-client\bin

:END
