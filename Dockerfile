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

COPY TensorRT /workspace/TensorRT
# Python dependencies
COPY builder/requirements.txt /requirements.txt
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt

# NOTE: The base image comes with multiple Python versions pre-installed.
#       It is recommended to specify the version of Python when running your code.

# Add src files (Worker Template)
ADD src .

# Copy the TensorRT directory to the container
CMD python3 -u /handler.py
