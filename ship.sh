#!/bin/sh
set -eo pipefail
IFS=$'\n\t'

echo "Shipping RetroQuest-iOS..."

git pull -r

fastlane tests

git push

echo "DONE"
