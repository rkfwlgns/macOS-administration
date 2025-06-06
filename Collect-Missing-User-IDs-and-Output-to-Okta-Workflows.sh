#!/bin/bash

###UserID collection script to be used through JAMF due to parameter definitions

#Gets the currentUser to run command as user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
#Add your Company branding so that the pop-up doesn't look like a scam/malware (parameter 4)
pathToIcon="$4"

userID=$(sudo -u "$currentUser" osascript <<
tell application "System Events" to text returned of (display dialog "Please type in your work email address to verify Mac device ownership:" with icon POSIX file "$pathToIcon" default answer "example@yourCompany.com" buttons {"OK"} default button 1)
EOF)

echo "Tool launched successfully...Outputting userID now"

#Get the Serial Number for the computer
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

echo $serialNumber
echo $userID

#sleep 3

#Define Okta Workflow API in Jamf Pro (parameter 5)
##Example format "https://yourCompanyUrl.workflows.okta.com/api/flo/uniqueFlowIdentifier/invoke?clientToken=yourClientToken"
oktaWorkFlowAPI="$5"

curl --location --request POST "$oktaWorkFlowAPI" \
--header 'Content-Type: application/json' \
--data-raw '{ "Serial": "'$serialNumber'",
	"Username": "'$userID'"
	}'
