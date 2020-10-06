#!/bin/bash
source `dirname $0`/config.sh

execute() {
  $@ || exit
}

echo "Creating scratch ORG"
execute sfdx force:org:create -a $SCRATCH_ORG_ALIAS -s -f ./config/project-scratch-def.json -d 7

echo "Make sure Org user is english"
sfdx force:data:record:update -s User -w "Name='User User'" -v "Languagelocalekey=en_US"

echo "Pushing changes to scratch org"
execute sfdx force:source:push


echo "Assigning permission"
execute sfdx force:user:permset:assign -n StandardUser

echo "Running apex tests"
execute sfdx force:apex:test:run -l RunLocalTests -w 30