#!/usr/bin/env bash

SBT_VERSION="$1"
EXPECTED_MD5="3313925451929f8f137774844e3a9ee2"

curl -vvv "https://scala.jfrog.io/artifactory/debian/sbt-${SBT_VERSION}.deb" --output "sbt-${SBT_VERSION}.deb"

RECEIVED_MD5="$(md5sum "sbt-${SBT_VERSION}.deb" | cut -f1 -d' ')"

echo "Expected MD5: ${EXPECTED_MD5}"
echo "Received MD5: ${RECEIVED_MD5}"

if [ "$EXPECTED_MD5" = "$RECEIVED_MD5" ]; then
  dpkg -i "sbt-${SBT_VERSION}.deb"
else
  echo "MD5 MISMATCH!"
  exit 1
fi