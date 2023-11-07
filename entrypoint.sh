#!/bin/bash

# Run the specific command once
python3 -u /workspace/handler.py \
  "Astronaut in a jungle, cold color palette, muted colors, detailed, 8k" \
  --build-static-batch \
  --use-cuda-graph \
  --num-warmup-runs 1 \
  --width 1024 \
  --height 1024 \
  --denoising-steps 30 \
  --onnx-base-dir /workspace/stable-diffusion-xl-1.0-tensorrt/sdxl-1.0-base \
  --onnx-refiner-dir /workspace/stable-diffusion-xl-1.0-tensorrt/sdxl-1.0-refiner

# Execute the default command specified in CMD
exec "$@"
