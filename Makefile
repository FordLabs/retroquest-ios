.PHONY : log get_app_center help

SHELL = /bin/bash

log:help

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
