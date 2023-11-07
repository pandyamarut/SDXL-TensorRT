# Base image -> https://github.com/runpod/containers/blob/main/official-templates/base/Dockerfile
FROM nvcr.io/nvidia/pytorch:23.06-py3

# The base image comes with many system dependencies pre-installed to help you get started quickly.
# Please refer to the base image's Dockerfile for more information before adding additional dependencies.
# IMPORTANT: The base image overrides the default huggingface cache location.
WORKDIR /workspace

# Optional: System dependencies
COPY builder/setup.sh /setup.sh
RUN /bin/bash /setup.sh && \
    rm /setup.sh

# Python dependencies
COPY builder/requirements.txt /requirements.txt
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt


COPY src/Diffusion /workspace/Diffusion

# Copy the stable diffusion directory to the container

COPY src/stable-diffusion-xl-1.0-tensorrt /workspace/stable-diffusion-xl-1.0-tensorrt


ADD src .

CMD ["python3", "-u", "/workspace/Diffusion/demo_txt2img_xl.py", \
  "Astronaut in a jungle, cold color palette, muted colors, detailed, 8k", \
  "--build-static-batch", \
  "--use-cuda-graph", \
  "--num-warmup-runs", "1", \
  "--width", "1024", \
  "--height", "1024", \
  "--denoising-steps", "30", \
  "--onnx-base-dir", "/workspace/stable-diffusion-xl-1.0-tensorrt/sdxl-1.0-base", \
  "--onnx-refiner-dir", "/workspace/stable-diffusion-xl-1.0-tensorrt/sdxl-1.0-refiner"]
