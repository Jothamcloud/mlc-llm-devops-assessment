# MLC-LLM CI/CD Pipeline

This repository implements a production-grade, cross-platform CI/CD pipeline for building, testing, and releasing the **MLC-LLM Python package on Linux and Windows**, using a shared Docker-based Linux build environment.

The pipeline demonstrates how a complex native + Python project (CMake, TVM, Vulkan, Python wheels) can be reliably built, tested, and released using modern DevOps practices and GitHub Actions.

---

## Scope

This project delivers the following:

### 1. Docker

* A multipurpose Docker image published to GitHub Container Registry (GHCR)
* Used as:

  * An interactive local development environment
  * A non-interactive CI build environment
* Contains:

  * Conda (Python)
  * CMake
  * Vulkan toolchain
  * Native build dependencies

### 2. Linux CI

* Linux wheel builds using the Docker image
* Test-gated validation inside the same container
* Reproducible native + Python builds

### 3. Windows CI

* Native Windows builds using GitHub-hosted Windows runners
* Vulkan SDK installation using the official LunarG installer
* Windows wheel packaging
* Post-build CLI and Python import validation

### 4. Release Automation

* Versioned wheel artifacts (Linux + Windows)
* GitHub Releases created from validated builds

> For the purpose of this assessment, all workflows can be triggered manually via `workflow_dispatch` to allow easy inspection and review.

---

## High-Level Architecture

```text
Developer / CI
      |
      v
Docker Image (GHCR)
├── Conda
├── CMake
├── Vulkan
└── Build Tooling
      |
      +-----------------------------+
      |                             |
      v                             v
Linux Build (Docker)         Windows Build (Runner)
      |                             |
      v                             v
Linux Wheels                   Windows Wheels
      |                             |
      +-------------+---------------+
                    v
        Release Build (from Git tag)
                    |
                    v
        GitHub Release (version tag)
```

This architecture ensures:

* A single, reproducible Linux environment
* Native Windows correctness
* Clear separation between build, test, and release responsibilities

---

## Repository Structure

```text
.
├── docker/
│   └── Dockerfile                  # Linux build & dev environment
├── scripts/
│   ├── build.sh                    # Linux build + wheel packaging
│   ├── test.sh                     # Linux test validation
│   ├── build.ps1                   # Windows build + wheel packaging
│   └── test.ps1                    # Windows test validation
├── docs/
│   ├── local-development.md
│   ├── ci-pipeline.md
│   └── releases.md
├── README.md
└── .github/workflows/
    ├── docker.yml                  # Docker image build & push
    ├── linux.yml                   # Linux build + test
    ├── windows.yml                 # Windows build + test
    └── release.yml                 # GitHub Releases
```

---

## CI Workflow Overview

| Workflow      | Purpose                                      | Platform | Trigger            |
|---------------|----------------------------------------------|----------|--------------------|
| `docker.yml`  | Build & publish Docker toolchain image       | Linux    | Manual / dev push  |
| `linux.yml`   | Build & test Linux wheels                    | Linux    | Manual / PR        |
| `windows.yml` | Build & test Windows wheels                  | Windows  | Manual / PR        |
| `release.yml` | Rebuild & publish versioned release artifacts| Linux + Windows | Manual / Tag |

> In a production setup, these workflows would typically be fully automated and chained.
>
> For this assessment, **manual triggers are intentionally enabled** to make each stage independently verifiable.

---

## Image Tagging Strategy
The Docker image is treated as a stable build toolchain, not a released artifact.
Docker images are tagged using:

* `latest`
* the Git commit SHA (`${{ github.sha }}`)

The CI pipeline always pulls the `latest` image to ensure:

* Consistent build environments
* Fast CI execution
* Clear separation between tooling and release artifacts

---

## Quick Start (Local Development – Linux)

To jump into a pre-configured environment with all dependencies ready:

```bash
docker pull ghcr.io/<owner>/<repo>:latest

docker run -it \
  -v $(pwd):/workspace \
  ghcr.io/<owner>/<repo>:latest
```

From inside the container:

```bash
./scripts/build.sh
./scripts/test.sh
```

---

## Windows Development Notes

Windows builds are performed directly on GitHub-hosted runners using:

* Visual Studio Build Tools
* Vulkan SDK (LunarG)
* Conda-managed Python environment

This mirrors how native Windows users would build and consume the package outside of Docker.

---

## Releases

Releases are created by pushing a version tag:

```bash
git tag v0.1.0
git push origin v0.1.0
````

The release workflow:

* Pulls the `latest` Docker toolchain image
* Rebuilds Linux wheels from source
* Rebuilds Windows wheels from source
* Publishes all verified artifacts to GitHub Releases

This guarantees that every release is:

* Reproducible
* Platform-consistent
* Traceable to a specific Git tag

---

## Documentation

* **[Local Development](docs/local-development.md)**
  Using the Docker image for day-to-day development.

* **[CI Pipeline](docs/ci-pipeline.md)**
  Detailed explanation of each workflow and design decision.

* **[Releases & Artifacts](docs/releases.md)**
  Versioning strategy and how release artifacts are produced.

---

## Why This Matters

This repository demonstrates:

* Cross-platform native builds (Linux + Windows)
* Docker-based reproducibility
* Artifact-driven CI pipelines
* Real-world dependency handling (Vulkan, TVM, Python wheels)
* Clear separation of responsibilities across CI workflows

---