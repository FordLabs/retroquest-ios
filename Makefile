.PHONY : log update_carthage bootstrap_carthage  help

SHELL = /bin/bash

log:help

## bootstrap_carthage	: Runs carthage bootstrap
bootstrap_carthage:
	carthage bootstrap --platform iOS --cache-builds --no-use-binaries

## update_carthage	: Runs carthage update
update_carthage:
	carthage update --platform iOS --cache-builds --no-use-binaries

help: Makefile
	sed -n "s/^##//p" $<

get_app_center:
	if [ ! -d "Vendor" ]; then \
curl -LO https://github.com/microsoft/appcenter-sdk-apple/releases/download/2.3.0/AppCenter-SDK-Apple-2.3.0.zip --silent; \
unzip -q AppCenter-SDK-Apple-2.3.0.zip; \
mkdir Vendor; \
mv AppCenter-SDK-Apple/iOS/*.framework Vendor; \
rm -rf AppCenter-SDK-Apple*; \
	fi
