# Audit Report: homebrew-formulas

**Audit Date:** 2026-10-27  
**Repository:** `/Users/georgimullassery/Desktop/Projects/homebrew-formulas`  
**Commit:** `defdd71197e2ac83179cd13f06192a18a5c15e7e` (2026-10-25)  
**Audit Type:** Read-only systems design audit  
**Scope:** Six formulas, tap documentation, repository automation, and published artifact metadata. Formula installation was not executed; `brew style` and Ruby syntax checks were run.

## Executive Summary

This is a legacy combined Homebrew tap for six Apple Silicon formulas: three Python wheel virtualenvs and three TinyBridge components. The formulas are mostly small and readable, use pinned SHA-256 checksums, re-encode TinyBridge binaries with the required entitlement, and avoid post-install shell downloads.

The tap is explicitly described as deprecated in its README, but that deprecation is not represented in Homebrew metadata, so users receive no brew-level warning. More importantly, the tap lists two TinyBridge formulas that install the same `tinybridge-vmhost` payload and therefore cannot coexist, five formulas are substantially behind their upstream releases, and there is no formula CI. The Python formula architecture guard also checks CPU but not operating system, so an arm64 Linux Homebrew installation can be accepted and then fail on a macOS wheel.

**Finding counts:** 0 Critical, 0 High, 4 Medium, 3 Low.

## Overview

- **Type:** Homebrew tap with custom Ruby formula definitions.
- **Purpose:** Install Mullassery tools from prebuilt macOS arm64 artifacts: StreamXL, ClusterAudienceKit, PyHound, TinyBridge CLI, TinyBridge daemon, and TinyBridge VM host.
- **Distribution:** Direct PyPI wheel URLs for the Python libraries; one shared GitHub release tarball for all three TinyBridge formulas.
- **Platform:** Apple Silicon only. Every formula either checks `Hardware::CPU.arm?` or depends on macOS Ventura.
- **Maintenance status:** README calls the tap “legacy, deprecated” and points to `homebrew-prismnote` and `homebrew-tinybridge`, but the tap still publishes install instructions and installable formulas.

## Architecture

- `Formula/*.rb` are independent formula classes; there is no shared tap library or DSL abstraction.
- The three Python formulas include `Language::Python::Virtualenv`, create a private virtualenv, and install a single wheel from the downloaded buildpath.
- The TinyBridge formulas install prebuilt Mach-O executables from one tarball. `tinybridged` and `tinybridge-vmhost` both install `tinybridge-vmhost` plus its dylib and codesign the VM host with `tinybridge-vmhost.entitlements`.
- `tinybridged` supplies a Homebrew `service` block for the daemon; `tinybridge` and `tinybridge-vmhost` are CLI/component formulas.
- Repository automation contains only a manual, non-blocking Graphify workflow. No formula style, audit, install, or test job exists.

## Entry Points

- `brew tap Mullassery/homebrew-formulas`
- `brew install streamxl`
- `brew install clusteraudiencekit`
- `brew install pyhound`
- `brew install tinybridge`
- `brew install tinybridged`
- `brew install tinybridge-vmhost`
- `brew services start tinybridged`

## Dependencies

- **Homebrew DSL:** `Language::Python::Virtualenv`, `Hardware::CPU`, `OS`/macOS dependencies, `service`.
- **Upstream runtimes:** `python@3.13` for all three Python formulas; macOS Ventura or later for all TinyBridge formulas.
- **Artifacts:** PyPI-hosted wheel files pinned by URL and SHA-256; GitHub release tarball v0.6.1 pinned once and reused by three formulas.
- **Repository CI dependencies:** Graphify only, installed at workflow runtime; no formula toolchain job.

## Module Structure

- `Formula/streamxl.rb` — StreamXL 0.4.0 arm64 wheel virtualenv.
- `Formula/clusteraudiencekit.rb` — ClusterAudienceKit 0.1.0 arm64 wheel virtualenv.
- `Formula/pyhound.rb` — PyHound 0.1.0 arm64 wheel virtualenv; wheel is published as `pyhound-core`.
- `Formula/tinybridge.rb` — TinyBridge CLI from the combined release tarball.
- `Formula/tinybridged.rb` — daemon, VM host, dylib, codesign, and service definition.
- `Formula/tinybridge-vmhost.rb` — duplicate VM host + dylib installation without the daemon.
- `README.md`, `USE_CASES.md` — tap status, installation, and high-level positioning.
- `.github/workflows/graphify.yml` — optional manual Graphify analysis only.
- `tools/graphify/` — repository graph adapter, unrelated to formula validation.

## Data, State, APIs, and Contracts

