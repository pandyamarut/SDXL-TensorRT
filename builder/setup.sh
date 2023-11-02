#!/bin/bash

# NOTE: This script is not ran by default for the template docker image.
#       If you use a custom base image, you can add your required system dependencies here.

set -e # Stop script on error
apt-get update && apt-get upgrade -y # Update System

# Install System Dependencies
# - openssh-server: for ssh access and web terminal
apt-get install -y --no-install-recommends software-properties-common curl git openssh-server

# Install Python 3.10
add-apt-repository ppa:deadsnakes/ppa -y
apt-get update && apt-get install -y --no-install-recommends python3.10 python3.10-dev python3.10-distutils
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install pip for Python 3.10
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py

# Clean up, remove unnecessary packages, and help reduce image size
apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
apt-get install git-lfs

# Your custom commands go here
# Clone the TensorRT repository and switch to the release/8.6 branch
git clone https://github.com/rajeevsrao/TensorRT.git
cd TensorRT
git checkout release/8.6

# Download the SDXL TensorRT files from the specified repository using Git LFS
git lfs install
git clone https://huggingface.co/stabilityai/stable-diffusion-xl-1.0-tensorrt
cd stable-diffusion-xl-1.0-tensorrt

# Run git lfs pull in the background
git lfs pull &

# Check the progress periodically
while true; do
  # Check the status
  status=$(git lfs status)

  # If there are no files in the "Downloading" status, exit
  if [[ $status != *"Downloading"* ]]; then
    echo "Git LFS downloads are complete."
    break
  fi

  sleep 5  # Wait for 5 seconds before checking again
done

# Exit the git lfs pull process (if it's still running)
pkill -f "git lfs pull"

# Continue with the rest of your script
# Install Python libraries and requirements
cd ..

# Install Python libraries and requirements
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade tensorrt

# Navigate to the 'demo/Diffusion' directory and install its requirements
cd demo/Diffusion
pip3 install -r requirements.txt
