#!/bin/bash

# Run command: [bash update_pods.sh]

# Navigate to the ios directory relative to the script's location
cd "$(dirname "$0")/../ios"

# Remove the Podfile.lock file
rm -rf Podfile.lock

# Remove the Pods directory
rm -rf Pods

# Remove the pubspec.lock file
rm -rf pubspec.lock

# Update the CocoaPods repositories
pod repo update

# Clear the CocoaPods cache
pod cache clean --all

# Deintegrate CocoaPods from your Xcode project
pod deintegrate

# Setup CocoaPods
pod setup

# Install dependencies and update repositories
pod install --repo-update