- **Install contract:** Each formula downloads a pinned artifact, verifies SHA-256, and installs into the Homebrew prefix. Python libraries are isolated in `libexec` virtualenvs; TinyBridge binaries go to `bin`/`libexec`.
- **Codesign contract:** Both VM host formulas require `tinybridge-vmhost.entitlements` in the tarball and ad-hoc sign the installed binary. The entitlement file was previously verified to be present in the release tarball.
- **Service contract:** `tinybridged` runs `opt_bin/tinybridged`, keeps it alive on unsuccessful exit, and writes stdout/stderr to `var/log/tinybridge.log`.
- **Artifact identity:** One tarball serves three formulas; the same SHA-256 is repeated in all three. PyPI wheels use CPython 3.13 tags and macOS 11 arm64 platform tags.
- **State:** No application state is managed by the formulas beyond Homebrew's install tree, the virtualenv, and the daemon log/service state.

## Security Observations

### Positive controls

- All artifacts use pinned SHA-256 checksums; no unpinned `curl | bash` or post-install download exists.
- Python dependencies are installed offline from the downloaded wheel into an isolated virtualenv.
- TinyBridge binaries are ad-hoc signed with an explicit entitlements file rather than being left unsigned.
- The formulas are declarative and contain no arbitrary Ruby execution beyond Homebrew/`codesign`.
- Architecture guards prevent accidental Intel installation of arm64-only artifacts.

### Risk themes

1. **Co-installation conflict:** `tinybridged` and `tinybridge-vmhost` both own `bin/tinybridge-vmhost`, `libexec/tinybridge-vmhost`, and `libexec/libTinyBridgeVZBridge.dylib`. Homebrew cannot link both cleanly.
2. **Staleness:** The tap is deprecated but still installable, and its pins are far behind upstream. No livecheck or update automation exists for five of six formulas.
3. **Platform guard gap:** The Python formulas guard on CPU architecture only; an arm64 Linux host is not excluded despite the wheels being macOS-only.
4. **No validation pipeline:** Formula style, audit, install, and test are not run in CI. Current `brew style` already reports seven offenses.
5. **Deprecation is advisory only:** README text does not translate into `deprecate!` metadata, so Homebrew users are not warned at install time.

## Tests and CI

- There is no formula CI. `.github/workflows/graphify.yml` is manual (`workflow_dispatch`), non-blocking (`continue-on-error: true`), and only builds a code graph.
- All six formulas parse successfully (`ruby -c`).
- `brew style Formula/*.rb` reports seven offenses:
  - missing blank line after `include Language::Python::Virtualenv` in all three Python formulas;
  - `url` ordered before `version` in all three Python formulas;
  - `tinybridge-vmhost` description starting with the formula name.
- No `brew audit`, `brew install`, or `brew test` was executed; the audit is static and metadata-based.

## Findings

