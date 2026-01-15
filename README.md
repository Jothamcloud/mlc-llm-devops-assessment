# MLC-LLM CI/CD Pipeline

This repository implements a production-grade CI/CD pipeline for building, testing, and releasing the MLC-LLM Python package on Linux using a multipurpose Docker-based workflow.

The goal of this project is to demonstrate how complex native + Python projects can be reliably built, tested, and released using modern DevOps practices.

---

## Scope

This project delivers the following:

**Multipurpose Docker image that serves as:**
* An interactive development environment
* A non-interactive CI build environment


* Automated, test-gated GitHub Actions pipelines
* Linux wheel builds for the MLC-LLM Python package
* Artifact publishing to:
* GitHub Container Registry (GHCR)
* GitHub Releases



---

## High-Level Architecture

```text
Developer / CI
      |
      v
Docker Image (GHCR)
├── Conda (Python 3.13)
├── CMake >= 3.24
├── Vulkan toolchain
└── Build tooling
      |
      v
Build Script (scripts/build.sh)
      |
      v
Python Wheels
      |
      v
Test Script (scripts/test.sh)
      |
      v
GitHub Release (on tag)

```

---

## Repository Structure

```text
.
├── docker/
│   └── Dockerfile          # Environment definition
├── scripts/
│   ├── build.sh            # Logic for native & wheel compilation
│   └── test.sh             # Logic for post-build validation
├── docs/
│   ├── local-development.md
│   ├── ci-pipeline.md
│   └── releases.md
├── README.md             
└── .github/workflows/
    └── ci.yml              # GitHub Actions orchestration

```

---

## Quick Start (Local Development)

To jump into a pre-configured environment with all dependencies (Vulkan, CMake, Conda) ready to go:

```bash
# 1. Pull the latest image
docker pull ghcr.io/<owner>/<repo>:latest

# 2. Run the interactive shell
docker run -it \
  -v $(pwd):/workspace \
  ghcr.io/<owner>/<repo>:latest

```

This launches an interactive development shell where you can run `./scripts/build.sh` immediately.

---

## Detailed Documentation

* **[Local Development](https://www.google.com/search?q=docs/local-development.md)**: How to use the Docker container for daily coding.
* **[CI Pipeline](https://www.google.com/search?q=docs/ci-pipeline.md)**: Deep dive into the GitHub Actions stages.
* **[Releases & Artifacts](https://www.google.com/search?q=docs/releases.md)**: Information on versioning and how to get the wheels.

