#!/bin/bash
source `dirname $0`/config.sh

execute() {
  $@ || exit
}

if [ "$QA_URL" ]; then
  echo "Authenticate QA ORG"
  
  echo $QA_URL > qaURLFile
  sfdx force:auth:sfdxurl:store -f qaURLFile -a $QA_ORG_ALIAS
  rm qaURLFile
fi


echo "List existing package versions"
sfdx force:package:version:list -p $PACKAGENAME --concise

echo "Creating new package version"
PACKAGE_VERSION="$(execute sfdx force:package:version:create -p $PACKAGENAME -x -w 40 --json | jq '.result.SubscriberPackageVersionId' | tr -d '"')"

echo "Package Persion: "
echo $PACKAGE_VERSION

echo "Install dependencies in QA ORG"
sfdx texei:package:dependencies:install -u $QA_ORG_ALIAS

execute sfdx force:package:install -p $PACKAGE_VERSION -u $QA_ORG_ALIAS --publishwait=3 --wait 10 -r