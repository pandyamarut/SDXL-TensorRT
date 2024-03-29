# Base image -> https://github.com/runpod/containers/blob/main/official-templates/base/Dockerfile
FROM nvcr.io/nvidia/pytorch:23.06-py3

# The base image comes with many system dependencies pre-installed to help you get started quickly.
# Please refer to the base image's Dockerfile for more information before adding additional dependencies.
# IMPORTANT: The base image overrides the default huggingface cache location.
WORKDIR /workspace

# # Optional: System dependencies
# COPY builder/setup.sh /setup.sh
# RUN /bin/bash /setup.sh && \
#     rm /setup.sh

# Python dependencies
COPY builder/requirements.txt /requirements.txt
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt


COPY src/Diffusion /workspace/Diffusion

# Copy the stable diffusion directory to the container
COPY src/stable-diffusion-xl-1.0-tensorrt /workspace/stable-diffusion-xl-1.0-tensorrt

# Copy the entry point script to the container
COPY src/entrypoint.sh /workspace/entrypoint.sh

# Make the entry point script executable
RUN chmod +x /workspace/entrypoint.sh
# Set the entrypoint
ADD src .

# ENTRYPOINT ["/workspace/entrypoint.sh"]


CMD ["python3", "-u", "/workspace/Diffusion/handler.py"] 
