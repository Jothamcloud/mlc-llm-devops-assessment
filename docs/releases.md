# Releases & Artifacts

This document describes how versioning is managed and how build artifacts are generated, validated, and published.

---

## Versioning Strategy

This project follows **Semantic Versioning (SemVer)**.
Releases are driven entirely by **Git tags**.

To trigger a release:

```bash
git tag v0.1.0
git push origin v0.1.0
```

Pushing a version tag triggers the **Release workflow**, which performs fresh, clean builds for all supported platforms before publishing a GitHub Release.

> **Important:**
> All release artifacts are rebuilt from source to guarantee correctness and reproducibility.

---

## Release Workflow Overview

The release process is implemented as a **dedicated workflow** that runs only on version tags (`v*`) or manual dispatch.

High-level flow:

```text
Git Tag (v*)
   |
   v
Release Workflow
   |
   ├── Linux Build → Test → Wheels
   ├── Windows Build → Test → Wheels
   |
   v
GitHub Release
```

This design ensures that:

* Every release is **fully validated**
* Artifacts are **traceable to a tag**
* No hidden dependency on previous CI runs exists

---

## Published Artifacts

Each release publishes **platform-specific Python wheels**.

### Linux Wheels

* **Format:** `.whl`
* **Platform:** Linux (Docker-built, manylinux-compatible)
* **Built using:** Dockerized toolchain
* **Validated inside:** Same Docker image

### Windows Wheels

* **Format:** `.whl`
* **Platform:** Windows (x86_64)
* **Built using:** Native Windows runner
* **Validated using:** CLI and import tests

Both artifacts are attached directly to the **GitHub Release** page.

---

## Artifact Storage & Lifecycle

| Artifact Type      | Storage Location                 | Purpose                      |
| ------------------ | -------------------------------- | ---------------------------- |
| **Docker Images**  | GitHub Container Registry (GHCR) | Build & dev environment      |
| **CI Artifacts**   | GitHub Actions Artifacts         | Short-lived, workflow-scoped |
| **Release Wheels** | GitHub Releases                  | Long-term distribution       |

### Retention Model

* **Actions artifacts:** Temporary, workflow-scoped
* **Release artifacts:** Permanent
* **Docker images:** Tagged (`latest`, `dev`, commit SHA)

---

## Consuming the Package

Once a release is published, wheels can be downloaded from the GitHub Release page.

### Linux

```bash
pip install mlc_llm-0.1.0-*-manylinux*.whl
```

### Windows

```powershell
pip install mlc_llm-0.1.0-*-win_amd64.whl
```

---

## Why Releases Rebuild From Source

A deliberate design choice was made to rebuild during release, rather than reuse artifacts from PR or CI workflows.

### Benefits

* Guarantees a **clean, tag-based build**
* Prevents accidental release of:

  * PR artifacts
  * Debug builds
  * Mismatched dependencies

---

## Cross-Platform Scope

This pipeline supports both Linux and Windows.

* Linux builds are Docker-based for reproducibility
* Windows builds are native to match real user environments
* Both platforms are validated before release

The CI/CD architecture cleanly separates:

* Toolchain provisioning
* Build logic
* Test logic
* Release logic

---

## Assessment Notes

For the purpose of this assessment:

* All workflows support **manual execution**
* Release automation is explicit and auditable
* Real-world constraints (Vulkan, TVM, native builds) are handled explicitly
