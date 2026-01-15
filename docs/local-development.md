# Local Development

This document describes how to use the Docker image for interactive development and local builds. By using Docker, we ensure that every developer has the exact same toolchain as the CI/CD pipeline.

---

## Prerequisites

* **Docker:** Installed on Linux or macOS.
* **Git:** Ensure you clone with submodules enabled, as MLC-LLM relies on nested dependencies:
```bash
git clone --recursive https://github.com/<owner>/<repo>.git

```



---

## Development Environment

The provided Docker image is a "batteries-included" environment. It contains:

* **OS:** Ubuntu base image.
* **Python:** Miniconda with Python 3.13.
* **Build Tools:** CMake >= 3.24, Rust, and Cargo.
* **Graphics:** Vulkan headers and validation tools.
* **Version Control:** Git and Git LFS.

No dependencies need to be installed on your host machine other than Docker.

---

## Running an Interactive Dev Shell

Use the following command to start a container and mount your current directory. This allows you to edit code on your host machine (using VS Code, etc.) while compiling inside the container.

```bash
docker run -it \
  -v $(pwd):/workspace \
  ghcr.io/<owner>/<repo>:latest

```

**Inside the shell:**

1. The working directory is mapped to `/workspace`.
2. The Conda `mlc` environment is pre-activated.
3. All system paths are configured for native compilation.

---

## Building Locally

Once inside the interactive shell, you can trigger a full build by running the centralized build script:

```bash
./scripts/build.sh

```

**What this script does:**

* Configures the build using CMake.
* Enables **Vulkan** support.
* Compiles the native C++ libraries.
* Packages the result into a **Python Wheel** (`.whl`) located in the `dist/` folder.

---

## Running Tests

To verify your changes, run the test suite:

```bash
./scripts/test.sh

```

> **[IMPORTANT]**
> The test script is designed to install the built wheel and test against it, rather than testing the raw source tree. This ensures the packaging logic is functional.

---

## Why This Approach?

* **Reproducibility:** Eliminates the "it works on my machine" problem.
* **No Host Pollution:** Keeps your personal machine clean of specific LLM build dependencies.
* **Parity:** Your local environment is a 1:1 match with the production CI pipeline.

---