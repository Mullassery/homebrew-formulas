# Audit Findings - homebrew-formulas

**Audit Date:** 2026-10-27  
**Commit:** `defdd71197e2ac83179cd13f06192a18a5c15e7e`  
**Audit Type:** Read-only systems design audit  
**Detailed report:** [../.audit/reports/homebrew-formulas/audit.md](../.audit/reports/homebrew-formulas/audit.md)

## Summary

`homebrew-formulas` is a legacy combined Homebrew tap with six Apple Silicon formulas: three Python wheel virtualenvs and three TinyBridge components. The formulas use pinned SHA-256 checksums, avoid opaque post-install downloads, and correctly codesign the TinyBridge VM host with its Virtualization entitlement.

The tap has four notable design problems: two TinyBridge formulas own the same VM-host payload and cannot coexist; most formulas are far behind upstream and have no livecheck/update path; the Python formulas reject non-arm CPUs but not non-macOS systems; and there is no formula CI, with `brew style` already reporting seven offenses. The README calls the tap deprecated, but Homebrew itself is not told that.

**Counts:** 0 Critical, 0 High, 4 Medium, 3 Low.

## Quick Findings

- **Medium - Conflicting TinyBridge formulas:** `tinybridged` and `tinybridge-vmhost` both install `bin/tinybridge-vmhost`, `libexec/tinybridge-vmhost`, and the same dylib, so installing both conflicts.
- **Medium - Stale pins:** StreamXL 0.4.0 vs PyPI 5.3.3; ClusterAudienceKit 0.1.0 vs 7.5.2; PyHound 0.1.0; TinyBridge v0.6.1 vs v0.6.3. Only the TinyBridge formulas have livecheck, and none of the Python formulas do.
- **Medium - Platform guard gap:** Python formulas use `disable! ... unless Hardware::CPU.arm?` but do not require macOS, so arm64 Linux accepts a macOS wheel and fails during pip install.
- **Medium - No formula CI:** The only workflow is a manual, non-blocking Graphify job; no style/audit/install/test runs. Current style reports 7 offenses.
- **Low - Deprecation not encoded:** README says legacy/deprecated, but no formula uses `deprecate!`; users get no Homebrew warning.
- **Low - Orphaned PyHound package identity:** The pinned `pyhound-core` wheel still downloads, but PyPI's project endpoint is 404 while `pyhound` 1.0.0 is a source distribution.
- **Low - Style debt:** Missing blank lines after module inclusion, `url`/`version` ordering, and a description starting with the formula name.

## Findings

| Severity | Finding | Evidence | Impact | Recommendation |
|----------|---------|----------|--------|----------------|
| Medium | Duplicate VM-host payload in two formulas | `Formula/tinybridged.rb:24-33`; `Formula/tinybridge-vmhost.rb:19-25`; README lists both | Installing both documented formulas causes a link conflict/ownership collision. | Remove/deprecate `tinybridge-vmhost` or make it depend on `tinybridged`; add `conflicts_with` if necessary. |
| Medium | Formulas are far behind upstream with no update automation | Formula pins vs PyPI/GitHub metadata; `livecheck` absent from all Python formulas | Users get old code and miss fixes; Python 3.13-only virtualenvs remain even where upstream ships pure/abi3 wheels. | Truly deprecate, or bump and add livecheck/automated checksum-update PRs. |
| Medium | Python formulas do not require macOS | `Formula/streamxl.rb:15`; `Formula/clusteraudiencekit.rb:15`; `Formula/pyhound.rb:16`; macOS-tagged wheel URLs | Arm64 Linux passes the guard and fails late during pip install. | Add `depends_on :macos` or include `OS.mac?` in the guard. |
| Medium | No formula validation CI | `.github/workflows/graphify.yml:1-39`; no style/audit/install/test workflow; style reports 7 offenses | Formula breakage and existing style debt can merge undetected. | Add macOS arm64 CI for style/audit/install/test, plus unsupported-platform rejection checks. |
| Low | Deprecation is advisory only | `README.md:3-7,39-42`; no `deprecate!` in formulas | No Homebrew warning or migration prompt at install time. | Encode deprecation with replacement metadata or archive the tap. |
| Low | PyHound package identity is orphaned | `Formula/pyhound.rb:7-11`; pinned wheel URL 200; PyPI `pyhound-core` 404; `pyhound` 1.0.0 is sdist-only | The old wheel still installs, but discovery/upgrades are broken and the pin is a long-term liability. | Move to a supported distribution or remove the formula; add livecheck. |
| Low | Formula style and metadata debt | `brew style Formula/*.rb`; `Formula/tinybridge-vmhost.rb:4` | Cosmetic failures and nonstandard metadata will fail strict CI. | Run `brew style --fix` and enforce it in CI. |

## Positive Controls

- Every artifact is pinned by SHA-256.
- Python packages install offline into isolated virtualenvs.
- No `curl | bash`, post-install network fetch, or privileged script.
- Arm64 guards prevent Intel installation.
- TinyBridge VM host is codesigned with the required entitlement.
- `tinybridged` provides a conventional keep-alive service and log paths.
- README clearly points to the maintained partial taps.

## Recommended Sequence

1. Fix or remove the duplicate `tinybridge-vmhost` formula.
2. Encode tap deprecation and migration guidance, or commit to maintenance.
3. If maintained: bump artifacts, add livecheck, and fix the macOS guard.
4. Add formula CI covering style, audit, install, test, and unsupported platforms.
5. Remove the orphaned PyHound pin or re-home it.
