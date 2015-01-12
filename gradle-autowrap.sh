#!/bin/bash
#
# Entry script for Gradle that calls the Gradle wrapper if it exists, and the
# system Gradle otherwise.

if [[ -x ./gradlew ]]; then
  echo "Using ./gradlew"
  ./gradlew "$@"
else
  echo "Using /usr/bin/gradle"
  /usr/bin/gradle "$@"
fi
