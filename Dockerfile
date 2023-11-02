# Base image -> https://github.com/runpod/containers/blob/main/official-templates/base/Dockerfile
FROM nvcr.io/nvidia/pytorch:23.06-py3

# The base image comes with many system dependencies pre-installed to help you get started quickly.
# Please refer to the base image's Dockerfile for more information before adding additional dependencies.
# IMPORTANT: The base image overrides the default huggingface cache location.
WORKDIR /

# Optional: System dependencies
COPY builder/setup.sh /setup.sh
RUN /bin/bash /setup.sh && \
    rm /setup.sh

# Python dependencies
COPY builder/requirements.txt /requirements.txt
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt

# NOTE: The base image comes with multiple Python versions pre-installed.
#       It is recommended to specify the version of Python when running your code.

# Add src files (Worker Template)
ADD src .

# Clone the TensorRT repository and switch to the release/8.6 branch
RUN git clone https://github.com/rajeevsrao/TensorRT.git && \
    cd TensorRT && \
    git checkout release/8.6

# Download the SDXL TensorRT files from the specified repository using Git LFS
RUN git lfs install && \
    git clone https://huggingface.co/stabilityai/stable-diffusion-xl-1.0-tensorrt && \
    cd stable-diffusion-xl-1.0-tensorrt

# Run git lfs pull in the background
RUN git lfs pull &

# Check the progress periodically
RUN while true; do \
  # Check the status
  status=$(git lfs status) \
  # If there are no files in the "Downloading" status, exit
  if [[ $status != *"Downloading"* ]]; then \
    echo "Git LFS downloads are complete." \
    break \
  fi \
  sleep 5  # Wait for 5 seconds before checking again \
done

# Exit the git lfs pull process (if it's still running)
RUN pkill -f "git lfs pull"

# Continue with the rest of your script
# Install Python libraries and requirements
RUN cd .. && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade tensorrt

# Navigate to the 'demo/Diffusion' directory and install its requirements
RUN cd demo/Diffusion && \
    pip3 install -r requirements.txt
    
CMD python3 -u /handler.py
