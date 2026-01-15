# CI Pipeline

This document describes the structure, triggers, and logic of the GitHub Actions automated workflow.

---

## Workflow Triggers

To balance resource usage and developer feedback, the pipeline is triggered by:

* **Pull Requests:** Validates code before merging.
* **Pushes to `main`:** Ensures the main branch remains in a deployable state.
* **Version Tags (`v*`):** Triggers the official release process.
* **Manual Dispatch:** Allows maintainers to run the pipeline on-demand.

---

## Job Overview

The pipeline is organized into a directed acyclic graph (DAG) to ensure that expensive build steps only occur if the environment is ready, and releases only occur if tests pass.

```text
docker-image (Builds environment)
      |
      v
linux-build  (Compiles code/wheels)
      |
      v
linux-test   (Validates functionality)
      |
      v
release      (Publishes artifacts - Tags only)

```

---

## Job Breakdown

### 1. Docker Image Build & Push

* **Purpose:** Pre-builds the heavy dependency layer.
* **Registry:** Pushes to GitHub Container Registry (GHCR).
* **Caching:** Uses GitHub Actions cache to speed up subsequent image builds.
* **Tagging:** Images are tagged with the commit SHA and `latest`.

### 2. Linux Build

* **Environment:** Runs inside the container built in step 1.
* **Action:** Executes `scripts/build.sh`.
* **Output:** Generates a `.whl` file (Python Wheel).
* **Persistence:** The wheel is uploaded as a GitHub Action artifact named `linux-wheels`.

### 3. Linux Tests

* **Dependency:** Starts only after `linux-build` completes successfully.
* **Action:** Downloads the wheel, installs it, and runs `scripts/test.sh`.
* **Gatekeeping:** If any test fails, the pipeline stops here, preventing a broken release.

### 4. Release (Tags Only)

* **Condition:** Triggered only when a Git tag (e.g., `v1.0.2`) is pushed.
* **Action:** Collects the verified wheels from the build stage and creates a GitHub Release.
* **Visibility:** Automatically generates release notes based on commit history.

---

## Why Docker is Used in CI

* **Environment Parity:** The exact same environment used by the developer is used in CI.
* **Efficiency:** We don't waste time installing `cmake`, `rust`, or `vulkan` on every run; they are baked into the image.
* **Portability:** If we move from GitHub Actions to another provider (e.g., GitLab or Jenkins), the core logic remains inside the container.

---