| Severity | Finding | Evidence | Impact | Root Cause Hypothesis | Recommendation |
|----------|---------|----------|--------|----------------------|---------------|
| Medium | `tinybridged` and `tinybridge-vmhost` install the same payload and cannot coexist | `Formula/tinybridged.rb:24-33` installs `libexec/tinybridge-vmhost`, `libexec/libTinyBridgeVZBridge.dylib`, and `bin.install_symlink`; `Formula/tinybridge-vmhost.rb:19-25` installs the same three paths; README lists both as available | Installing both documented formulas causes a link conflict or overwrites ownership of the same files; users cannot compose the daemon and standalone VM-host formulas. | The VM host was split into a separate formula without declaring a conflict or making one formula depend on the other. | Remove/deprecate `tinybridge-vmhost`, or make it an alias/dependency of `tinybridged`; add `conflicts_with` if coexistence is intentional; install shared payload in exactly one formula. |
| Medium | Five formulas are substantially stale, with no livecheck/update path | `streamxl.rb` pins 0.4.0 while PyPI reports 5.3.3; `clusteraudiencekit.rb` pins 0.1.0 while PyPI reports 7.5.2; `pyhound.rb` pins 0.1.0; `tinybridge.rb`/`tinybridged.rb`/`tinybridge-vmhost.rb` pin v0.6.1 while GitHub latest is v0.6.3; only the TinyBridge formulas and none of the Python formulas define livecheck | Users following the README receive old code and may miss bug/security fixes and compatibility improvements. The Python formulas still require CPython 3.13 even where upstream now ships abi3 or pure-Python wheels. | Legacy tap is intentionally frozen but remains advertised and installable; updates were manual and stopped. | Prefer making the tap truly deprecated and redirecting users. If maintained, bump to current artifacts, add `livecheck` to every formula, and automate update PRs with checksum verification. |
| Medium | Python formulas guard architecture but not operating system | `Formula/streamxl.rb:15`, `Formula/clusteraudiencekit.rb:15`, `Formula/pyhound.rb:16` use `disable! ... unless Hardware::CPU.arm?`; none declares a macOS dependency; all URLs are `macosx_11_0_arm64` wheels | On Homebrew for Linux arm64 the formula remains enabled, then fails when pip attempts to install a macOS wheel. The failure is late and confusing rather than a clean “unsupported platform” message. | Arm64 Mac was the only intended platform, but the guard models “arm CPU” instead of “macOS on arm.” | Use `depends_on :macos` (or `disable! ... unless OS.mac? && Hardware::CPU.arm?`) in addition to the architecture guard, and test the disabled path. |
| Medium | No formula validation CI; current style checks already fail | `.github/workflows/graphify.yml:1-39` is manual and only runs Graphify; no `.github/workflows` job runs `brew style`, `brew audit`, install, or test; `brew style` reports seven offenses across the formulas | Formula syntax/style regressions, bad checksums, duplicate payloads, and install/test failures can merge without detection. The existing style debt demonstrates the gap. | CI was added for graph analysis but not for the repository's actual product: formulas. | Add a macOS arm64 workflow running `brew style`, `brew audit --strict`, `brew install --build-from-source`, and `brew test` for each formula, plus a Linux arm64 check that unsupported formulas are rejected cleanly. |
| Low | Tap deprecation is documentation-only | `README.md:3-7,39-42` says the tap is legacy/deprecated, but no `deprecate!` is present in any formula; `disable!` is used only for non-arm architectures | Users do not receive Homebrew's deprecation warning or migration guidance at install time; the tap remains discoverable and appears maintained. | Deprecation was documented but not encoded in formula metadata. | Add tap/formula `deprecate!` with a replacement tap/formula, or archive the repository and make the README the only installation path. |
| Low | `pyhound` is pinned to an orphaned package identity | `Formula/pyhound.rb:7-11` says PyPI distribution `pyhound-core` is used; the pinned wheel URL returns HTTP 200, but PyPI's `pyhound-core` JSON endpoint returns 404 and current PyPI `pyhound` 1.0.0 is a source distribution; no livecheck exists | The formula still installs the cached 0.1.0 wheel, but the package identity is no longer discoverable/upgradable through PyPI, increasing long-term breakage and confusion risk. | Package renamed/removed upstream while the formula retained a direct file URL. | Pin to a supported current distribution or remove the formula; add livecheck against the actual package; document the naming history only if the artifact remains published. |
| Low | Formula style debt and metadata inconsistencies | `brew style` reports missing blank lines after module inclusion, `url` before `version` ordering, and a description beginning with the formula name (`Formula/tinybridge-vmhost.rb:4`) | Cosmetic/style failures make the tap look unmaintained and will fail a future strict CI gate; `tinybridge-vmhost` also has a nonstandard description. | Hand-written formulas without style enforcement. | Apply `brew style --fix`, then enforce style in CI. |

## Strengths

- Pinned SHA-256 checksums for every artifact.
- Small, declarative formulas with no opaque post-install scripts.
- Python packages are isolated in virtualenvs rather than installed into the system Python.
- Architecture guards fail cleanly on Intel Macs for every formula.
- TinyBridge VM host is explicitly codesigned with the Virtualization entitlement.
- `tinybridged` provides a conventional keep-alive service and log paths.
- Clear README migration pointers to the maintained partial taps.
- No secrets, credentials, or privileged install steps are present.

## Limitations

- Apple Silicon only; Intel, Linux, and Windows are unsupported.
- No formula install/test was executed in this audit, so runtime behavior is inferred from formulas and upstream metadata.
- Upstream release assets were checked by URL/API metadata, not by downloading and re-verifying every checksum.
- The tap is explicitly legacy, so some staleness may be intentional; it still affects anyone following the published install commands.
- No compatibility matrix for Homebrew versions, macOS releases, or Python patch levels.

## Prioritized Recommendations

1. **Medium:** Resolve the TinyBridge formula ownership conflict by removing/deprecating `tinybridge-vmhost` or making `tinybridged` the sole owner of the VM host payload.
2. **Medium:** Make the deprecation real and migration-first; if the tap is kept, bump all artifacts and add livecheck/update automation.
3. **Medium:** Fix the platform guard to require macOS as well as arm64 for the Python wheels.
4. **Medium:** Add formula CI: style, audit, install, test, and clean unsupported-platform rejection.
5. **Low:** Remove or re-home the orphaned `pyhound` pin.
6. **Low:** Apply style fixes and correct formula descriptions/metadata.
