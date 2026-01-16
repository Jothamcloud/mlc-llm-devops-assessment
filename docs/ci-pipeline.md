# CI Pipeline

This document describes the structure, triggers, and design decisions behind the **MLC-LLM GitHub Actions CI/CD pipeline**.

The pipeline is intentionally split into independent, focused workflows to clearly separate concerns across Docker tooling, Linux builds, Windows builds, and releases.

> For the purpose of this assessment, all workflows support manual execution via `workflow_dispatch` to simplify review and testing.

---

## Pipeline Design Philosophy

This CI/CD pipeline follows four core principles:

1. **Docker is a toolchain, not a release artifact**
2. **Linux and Windows builds are first-class citizens**
3. **Release artifacts are rebuilt from source**
4. **Each workflow has a single responsibility**

---

## Workflow Overview

```text
           dev branch
               |
               v
     Docker Toolchain Image (GHCR, latest)
               |
        ┌──────┴────────┐
        v               v
 Linux Build & Test   Windows Build & Test
        |               |
        └──────┬────────┘
               v
        Release Build (Git tag)
               |
               v
         GitHub Release
```

Key idea:

* **Docker is shared tooling**
* **Releases rebuild wheels from source**
* **Artifacts do not cross workflow boundaries**

## Workflow Triggers

| Workflow     | Trigger Condition                      |
| ------------ | -------------------------------------- |
| Docker Image | Push to `dev`, manual dispatch         |
| Linux CI     | Pull request → `main`, manual dispatch |
| Windows CI   | Pull request → `main`, manual dispatch |
| Release      | Git tag (`v*`), manual dispatch        |

This structure ensures:

* Fast feedback during development
* Full validation before merge
* Clean, reproducible releases


---

## Workflow Breakdown

### 1. Docker Image Build (`docker.yml`)

**Trigger:**

* Push to `dev`
* `workflow_dispatch`

**Purpose:**

* Build a reusable Linux environment containing:

  * Conda
  * CMake
  * Vulkan toolchain
  * Native build dependencies
* Publish the image to **GitHub Container Registry (GHCR)**

**Why Docker is used**

* Vulkan, CMake, Conda, and native dependencies are expensive to install
* Baking them into an image drastically reduces CI time
* Ensures perfect environment parity between local dev and CI

**Key Characteristics**

* Published to **GitHub Container Registry (GHCR)**
* Tagged as:

  * `latest`
  * commit `SHA`
  * optionally `dev`
* Not tied to Git tags or releases

**Important**

> Docker images are **never released artifacts**.
> They exist solely to enable reproducible builds.

---

### 2. Linux Build & Test (`linux.yml`)

**Trigger:**

* Pull request targeting `main`
* `workflow_dispatch`

The Linux CI workflow is split into two explicit jobs to mirror real-world CI patterns: **build once, test separately**, while reusing the same Docker-based toolchain.

#### Linux Build Job

**Purpose**
Compile native code and package Linux Python wheels in a reproducible environment.

**Steps**

1. **Checkout source**

   * Repository is checked out with submodules.

2. **Select Docker toolchain**

   * Uses the prebuilt Docker image from GHCR.
   * Image is referenced via:

     * `IMAGE_NAME = ghcr.io/<org>/<repo>`
     * `IMAGE_TAG = latest`

3. **Build wheels**

   * Runs `scripts/build.sh` inside the container.
   * Produces Linux `.whl` files.

4. **Upload artifacts**

   * Wheels are uploaded as a GitHub Actions artifact:

     * `linux-wheels`

```text
linux-build
  └─ docker run → build.sh → linux-wheels (artifact)
```
---
#### Linux Test Job

**Purpose**
Validate the previously built wheels in a clean environment.

**Steps**

1. **Download artifacts**

   * Retrieves `linux-wheels` produced by the build job.

2. **Reuse the same Docker toolchain**

   * Pulls the *same* Docker image (`:latest`) to ensure environment parity.

3. **Run tests**

   * Executes `scripts/test.sh` inside the container.
   * Installs the wheel and validates:

     * CLI entry point
     * Python imports
     * Runtime sanity checks

```text
linux-test
  └─ download linux-wheels → docker run → test.sh
```

**Why this matters**

* Build and test are logically isolated
* Test failures do not require rebuilding

---

### 3. Windows Build & Test (`windows.yml`)

**Trigger:**

* Pull request targeting `main`
* `workflow_dispatch`

**Environment:**

* GitHub-hosted Windows runners (no Docker)

The Windows CI workflow follows the **same two-stage pattern** as Linux, adapted for native Windows tooling.

---

#### Windows Build Job

**Purpose**
Compile and package Windows Python wheels using native Windows toolchains.

**Steps**

1. **Checkout source**
2. **Provision environment**

   * Conda-based Python (3.11)
   * CMake, Rust, Clang, Vulkan loader
   * Official LunarG Vulkan SDK (unattended install)
3. **Build wheels**

   * Executes `scripts/build.ps1`
4. **Upload artifacts**

   * Wheels are uploaded as:

     * `windows-wheels`

```text
windows-build
  └─ native build → build.ps1 → windows-wheels (artifact)
```

---

#### Windows Test Job

**Purpose**
Validate Windows wheels in a clean environment.

**Steps**

1. **Download artifacts**

   * Retrieves `windows-wheels`.

2. **Recreate runtime environment**

   * Conda Python
   * Vulkan loader + runtime deps

3. **Run tests**

   * Executes `scripts/test.ps1`
   * Verifies:

     * `mlc_llm` CLI availability
     * Python import correctness

```text
windows-test
  └─ download windows-wheels → test.ps1
```

---

### 4. Release (`release.yml`)

**Trigger:**

* Push of a version tag (`v*`)
* `workflow_dispatch`

**Steps:**

1. Download Linux and Windows wheel artifacts
2. Attach wheels to a GitHub Release
3. Publish immutable, versioned binaries

**Important properties:**

* Releases only happen from **validated builds**
* Artifacts are traceable to a specific Git commit
* No rebuilds during release → avoids “it worked in CI but not in release”

---

## Why the Pipeline Is Split

This CI/CD design intentionally avoids a monolithic workflow.

**Benefits:**

* Clear separation of concerns
* Faster iteration during Docker image development
* Independent Linux and Windows validation
* Easier debugging and manual re-runs
---

## Manual Execution

For assessment and review purposes, all workflows support manual execution using GitHub’s `workflow_dispatch`.

This allows:

* Running individual stages in isolation
* Easier inspection of logs and artifacts

---

## Summary

This pipeline demonstrates:

* Dockerized Linux reproducibility
* Native Windows build correctness
* Artifact-driven CI
* Safe, tag-based release automation
* Real-world handling of native dependencies (Vulkan, TVM)

It is designed to scale naturally into a fully automated production pipeline with minimal changes.

---
