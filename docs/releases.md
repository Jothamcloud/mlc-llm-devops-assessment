# Releases & Artifacts

This document describes how versioning is managed and how the resulting artifacts are published and consumed.

---

## Versioning Strategy

This project follows **Semantic Versioning (SemVer)**. The release process is entirely automated and driven by Git tags.

To trigger a new release:

1. Ensure the `main` branch is stable.
2. Create and push a version tag:
```bash
git tag v0.1.0
git push origin v0.1.0

```



The CI pipeline will automatically detect the tag, run the full test suite, and generate a GitHub Release.

---

## Published Artifacts

The primary output of this pipeline is the **Linux Python Wheel**.

* **Format:** `.whl` (Standard Python distribution format)
* **Platform:** Manylinux-compatible (x86_64)
* **Location:** Attached directly to the **GitHub Release** page.

---

## Artifact Storage & Lifecycle

| Artifact Type | Storage Location | Retention Policy |
| --- | --- | --- |
| **Docker Images** | GitHub Container Registry (GHCR) | Last 5 versions / Latest |
| **Intermediate Wheels** | GitHub Actions Artifacts | 90 Days (Internal use) |
| **Release Wheels** | GitHub Releases | Permanent / Production |

---

## Consuming the Package

Once a release is complete, you can download the wheel from the Release page and install it in any Linux environment with Python 3.13:

```bash
# Example installation
pip install ./mlc_llm-0.1.0-py3-none-manylinux_2_27_x86_64.whl

```

---

## Technical Constraints & Scope

### Why Windows is Not Included

While MLC-LLM supports Windows, this CI/CD pipeline is scoped to **Linux**.

* **Toolchain Complexity:** Windows builds require MSVC and specific DirectX/Vulkan SDK integrations that vary significantly from the Linux toolchain.
* **Stability:** By focusing on a Docker-based Linux workflow, we ensure 100% reproducibility and stability for this assessment.
* **Future Growth:** The pipeline is architected so that a `windows-build` job could be added to the `.github/workflows/ci.yml` in the future using a Windows-native runner.

---