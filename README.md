# Qwen Image Generation & Editing Demo

A minimal example showing how to:

1. **Generate images** with the Qwen‑Image diffusion model (`qwen_image.py`).
2. **Edit existing images** using the Qwen‑Image‑Edit pipeline (`qwen_image_edit.py`).
3. **Containerize** the environment with Docker.
4. **Build and run** the container via convenient `make` targets.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [1️⃣ Build the Docker image](#1️⃣-build-the-docker-image)
  - [2️⃣ Run the container](#2️⃣-run-the-container)
  - [3️⃣ Generate an image](#3️⃣-generate-an-image)
  - [4️⃣ Edit an image](#4️⃣-edit-an-image)
- [Customization](#customization)
- [Cleaning Up](#cleaning-up)
- [License](#license)

---

## Prerequisites

| Tool | Minimum Version |
|------|-----------------|
| Docker | ≥ 20.10 |
| NVIDIA GPU with CUDA 12.9 drivers (optional but recommended) |
| `make` (installed on most Linux/macOS environments) |
| `git` (to clone the repo) |

> **Note:** If you run the scripts on a CPU‑only machine, the code will fall back to `torch.float32` automatically.

## Project Structure

```
📂 .
├── qwen_image.py            # Text‑to‑image generation script
├── qwen_image_edit.py       # Image‑inpainting / editing script
├── Dockerfile               # Container definition
├── Makefile                 # Helper commands for build/run
├── .dockerignore            # Files excluded from the Docker context
└── README.md                # ← This file
```

## Getting Started

### 1️⃣ Build the Docker image

```bash
make build   # builds and tags the image with both latest and git‑SHA tags
```

*The `Dockerfile` installs PyTorch (CUDA 12.9), 🤗 Transformers, and Diffusers from source.*  

If you only need a local build (no Git metadata), you can run:

```bash
make build-local
```

### 2️⃣ Run the container

```bash
make run   # interactive shell with GPU access
```

The container mounts:
- Your repository (`$(pwd)`) to `/root` (so you can edit scripts live).
- A local cache folder (`/tmp/hugginface`) to avoid re‑downloading models.

> **Tip:** Use `make run-local` if you don’t have a CI environment or want to skip pulling the image again.

### 3️⃣ Generate an image

Inside the container (or on host if you have the required Python packages):

```bash
python qwen_image.py
```

This script:
- Loads the `Qwen/Qwen-Image` model.
- Generates an image with a preset prompt (feel free to edit `prompt` or `positive_magic`).
- Saves the output as `example.png` in the current directory.

You can change the aspect ratio by editing the `aspect_ratios` dictionary and adjusting `width, height = aspect_ratios["16:9"]`.

### 4️⃣ Edit an image

Place an image named `input.png` in the repository root (or modify the path in the script), then run:

```bash
python qwen_image_edit.py
```

The script:
- Loads `Qwen/Qwen-Image-Edit`.
- Applies the edit described in `prompt` (e.g., “Change the rabbit's color to purple…”).
- Saves the edited result as `output_image_edit.png`.

## Customization

- **Prompts:** Edit `prompt` strings in either script to suit your use‑case.
- **Seed & CFG:** Adjust `generator=torch.Generator(...).manual_seed(...)` and `true_cfg_scale` for deterministic or more creative outputs.
- **Model selection:** Replace `model_name = "Qwen/Qwen-Image"` with a different model identifier from Hugging Face Hub if desired.

## Cleaning Up

To stop the container and remove any dangling images:

```bash
docker container prune   # removes stopped containers
docker image prune -a    # removes unused images (be careful!)
```

## License

This demo repository is provided **as‑is** for educational purposes. Refer to the individual model licenses on Hugging Face for usage restrictions.

---

*Happy image generation!* 🎨🚀